import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/user_profile.dart';

class _TokenAuthClient extends http.BaseClient {
  final http.Client _inner;
  final String _token;

  _TokenAuthClient(this._inner, this._token);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _inner.send(request);
  }
}

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
  String? _cachedToken;

  /// Check if previously signed in (silent sign-in)
  Future<UserProfile?> signInSilently() async {
    try {
      _currentUser = await _googleSignIn.signInSilently(suppressErrors: true);
      if (_currentUser != null) {
        final profile = _buildProfile(_currentUser!);
        final token = await getAccessToken();
        await saveSession(profile, token);
        return profile;
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
        final profile = _buildProfile(_currentUser!);
        final token = await getAccessToken();
        await saveSession(profile, token);
        return profile;
      }
    } catch (e) {
      debugPrint('Interactive Google sign in error: $e');
      rethrow;
    }
    return null;
  }

  /// Persist session in SharedPreferences
  Future<void> saveSession(UserProfile profile, String? token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', profile.id);
    await prefs.setString('user_name', profile.name);
    await prefs.setString('user_email', profile.email);
    if (profile.photoUrl != null) {
      await prefs.setString('user_photo', profile.photoUrl!);
    } else {
      await prefs.remove('user_photo');
    }
    if (token != null && token.isNotEmpty) {
      await prefs.setString('access_token', token);
      await prefs.setInt('token_saved_at', DateTime.now().millisecondsSinceEpoch);
    }
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);
    await prefs.setBool(AppConstants.prefIsDemoMode, false);
  }

  /// Restore user profile and token from persistent storage on page refresh
  Future<UserProfile?> loadSavedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;
      final isDemo = prefs.getBool(AppConstants.prefIsDemoMode) ?? false;
      if (isDemo) return UserProfile.demo();
      if (!isLoggedIn) return null;

      final id = prefs.getString('user_id');
      final email = prefs.getString('user_email');
      final name = prefs.getString('user_name') ?? 'Google User';
      final photo = prefs.getString('user_photo');
      _cachedToken = prefs.getString('access_token');

      if (id != null && email != null) {
        return UserProfile(
          id: id,
          name: name,
          email: email,
          photoUrl: photo,
          isDemo: false,
        );
      }
    } catch (e) {
      debugPrint('Error loading saved profile: $e');
    }
    return null;
  }

  /// Clear persistent session on logout
  Future<void> clearSavedSession() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo');
    await prefs.remove('access_token');
    await prefs.remove('token_saved_at');
    await prefs.remove(AppConstants.prefIsLoggedIn);
    await prefs.remove(AppConstants.prefIsDemoMode);
  }

  /// Obtain an authenticated HTTP client, with fallback to cached OAuth token on refresh
  Future<http.Client?> getAuthenticatedClient() async {
    // 1. If googleSignIn is already active
    try {
      final client = await _googleSignIn.authenticatedClient();
      if (client != null) return client;
    } catch (_) {}

    // 2. Try silent sign-in
    if (_currentUser == null) {
      try {
        _currentUser = await _googleSignIn.signInSilently(suppressErrors: true);
        if (_currentUser != null) {
          final client = await _googleSignIn.authenticatedClient();
          if (client != null) return client;
        }
      } catch (_) {}
    }

    // 3. Fallback to cached bearer token from SharedPreferences
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      return _TokenAuthClient(http.Client(), token);
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
    await clearSavedSession();
  }

  /// Get Bearer authorization headers for calling Drive API or streaming media
  Future<Map<String, String>> getAuthHeaders() async {
    if (_currentUser != null) {
      try {
        final headers = await _currentUser!.authHeaders;
        if (headers.isNotEmpty) return headers;
      } catch (_) {}
    }

    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }

    return {};
  }

  /// Obtain fresh access token string with storage fallback
  Future<String?> getAccessToken() async {
    if (_currentUser != null) {
      try {
        final auth = await _currentUser!.authentication;
        if (auth.accessToken != null && auth.accessToken!.isNotEmpty) {
          _cachedToken = auth.accessToken;
          return auth.accessToken;
        }
      } catch (_) {}
    }

    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }

    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('access_token');
    return _cachedToken;
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
