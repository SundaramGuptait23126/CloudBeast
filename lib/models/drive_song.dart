import '../core/utils/formatters.dart';

class DriveSong {
  final String id;
  final String name;
  final String title;
  final String artist;
  final String album;
  final Duration? duration;
  final int? size;
  final String mimeType;
  final String? webContentLink;
  final String? streamUrl;
  final String folderId;
  final String folderName;
  final bool isFavorite;
  final String? localFilePath;

  DriveSong({
    required this.id,
    required this.name,
    String? title,
    String? artist,
    this.album = 'Google Drive',
    this.duration,
    this.size,
    required this.mimeType,
    this.webContentLink,
    this.streamUrl,
    this.folderId = 'root',
    this.folderName = 'Main Drive',
    this.isFavorite = false,
    this.localFilePath,
  })  : title = title ?? Formatters.parseTitleAndArtist(name)['title']!,
        artist = artist ?? Formatters.parseTitleAndArtist(name)['artist']!;

  bool get isCached => localFilePath != null && localFilePath!.isNotEmpty;

  String get fileExtension {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toUpperCase();
    }
    return 'AUDIO';
  }

  DriveSong copyWith({
    String? id,
    String? name,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    int? size,
    String? mimeType,
    String? webContentLink,
    String? streamUrl,
    String? folderId,
    String? folderName,
    bool? isFavorite,
    String? localFilePath,
  }) {
    return DriveSong(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      webContentLink: webContentLink ?? this.webContentLink,
      streamUrl: streamUrl ?? this.streamUrl,
      folderId: folderId ?? this.folderId,
      folderName: folderName ?? this.folderName,
      isFavorite: isFavorite ?? this.isFavorite,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'artist': artist,
        'album': album,
        'durationMs': duration?.inMilliseconds,
        'size': size,
        'mimeType': mimeType,
        'webContentLink': webContentLink,
        'streamUrl': streamUrl,
        'folderId': folderId,
        'folderName': folderName,
        'isFavorite': isFavorite,
        'localFilePath': localFilePath,
      };

  factory DriveSong.fromJson(Map<String, dynamic> json) => DriveSong(
        id: json['id'] as String,
        name: json['name'] as String,
        title: json['title'] as String?,
        artist: json['artist'] as String?,
        album: (json['album'] as String?) ?? 'Google Drive',
        duration: json['durationMs'] != null
            ? Duration(milliseconds: json['durationMs'] as int)
            : null,
        size: json['size'] as int?,
        mimeType: json['mimeType'] as String,
        webContentLink: json['webContentLink'] as String?,
        streamUrl: json['streamUrl'] as String?,
        folderId: (json['folderId'] as String?) ?? 'root',
        folderName: (json['folderName'] as String?) ?? 'Main Drive',
        isFavorite: (json['isFavorite'] as bool?) ?? false,
        localFilePath: json['localFilePath'] as String?,
      );
}
