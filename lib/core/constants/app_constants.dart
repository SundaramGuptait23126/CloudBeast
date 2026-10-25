class AppConstants {
  static const String appName = 'CloudBeats';
  static const String appTagline = 'Your Google Drive Music Cloud';

  // Google OAuth Client ID
  static const String googleClientId =
      '824172207-50a0f50eaq3odua5bpp742s55i619hs1.apps.googleusercontent.com';

  // Google OAuth Scopes
  static const List<String> driveScopes = [
    'email',
    'https://www.googleapis.com/auth/drive.readonly',
  ];

  // Supported audio MIME types & extensions
  static const List<String> supportedExtensions = [
    '.mp3',
    '.m4a',
    '.wav',
    '.flac',
    '.aac',
    '.ogg',
    '.wma',
  ];

  static const String driveAudioQuery =
      "mimeType contains 'audio/' and trashed = false";

  // Shared preferences keys
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserEmail = 'user_email';
  static const String prefUserName = 'user_name';
  static const String prefUserPhoto = 'user_photo';
  static const String prefIsDemoMode = 'is_demo_mode';
  static const String prefLastPlayedId = 'last_played_id';
}
