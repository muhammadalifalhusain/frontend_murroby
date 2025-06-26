import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static Future<void> saveMurrobySession({
    required int idUser,
    required String nama,
    String? photo,
    required String accessToken,
    required int expiresIn,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('idUser', idUser);
    await prefs.setString('namaMurroby', nama);
    await prefs.setString('photo', photo ?? '');
    await prefs.setString('accessToken', accessToken);
    await prefs.setInt('expiresIn', expiresIn);
    await prefs.setInt('loginTimestamp', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<int?> getIdUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('idUser');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

    static Future<bool> isUserLoggedIn() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final loginTime = prefs.getInt('loginTimestamp');
      final expiresIn = prefs.getInt('expiresIn');

      if (token == null || loginTime == null || expiresIn == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      final expiredTime = loginTime + (expiresIn * 1000);
      return now < expiredTime;
    }

}
