import 'package:dio/dio.dart';
import '../utils/app_constants.dart';
import 'api_client.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  Future<Map<String, dynamic>> login(String maSV, String password) async {
    try {
      final response = await ApiClient.dio.post(
        AppConstants.loginEndpoint,
        data: {
          'maSV': maSV,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['token'];
        
        // Lưu token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.tokenKey, token);
        
        return {'success': true, 'token': token};
      }
      return {'success': false, 'message': 'Lỗi máy chủ'};
    } on DioException catch (e) {
      if (e.response != null && (e.response?.statusCode == 401 || e.response?.statusCode == 403)) {
         return {'success': false, 'message': 'Sai tên đăng nhập hoặc mật khẩu'};
      }
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }

  Future<UserModel?> getProfile() async {
    try {
      final response = await ApiClient.dio.get(AppConstants.profileEndpoint);
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        // Lưu thông tin user local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }
}
