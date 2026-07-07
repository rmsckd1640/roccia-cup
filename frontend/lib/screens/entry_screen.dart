import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../models/user_entry_request.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../utils/ui_helpers.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  final TextEditingController _teamController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String _selectedRole = 'MEMBER'; // 기본값: 팀원
  String? _teamErrorText;
  String? _nameErrorText;

  @override
  void dispose() {
    _teamController.dispose();
    _nameController.dispose();
    super.dispose();
  }


  void _enter() async {
    final teamName = _teamController.text.trim();
    final userName = _nameController.text.trim();
    bool loadingShown = false;

    setState(() {
      _teamErrorText = teamName.isEmpty ? '팀명을 입력해주세요' : null;
      _nameErrorText = userName.isEmpty ? '이름을 입력해주세요' : null;
    });

    if (teamName.isEmpty || userName.isEmpty) return;

    final requestModel = UserEntryRequest(
      teamName: teamName,
      userName: userName,
      role: _selectedRole,
    );

    UIHelpers.showLoading(context);
    loadingShown = true;

    try {
      final user = await ApiService.enter(requestModel);

      await SessionService.save(
        id: user.id,
        teamName: user.teamName,
        userName: user.userName,
        role: user.role,
      );

      if (mounted) {
        if (loadingShown) {
          UIHelpers.hideLoading(context);
          loadingShown = false;
        }
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackbar(context, e.toString());
      }
    } finally {
      if (mounted && loadingShown) {
        UIHelpers.hideLoading(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('입장'),
        backgroundColor: const Color(0xCB9850F3),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _teamController,
              decoration: InputDecoration(
                labelText: '팀명',
                errorText: _teamErrorText,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름',
                errorText: _nameErrorText,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('팀원'),
                    value: 'MEMBER',
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('팀장'),
                    value: 'LEADER',
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _enter,
              child: const Text('입장'),
            ),
          ],
        ),
      ),
    );
  }
}
