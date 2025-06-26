import 'dart:convert';
import '../models/murroby_model.dart';
import '../utils/api_helper.dart';

class LoginService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await ApiHelper.post('/ustad/login', body: {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final murroby = Murroby.fromJson(data['data']);
        return {
          'success': true,
          'data': murroby,
        };
      } else {
        return {
          'success': false,
          'message': data['errors']?['Verifikasi']?[0] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat login: ${e.toString()}',
      };
    }
  }
}
