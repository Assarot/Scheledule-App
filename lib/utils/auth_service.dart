import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entity/user.dart';
import '../../domain/repository/auth_repository.dart';

class AuthService extends ChangeNotifier {
  final AuthRepository repository;

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  AuthService({required this.repository}) {
    _initialize();
  }

  Future<void> _initialize() async {
    // No mostrar loading durante la inicialización para no afectar la UI
    _isAuthenticated = await repository.isAuthenticated();
    if (_isAuthenticated) {
      _currentUser = await repository.getCurrentUser();
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(
    String username,
    String password,
    bool rememberMe,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await repository.login(username, password, rememberMe);

    if (result['success'] == true) {
      _currentUser = result['user'] as User?;
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<void> logout() async {
    await repository.logout();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<String?> refreshAccessToken() async {
    return await repository.refreshAccessToken();
  }

  bool hasRole(String role) {
    return _currentUser?.hasRole(role) ?? false;
  }

  bool get isAdmin => hasRole('ADMIN');
}
