import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;

  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Call the login API
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      // Token is automatically set in ApiService
      final userData = response['user'];

      _currentUser = User(
        id: userData['id'],
        email: userData['email'],
        username: userData['username'],
        isPremium: userData['isPremium'] ?? false,
      );
      _isAuthenticated = true;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    _setLoading(true);
    _clearError();

    try {
      // Call the register API
      final response = await ApiService.register(
        email: email,
        username: username,
        password: password,
      );

      // Token is automatically set in ApiService
      final userData = response['user'];

      _currentUser = User(
        id: userData['id'],
        email: userData['email'],
        username: userData['username'],
        isPremium: userData['isPremium'] ?? false,
      );
      _isAuthenticated = true;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _currentUser = null;
    ApiService.setAuthToken(null);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

class User {
  final String id;
  final String email;
  final String username;
  final bool isPremium;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.isPremium,
  });
}
