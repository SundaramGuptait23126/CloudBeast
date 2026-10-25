import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drive_song.dart';
import '../services/google_drive_service.dart';

class LibraryProvider extends ChangeNotifier {
  final GoogleDriveService _driveService = GoogleDriveService();

  List<DriveSong> _allSongs = [];
  List<DriveSong> _filteredSongs = [];
  final Set<String> _favoriteSongIds = {};
  final Map<String, List<DriveSong>> _folderGroups = {};

  String? _selectedFolderId;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<DriveSong> get allSongs => _allSongs;
  List<DriveSong> get filteredSongs => _filteredSongs;
  Set<String> get favoriteSongIds => _favoriteSongIds;
  Map<String, List<DriveSong>> get folderGroups => _folderGroups;
  String? get selectedFolderId => _selectedFolderId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DriveSong> get favoriteSongs =>
      _allSongs.where((song) => _favoriteSongIds.contains(song.id)).toList();

  int get totalSizeBytes =>
      _allSongs.fold(0, (sum, song) => sum + (song.size ?? 0));

  LibraryProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = prefs.getStringList('favorite_song_ids') ?? [];
      _favoriteSongIds.addAll(favList);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> toggleFavorite(DriveSong song) async {
    if (_favoriteSongIds.contains(song.id)) {
      _favoriteSongIds.remove(song.id);
    } else {
      _favoriteSongIds.add(song.id);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_song_ids', _favoriteSongIds.toList());
    } catch (e) {
      debugPrint('Error saving favorite: $e');
    }

    notifyListeners();
  }

  bool isFavorite(String songId) => _favoriteSongIds.contains(songId);

  /// Load songs from Google Drive or Demo mock
  Future<void> fetchSongs({required bool isDemo}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final songs = await _driveService.fetchDriveSongs(isDemo: isDemo);
      _allSongs = songs;

      // Group into folders
      _folderGroups.clear();
      for (final song in songs) {
        final folderName = song.folderName;
        if (!_folderGroups.containsKey(folderName)) {
          _folderGroups[folderName] = [];
        }
        _folderGroups[folderName]!.add(song);
      }

      _applyFilters();
    } catch (e) {
      _errorMessage = 'Failed to load songs: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search query filter
  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  /// Filter by specific folder
  void selectFolder(String? folderId) {
    _selectedFolderId = folderId;
    _applyFilters();
  }

  void _applyFilters() {
    List<DriveSong> results = List.from(_allSongs);

    // Apply folder filter
    if (_selectedFolderId != null && _selectedFolderId != 'all') {
      results = results.where((s) => s.folderId == _selectedFolderId || s.folderName == _selectedFolderId).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      results = results.where((s) {
        final title = s.title.toLowerCase();
        final artist = s.artist.toLowerCase();
        final filename = s.name.toLowerCase();
        return title.contains(_searchQuery) ||
            artist.contains(_searchQuery) ||
            filename.contains(_searchQuery);
      }).toList();
    }

    _filteredSongs = results;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedFolderId = null;
    _applyFilters();
  }
}
