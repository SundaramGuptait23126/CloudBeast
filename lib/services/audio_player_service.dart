import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:http/http.dart' as http;

import '../models/drive_song.dart';
import 'google_auth_service.dart';
import 'web_audio_helper.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal() {
    _initAudioSession();
  }

  final AudioPlayer _player = AudioPlayer();
  final GoogleAuthService _authService = GoogleAuthService();
  String? _lastBlobUrl;

  AudioPlayer get player => _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<double> get speedStream => _player.speedStream;

  Duration get currentPosition => _player.position;
  Duration? get totalDuration => _player.duration;
  bool get isPlaying => _player.playing;

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint('Failed to configure audio session: $e');
    }
  }

  /// Load and start playing a song from Google Drive, Local Cache, or Network
  Future<void> playSong(DriveSong song) async {
    try {
      await _player.stop();

      // Revoke previous Web blob URL if any
      if (_lastBlobUrl != null) {
        WebAudioHelper.revokeBlobUrl(_lastBlobUrl!);
        _lastBlobUrl = null;
      }

      // Case 1: Cached local file on disk
      if (song.localFilePath != null && song.localFilePath!.isNotEmpty) {
        await _player.setFilePath(song.localFilePath!);
      }
      // Case 2: External HTTP stream (Demo mock or direct link)
      else if (song.streamUrl != null &&
          !song.streamUrl!.contains('googleapis.com')) {
        await _player.setUrl(song.streamUrl!);
      }
      // Case 3: Google Drive API streaming with OAuth Bearer Token
      else {
        final authHeaders = await _authService.getAuthHeaders();
        final uri = Uri.parse(
          song.streamUrl ??
              'https://www.googleapis.com/drive/v3/files/${song.id}?alt=media',
        );

        if (kIsWeb) {
          // On Web: HTML5 <audio> does not support custom request headers like Authorization.
          // Fetch authenticated bytes through http client with Bearer token, then create in-memory Blob URL.
          final response = await http.get(uri, headers: authHeaders);
          if (response.statusCode != 200) {
            throw Exception('Drive returned status ${response.statusCode}');
          }

          final blobUrl = WebAudioHelper.createBlobUrl(
            response.bodyBytes,
            song.mimeType.isNotEmpty ? song.mimeType : 'audio/mpeg',
          );
          _lastBlobUrl = blobUrl;
          await _player.setUrl(blobUrl);
        } else {
          // On Mobile (Android/iOS) and Desktop: ExoPlayer supports headers natively
          final audioSource = AudioSource.uri(
            uri,
            headers: authHeaders,
            tag: song,
          );
          await _player.setAudioSource(audioSource);
        }
      }

      await _player.play();
    } catch (e) {
      debugPrint('Error playing song (${song.title}): $e');
      rethrow;
    }
  }

  Future<void> resume() async => await _player.play();

  Future<void> pause() async => await _player.pause();

  Future<void> stop() async => await _player.stop();

  Future<void> seek(Duration position) async => await _player.seek(position);

  Future<void> setLoopMode(LoopMode mode) async => await _player.setLoopMode(mode);

  Future<void> setShuffleModeEnabled(bool enabled) async =>
      await _player.setShuffleModeEnabled(enabled);

  Future<void> dispose() async {
    if (_lastBlobUrl != null) {
      WebAudioHelper.revokeBlobUrl(_lastBlobUrl!);
    }
    await _player.dispose();
  }
}
