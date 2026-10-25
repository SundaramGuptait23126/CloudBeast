import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/drive_song.dart';
import '../services/audio_player_service.dart';
import '../services/google_drive_service.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  final GoogleDriveService _driveService = GoogleDriveService();

  DriveSong? _currentSong;
  List<DriveSong> _queue = [];
  int _currentIndex = -1;

  PlayerState _playerState = PlayerState(false, ProcessingState.idle);
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _bufferedPosition = Duration.zero;

  bool _isShuffle = false;
  LoopMode _loopMode = LoopMode.off;
  bool _isCaching = false;
  double _cachingProgress = 0.0;
  bool _isLoadingSong = false;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _bufferedPositionSubscription;

  DriveSong? get currentSong => _currentSong;
  List<DriveSong> get queue => _queue;
  int get currentIndex => _currentIndex;
  PlayerState get playerState => _playerState;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration get bufferedPosition => _bufferedPosition;
  bool get isPlaying => _playerState.playing;
  bool get isBuffering =>
      !_playerState.playing &&
      (_isLoadingSong ||
          _playerState.processingState == ProcessingState.buffering ||
          _playerState.processingState == ProcessingState.loading);
  bool get isShuffle => _isShuffle;
  LoopMode get loopMode => _loopMode;
  bool get isCaching => _isCaching;
  double get cachingProgress => _cachingProgress;

  PlayerProvider() {
    _initListeners();
  }

  void _initListeners() {
    _playerStateSubscription = _audioService.playerStateStream.listen((state) {
      _playerState = state;
      if (state.processingState == ProcessingState.completed) {
        _handleTrackCompleted();
      }
      notifyListeners();
    });

    _positionSubscription = _audioService.positionStream.listen((pos) {
      if ((pos.inMilliseconds - _position.inMilliseconds).abs() >= 250 ||
          pos == Duration.zero) {
        _position = pos;
        notifyListeners();
      }
    });

    _durationSubscription = _audioService.durationStream.listen((dur) {
      if (dur != null && dur != _duration) {
        _duration = dur;
        notifyListeners();
      }
    });

    _bufferedPositionSubscription =
        _audioService.bufferedPositionStream.listen((buf) {
      if ((buf.inMilliseconds - _bufferedPosition.inMilliseconds).abs() >= 500) {
        _bufferedPosition = buf;
        notifyListeners();
      }
    });
  }

  /// Start playing a song, optionally supplying queue and initial index
  Future<void> playSong(DriveSong song, {List<DriveSong>? queue, int? index}) async {
    if (queue != null && queue.isNotEmpty) {
      _queue = List.from(queue);
      _currentIndex = index ?? _queue.indexWhere((s) => s.id == song.id);
      if (_currentIndex == -1) {
        _queue.insert(0, song);
        _currentIndex = 0;
      }
    } else if (!_queue.any((s) => s.id == song.id)) {
      _queue.add(song);
      _currentIndex = _queue.length - 1;
    } else {
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    }

    _currentSong = song;
    _isLoadingSong = true;
    notifyListeners();

    try {
      await _audioService.playSong(song);
    } catch (e) {
      debugPrint('Error playing song: $e');
    } finally {
      _isLoadingSong = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_currentSong == null) {
      if (_queue.isNotEmpty) {
        await playSong(_queue.first);
      }
      return;
    }

    if (isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> skipNext() async {
    if (_queue.isEmpty) return;

    if (_isShuffle) {
      final nextIndex = (_currentIndex + 1) % _queue.length;
      await playSong(_queue[nextIndex], index: nextIndex);
      return;
    }

    if (_currentIndex < _queue.length - 1) {
      final nextIndex = _currentIndex + 1;
      await playSong(_queue[nextIndex], index: nextIndex);
    } else if (_loopMode == LoopMode.all) {
      await playSong(_queue.first, index: 0);
    }
  }

  Future<void> skipPrevious() async {
    if (_queue.isEmpty) return;

    // If more than 3 seconds in, restart current track
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      final prevIndex = _currentIndex - 1;
      await playSong(_queue[prevIndex], index: prevIndex);
    } else {
      await seek(Duration.zero);
    }
  }

  void _handleTrackCompleted() {
    if (_loopMode == LoopMode.one) {
      seek(Duration.zero);
      _audioService.resume();
    } else {
      skipNext();
    }
  }

  Future<void> toggleShuffle() async {
    _isShuffle = !_isShuffle;
    await _audioService.setShuffleModeEnabled(_isShuffle);
    notifyListeners();
  }

  Future<void> toggleLoopMode() async {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }
    await _audioService.setLoopMode(_loopMode);
    notifyListeners();
  }

  /// Download and cache current song for offline & rapid seek
  Future<void> cacheCurrentSong() async {
    if (_currentSong == null || _isCaching) return;

    _isCaching = true;
    _cachingProgress = 0.0;
    notifyListeners();

    try {
      final localPath = await _driveService.cacheSongLocally(
        _currentSong!,
        onProgress: (p) {
          _cachingProgress = p;
          notifyListeners();
        },
      );

      if (localPath != null) {
        _currentSong = _currentSong!.copyWith(localFilePath: localPath);
        // update in queue
        if (_currentIndex >= 0 && _currentIndex < _queue.length) {
          _queue[_currentIndex] = _currentSong!;
        }
      }
    } catch (e) {
      debugPrint('Failed to cache current track: $e');
    } finally {
      _isCaching = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}
