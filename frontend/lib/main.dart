import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final team = prefs.getString('teamName');
    final name = prefs.getString('userName');

    if (team != null && name != null) {
      try {
        await ApiService.getUserScores(team, name);
        return const HomeScreen();
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          await prefs.clear();
        }
        return const LoginScreen();
      } catch (_) {
        return const LoginScreen();
      }
    } else {
      return const LoginScreen();
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roccia Cup',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Pretendard',
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
