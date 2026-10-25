import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_profile.dart';
import '../services/google_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final GoogleAuthService _authService = GoogleAuthService();

  UserProfile? _user;
  bool _isLoading = true;
  bool _isDemoMode = false;
  String? _errorMessage;

  UserProfile? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isDemoMode => _isDemoMode;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    initAuth();
  }

  /// Initialize auth from persistent storage or silent sign in
  Future<void> initAuth() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isDemo = prefs.getBool(AppConstants.prefIsDemoMode) ?? false;

      if (isDemo) {
        _isDemoMode = true;
        _user = UserProfile.demo();
      } else {
        final profile = await _authService.signInSilently();
        if (profile != null) {
          _user = profile;
        }
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Interactive Sign in with Google Account
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _authService.signIn();
      if (profile != null) {
        _user = profile;
        _isDemoMode = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.prefIsLoggedIn, true);
        await prefs.setBool(AppConstants.prefIsDemoMode, false);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: $e';
      debugPrint(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Enable Demo Mode for immediate preview without Google Cloud Console setup
  Future<void> enableDemoMode() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _isDemoMode = true;
    _user = UserProfile.demo();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);
    await prefs.setBool(AppConstants.prefIsDemoMode, true);

    _isLoading = false;
    notifyListeners();
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    if (!_isDemoMode) {
      await _authService.signOut();
    }

    _user = null;
    _isDemoMode = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefIsLoggedIn);
    await prefs.remove(AppConstants.prefIsDemoMode);

    _isLoading = false;
    notifyListeners();
  }
}
