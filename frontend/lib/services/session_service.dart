import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  final int id;
  final String teamName;
  final String userName;
  final String role;

  const UserSession({
    required this.id,
    required this.teamName,
    required this.userName,
    required this.role,
  });
}

class SessionService {
  static Future<UserSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    final teamName = prefs.getString('teamName');
    final userName = prefs.getString('userName');

    if (id == null || teamName == null || userName == null) {
      return null;
    }

    return UserSession(
      id: id,
      teamName: teamName,
      userName: userName,
      role: prefs.getString('role') ?? 'MEMBER',
    );
  }

  static Future<void> save({
    required int id,
    required String teamName,
    required String userName,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', id);
    await prefs.setString('teamName', teamName);
    await prefs.setString('userName', userName);
    await prefs.setString('role', role);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
