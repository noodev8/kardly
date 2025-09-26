import 'package:flutter/material.dart';

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
      // TODO: Implement actual authentication
      await Future.delayed(const Duration(seconds: 2));
      
      _currentUser = User(
        id: '1',
        email: email,
        username: 'KpopFan2024',
        isPremium: false,
      );
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Implement actual registration
      await Future.delayed(const Duration(seconds: 2));
      
      _currentUser = User(
        id: '1',
        email: email,
        username: username,
        isPremium: false,
      );
      _isAuthenticated = true;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _currentUser = null;
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
