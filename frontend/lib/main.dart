import 'package:flutter/material.dart';
import 'screens/entry_screen.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<Widget> _initialScreenFuture;

  @override
  void initState() {
    super.initState();
    _initialScreenFuture = _getInitialScreen();
  }

  Future<Widget> _getInitialScreen() async {
    final session = await SessionService.load();

    if (session != null) {
      try {
        final scores = await ApiService.getUserScores(session.id);
        return HomeScreen(initialScores: scores);
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          await SessionService.clear();
        }
        return const EntryScreen();
      } catch (_) {
        return const EntryScreen();
      }
    }
    return const EntryScreen();
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
        future: _initialScreenFuture,
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
