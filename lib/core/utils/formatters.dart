class Formatters {
  /// Formats a Duration into `mm:ss` or `hh:mm:ss`
  static String formatDuration(Duration? duration) {
    if (duration == null || duration.inSeconds < 0) return '00:00';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// Formats byte count into human-readable size e.g. 5.2 MB
  static String formatBytes(int? bytes) {
    if (bytes == null || bytes <= 0) return '0 KB';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double d = bytes.toDouble();
    while (d >= 1024 && i < suffixes.length - 1) {
      d /= 1024;
      i++;
    }
    return '${d.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Parses track title and artist from raw file name
  static Map<String, String> parseTitleAndArtist(String fileName) {
    // Strip file extension
    String cleanName = fileName.replaceAll(
      RegExp(r'\.(mp3|m4a|wav|flac|aac|ogg|wma)$', caseSensitive: false),
      '',
    );

    // Common pattern: "Artist - Title" or "TrackNo - Artist - Title"
    if (cleanName.contains(' - ')) {
      final parts = cleanName.split(' - ');
      if (parts.length >= 2) {
        return {
          'artist': parts[0].trim(),
          'title': parts.sublist(1).join(' - ').trim(),
        };
      }
    }

    return {
      'artist': 'Google Drive Audio',
      'title': cleanName.trim(),
    };
  }
}
