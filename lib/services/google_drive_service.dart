import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../models/drive_song.dart';
import 'google_auth_service.dart';
import 'mock_drive_data.dart';

class GoogleDriveService {
  static final GoogleDriveService _instance = GoogleDriveService._internal();
  factory GoogleDriveService() => _instance;
  GoogleDriveService._internal();

  final GoogleAuthService _authService = GoogleAuthService();
  final Map<String, String> _folderNameCache = {};

  /// Fetch all audio songs from Google Drive
  Future<List<DriveSong>> fetchDriveSongs({bool isDemo = false}) async {
    if (isDemo) {
      // Simulate network latency
      await Future.delayed(const Duration(milliseconds: 600));
      return MockDriveData.getSampleSongs();
    }

    final account = _authService.currentUser;
    if (account == null) {
      throw Exception('User is not signed in to Google Drive.');
    }

    // Use the authenticated GoogleSignIn instance
    final authClient = await _authService.googleSignIn.authenticatedClient();
    if (authClient == null) {
      throw Exception('Failed to obtain authenticated Google Drive client.');
    }

    final driveApi = drive.DriveApi(authClient);
    final List<DriveSong> songs = [];

    try {
      String? pageToken;
      do {
        final drive.FileList result = await driveApi.files.list(
          q: "mimeType contains 'audio/' and trashed = false",
          spaces: 'drive',
          $fields: 'nextPageToken, files(id, name, mimeType, size, webContentLink, parents)',
          pageSize: 100,
          pageToken: pageToken,
        );

        final files = result.files;
        if (files != null) {
          for (final file in files) {
            if (file.id == null || file.name == null) continue;

            String folderId = 'root';
            String folderName = 'Main Drive';

            if (file.parents != null && file.parents!.isNotEmpty) {
              folderId = file.parents!.first;
              folderName = await _resolveFolderName(driveApi, folderId);
            }

            final song = DriveSong(
              id: file.id!,
              name: file.name!,
              mimeType: file.mimeType ?? 'audio/mpeg',
              size: file.size != null ? int.tryParse(file.size!) : null,
              webContentLink: file.webContentLink,
              streamUrl: 'https://www.googleapis.com/drive/v3/files/${file.id}?alt=media',
              folderId: folderId,
              folderName: folderName,
            );
            songs.add(song);
          }
        }
        pageToken = result.nextPageToken;
      } while (pageToken != null && pageToken.isNotEmpty);
    } catch (e) {
      debugPrint('Error querying Google Drive: $e');
      rethrow;
    }

    return songs;
  }

  /// Resolve folder ID to human-readable folder name
  Future<String> _resolveFolderName(drive.DriveApi driveApi, String folderId) async {
    if (_folderNameCache.containsKey(folderId)) {
      return _folderNameCache[folderId]!;
    }
    try {
      final folder = await driveApi.files.get(
        folderId,
        $fields: 'name',
      ) as drive.File;
      final name = folder.name ?? 'Folder';
      _folderNameCache[folderId] = name;
      return name;
    } catch (e) {
      debugPrint('Could not resolve folder name for $folderId: $e');
      return 'Folder';
    }
  }

  /// Download and cache a song locally for offline and instant seek playback
  Future<String?> cacheSongLocally(DriveSong song, {Function(double progress)? onProgress}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/cloudbeats_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final sanitizedName = song.name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final localFile = File('${cacheDir.path}/${song.id}_$sanitizedName');

      if (await localFile.exists()) {
        return localFile.path;
      }

      // Check if it's a demo URL or Google Drive file
      final headers = await _authService.getAuthHeaders();
      final uri = Uri.parse(song.streamUrl ?? 'https://www.googleapis.com/drive/v3/files/${song.id}?alt=media');

      final request = http.Request('GET', uri)..headers.addAll(headers);
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception('Download failed with status: ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      int downloaded = 0;
      final sink = localFile.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloaded += chunk.length;
        if (contentLength > 0 && onProgress != null) {
          onProgress(downloaded / contentLength);
        }
      }

      await sink.close();
      return localFile.path;
    } catch (e) {
      debugPrint('Error caching song: $e');
      return null;
    }
  }

  /// Get total cache size on disk
  Future<int> getCacheSizeBytes() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/cloudbeats_cache');
      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final file in cacheDir.list(recursive: true, followLinks: false)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all cached song files
  Future<void> clearCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/cloudbeats_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
  }
}
