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
  String? _role;

  int? _selectedSector;
  String? _scoreErrorText;
  bool _alreadySubmitted = false;
  String? _teamName;
  String? _userName;
  String? _sectorErrorText;
  UserSession? _session;

  int _calculateTotalScore() {
    return scoreList.fold(0, (sum, item) => sum + item.point);
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchUserScores();
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    final session = await SessionService.load();
    if (!mounted) return;
    setState(() {
      _session = session;
      _role = session?.role ?? 'MEMBER';
      _teamName = session?.teamName;
      _userName = session?.userName;
    });
  }


  Future<void> _fetchUserScores() async {
    final teamName = _session?.teamName;
    final userName = _session?.userName;

    if (teamName == null || userName == null) return;

    try {
      final scores = await ApiService.getUserScores(teamName, userName);
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

      _alreadySubmitted = scoreList.any((item) => item.sector == _selectedSector);
    });

    final hasError = _selectedSector == null || _scoreErrorText != null || _alreadySubmitted;
    if (hasError) return;

    final teamName = _session?.teamName;
    final userName = _session?.userName;

    if (teamName == null || userName == null) return;

    final requestModel = ScoreSubmitRequest(
      teamName: teamName,
      userName: userName,
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
        _alreadySubmitted = false;
      });
      if (mounted) UIHelpers.showSuccessSnackbar(context, '점수가 제출되었습니다.');
    } catch (e) {
      if (mounted) UIHelpers.showErrorSnackbar(context, e.toString());
    } finally {
      if (mounted) UIHelpers.hideLoading(context);
    }
  }


  void _deleteScore(int index) async {
    final teamName = _session?.teamName;
    final userName = _session?.userName;
    final sector = scoreList[index].sector;

    if (teamName == null || userName == null) return;

    if (!mounted) return;
    UIHelpers.showLoading(context);

    try {
      await ApiService.deleteScore(teamName, userName, sector);
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
        initialTeamName: _teamName ?? '',
        initialUserName: _userName ?? '',
        initialRole: _role ?? 'MEMBER',
      ),
    );

    if (result == null || !mounted) return;

    final requestModel = UserUpdateRequest(
      teamName: _teamName!,
      userName: _userName!,
      newTeamName: result.teamName,
      newUserName: result.userName,
      newRole: result.role,
    );

    UIHelpers.showLoading(context);

    try {
      await ApiService.updateUser(requestModel);

      await SessionService.save(
        teamName: result.teamName,
        userName: result.userName,
        role: result.role,
      );

      if (!mounted) return;
      setState(() {
        _teamName = result.teamName;
        _userName = result.userName;
        _role = result.role;
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
                      teamName: _teamName,
                      userName: _userName,
                      role: _role,
                      totalScore: _calculateTotalScore(),
                    ),
                    ScoreInputSection(
                      selectedSector: _selectedSector,
                      sectorErrorText: _sectorErrorText,
                      alreadySubmitted: _alreadySubmitted,
                      scoreErrorText: _scoreErrorText,
                      scoreController: _scoreController,
                      onSectorChanged: (value) {
                        setState(() {
                          _selectedSector = value;
                          _alreadySubmitted = false;
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

            HomeFooterActions(
              onEdit: _showEditDialog,
              onRanking: () {
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
            ),
          ],
        )



    );
  }
}
