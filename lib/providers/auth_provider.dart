import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  UserModel? _user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get user => _user;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userStr = prefs.getString(AppConstants.userKey);

    if (token != null && token.isNotEmpty) {
      _isAuthenticated = true;
      if (userStr != null) {
        _user = UserModel.fromJson(jsonDecode(userStr));
      } else {
        await fetchProfile();
      }
    } else {
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<bool> login(String maSV, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(maSV, password);
    
    if (result['success']) {
      _isAuthenticated = true;
      await fetchProfile();
    }
    
    _isLoading = false;
    notifyListeners();
    return result['success'];
  }

  Future<void> fetchProfile() async {
    _user = await _authService.getProfile();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
