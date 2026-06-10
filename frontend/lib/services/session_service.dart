import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  final String teamName;
  final String userName;
  final String role;

  const UserSession({
    required this.teamName,
    required this.userName,
    required this.role,
  });
}

class SessionService {
  static Future<UserSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final teamName = prefs.getString('teamName');
    final userName = prefs.getString('userName');

    if (teamName == null || userName == null) {
      return null;
    }

    return UserSession(
      teamName: teamName,
      userName: userName,
      role: prefs.getString('role') ?? 'MEMBER',
    );
  }

  static Future<void> save({
    required String teamName,
    required String userName,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teamName', teamName);
    await prefs.setString('userName', userName);
    await prefs.setString('role', role);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
