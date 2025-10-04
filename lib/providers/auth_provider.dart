import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _init();
  }

  // Initialize auth state
  void _init() async {
    _setLoading(true);

    try {
      UserModel? user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      UserModel? user = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );

      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _handleAuthError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _clearError();

      UserModel? user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _handleAuthError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error signing out';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _handleAuthError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user data
  Future<bool> updateUserData(UserModel userModel) async {
    try {
      _setLoading(true);
      await _authService.updateUserData(userModel);
      _currentUser = userModel;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating profile';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (loading) {
      _status = AuthStatus.loading;
    }
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _handleAuthError(dynamic e) {
    String errorCode = e.toString();

    if (errorCode.contains('user-not-found')) {
      _errorMessage = 'No user found with this email address';
    } else if (errorCode.contains('wrong-password')) {
      _errorMessage = 'Incorrect password';
    } else if (errorCode.contains('email-already-in-use')) {
      _errorMessage = 'An account with this email already exists';
    } else if (errorCode.contains('weak-password')) {
      _errorMessage = 'Password is too weak';
    } else if (errorCode.contains('invalid-email')) {
      _errorMessage = 'Invalid email address';
    } else if (errorCode.contains('user-disabled')) {
      _errorMessage = 'This account has been disabled';
    } else if (errorCode.contains('too-many-requests')) {
      _errorMessage = 'Too many attempts. Please try again later';
    } else {
      _errorMessage = 'An authentication error occurred';
    }
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
