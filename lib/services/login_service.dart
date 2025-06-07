import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  static const String baseUrl = 'https://api.ppatq-rf.id/api';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/ustad/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {
        'success': true,
        'data': data['data'], // pastikan response API login menyertakan ID user di sini
      };
    } else {
      return {
        'success': false,
        'message': data['errors']?['Verifikasi']?[0] ?? 'Login gagal',
      };
    }
  }

  static Future<Map<String, dynamic>> fetchDashboardData(int idUser) async {
    final url = Uri.parse('$baseUrl/murroby/uang-saku/$idUser');
    final response = await http.get(url);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': data['data'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengambil data',
      };
    }
  }
}
