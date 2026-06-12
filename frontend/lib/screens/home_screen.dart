import 'package:flutter/material.dart';
import '../models/score_response.dart';
import '../models/score_submit_request.dart';
import '../models/user_update_request.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../utils/ui_helpers.dart';
import 'home_screen_widgets.dart';
import 'ranking_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _scoreController = TextEditingController();

  List<ScoreResponse> scoreList = [];

  int? _selectedSector;
  String? _scoreErrorText;
  String? _sectorErrorText;
  UserSession? _session;

  int _calculateTotalScore() {
    return scoreList.fold(0, (sum, item) => sum + item.point);
  }

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    final session = await SessionService.load();
    if (!mounted) return;
    setState(() {
      _session = session;
    });
    await _fetchUserScores();
  }


  Future<void> _fetchUserScores() async {
    final userId = _session?.id;

    if (userId == null) return;

    try {
      final scores = await ApiService.getUserScores(userId);
      if (!mounted) return;
      setState(() {
        scoreList = scores;
      });
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackbar(context, e.toString());
      }
    }
  }

  void _submitScore() async {
    final scoreText = _scoreController.text.trim();
    final parsedScore = int.tryParse(scoreText);

    setState(() {
      if (_selectedSector == null) {
        _sectorErrorText = '섹터를 선택해주세요';
      } else {
        _sectorErrorText = null;
      }

      if (scoreText.isEmpty) {
        _scoreErrorText = '점수를 입력해주세요';
      } else if (parsedScore == null) {
        _scoreErrorText = '숫자를 입력해주세요';
      } else {
        _scoreErrorText = null;
      }
    });

    final hasError = _selectedSector == null || _scoreErrorText != null;
    if (hasError) return;

    final userId = _session?.id;

    if (userId == null) return;

    final requestModel = ScoreSubmitRequest(
      userId: userId,
      sector: _selectedSector!,
      point: parsedScore!,
    );

    if (!mounted) return;
    UIHelpers.showLoading(context);

    try {
      await ApiService.submitScore(requestModel);
      await _fetchUserScores();
      if (!mounted) return;
      _scoreController.clear();
      setState(() {
        _selectedSector = null;
      });
      if (mounted) UIHelpers.showSuccessSnackbar(context, '점수가 제출되었습니다.');
    } catch (e) {
      if (mounted) UIHelpers.showErrorSnackbar(context, e.toString());
    } finally {
      if (mounted) UIHelpers.hideLoading(context);
    }
  }


  void _deleteScore(int index) async {
    final scoreId = scoreList[index].id;

    if (!mounted) return;
    UIHelpers.showLoading(context);

    try {
      await ApiService.deleteScore(scoreId);
      if (!mounted) return;
      setState(() {
        scoreList.removeAt(index);
      });
      if (mounted) UIHelpers.showSuccessSnackbar(context, '점수가 삭제되었습니다.');
    } catch (e) {
      if (mounted) UIHelpers.showErrorSnackbar(context, e.toString());
    } finally {
      if (mounted) UIHelpers.hideLoading(context);
    }
  }

  Future<void> _showEditDialog() async {
    final result = await showDialog<EditUserDialogResult>(
      context: context,
      builder: (_) => EditUserDialog(
        initialTeamName: _session?.teamName ?? '',
        initialUserName: _session?.userName ?? '',
        initialRole: _session?.role ?? 'MEMBER',
      ),
    );

    if (result == null || !mounted) return;
    final session = _session;
    if (session == null) return;

    final requestModel = UserUpdateRequest(
      newTeamName: result.teamName,
      newUserName: result.userName,
      newRole: result.role,
    );

    UIHelpers.showLoading(context);

    try {
      final user = await ApiService.updateUser(session.id, requestModel);

      await SessionService.save(
        id: user.id,
        teamName: user.teamName,
        userName: user.userName,
        role: user.role,
      );

      if (!mounted) return;
      setState(() {
        _session = UserSession(
          id: user.id,
          teamName: user.teamName,
          userName: user.userName,
          role: user.role,
        );
      });

      await _fetchUserScores();
      if (mounted) UIHelpers.showSuccessSnackbar(context, '정보가 수정되었습니다.');
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackbar(context, e.toString());
      }
    } finally {
      if (mounted) UIHelpers.hideLoading(context);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Score',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xCB9850F3),
          elevation: 4,
        ),

        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserInfoCard(
                      teamName: _session?.teamName,
                      userName: _session?.userName,
                      role: _session?.role,
                      totalScore: _calculateTotalScore(),
                    ),
                    ScoreInputSection(
                      selectedSector: _selectedSector,
                      sectorErrorText: _sectorErrorText,
                      scoreErrorText: _scoreErrorText,
                      scoreController: _scoreController,
                      onSectorChanged: (value) {
                        setState(() {
                          _selectedSector = value;
                          _sectorErrorText = null;
                        });
                      },
                      onSubmit: _submitScore,
                    ),

                    const SizedBox(height: 24),
                    ScoreListSection(
                      scoreList: scoreList,
                      onDelete: _deleteScore,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _showEditDialog,
                    child: const Text('정보 수정'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const RankingScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: const Text('실시간 팀 랭킹'),
                  ),
                ],
              ),
            ),
          ],
        )



    );
  }
}
