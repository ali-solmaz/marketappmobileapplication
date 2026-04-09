import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
    print('prefste kaydedilen user id$id');
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}
