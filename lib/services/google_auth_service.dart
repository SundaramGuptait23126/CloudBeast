import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/constants/app_constants.dart';
import '../models/user_profile.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? AppConstants.googleClientId : null,
    serverClientId: kIsWeb ? null : AppConstants.googleClientId,
    scopes: AppConstants.driveScopes,
  );

  GoogleSignIn get googleSignIn => _googleSignIn;

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Check if previously signed in
  Future<UserProfile?> signInSilently() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        return _buildProfile(_currentUser!);
      }
    } catch (e) {
      debugPrint('Silent sign in failed: $e');
    }
    return null;
  }

  /// Interactive Sign-In with Google Account
  Future<UserProfile?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        return _buildProfile(_currentUser!);
      }
    } catch (e) {
      debugPrint('Interactive Google sign in error: $e');
      rethrow;
    }
    return null;
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Get Bearer authorization headers for calling Drive API or streaming media
  Future<Map<String, String>> getAuthHeaders() async {
    if (_currentUser == null) {
      return {};
    }
    return await _currentUser!.authHeaders;
  }

  /// Obtain fresh access token string
  Future<String?> getAccessToken() async {
    if (_currentUser == null) return null;
    final auth = await _currentUser!.authentication;
    return auth.accessToken;
  }

  /// Convert GoogleSignInAccount to UserProfile
  UserProfile _buildProfile(GoogleSignInAccount account) {
    return UserProfile(
      id: account.id,
      name: account.displayName ?? 'Google User',
      email: account.email,
      photoUrl: account.photoUrl,
      isDemo: false,
    );
  }
}
