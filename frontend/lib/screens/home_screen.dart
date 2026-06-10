import 'package:flutter/material.dart';
import '../models/score_response.dart';
import '../models/score_submit_request.dart';
import '../models/user_update_request.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../utils/ui_helpers.dart';
import 'ranking_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _enduranceController = TextEditingController();

  List<ScoreResponse> scoreList = [];
  String? _role;

  int? _selectedSector;
  String? _scoreErrorText;
  String? _enduranceErrorText;
  bool _alreadySubmitted = false;
  String? _teamName;
  String? _userName;
  String? _sectorErrorText;

  int _calculateTotalScore() {
    return scoreList
        .where((item) => item.sector != 99) // 지구력 제외
        .fold(0, (sum, item) => sum + item.point);
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchUserScores();
  }

  Future<void> _loadUserInfo() async {
    final session = await SessionService.load();
    if (!mounted) return;
    setState(() {
      _role = session?.role ?? 'MEMBER';
      _teamName = session?.teamName;
      _userName = session?.userName;
    });
  }


  Future<void> _fetchUserScores() async {
    final session = await SessionService.load();
    final teamName = session?.teamName;
    final userName = session?.userName;

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

    final session = await SessionService.load();
    final teamName = session?.teamName;
    final userName = session?.userName;

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


  void _submitEnduranceScore() async {
    final enduranceText = _enduranceController.text.trim();
    final parsedEndurance = int.tryParse(enduranceText);

    final session = await SessionService.load();
    final teamName = session?.teamName;
    final userName = session?.userName;

    if (teamName == null || userName == null) return;

    final alreadyExists = scoreList.any((item) => item.sector == 99);

    setState(() {
      if (enduranceText.isEmpty) {
        _enduranceErrorText = '지구력 점수를 입력해주세요';
      } else if (parsedEndurance == null) {
        _enduranceErrorText = '숫자를 입력해주세요';
      } else if (alreadyExists) {
        _enduranceErrorText = '중복 제출 불가!';
      } else {
        _enduranceErrorText = null;
      }
    });

    if (_enduranceErrorText != null) return;

    final requestModel = ScoreSubmitRequest(
      teamName: teamName,
      userName: userName,
      sector: 99,
      point: parsedEndurance!,
    );

    if (!mounted) return;
    UIHelpers.showLoading(context);

    try {
      await ApiService.submitScore(requestModel);
      await _fetchUserScores();
      if (!mounted) return;
      _enduranceController.clear();
      setState(() {
        _enduranceErrorText = null;
      });
      if (mounted) UIHelpers.showSuccessSnackbar(context, '지구력 점수가 제출되었습니다.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _enduranceErrorText = e.toString();
      });
    } finally {
      if (mounted) UIHelpers.hideLoading(context);
    }
  }



  void _deleteScore(int index) async {
    final session = await SessionService.load();
    final teamName = session?.teamName;
    final userName = session?.userName;
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

  void _showEditDialog() {
    final TextEditingController newTeamController = TextEditingController();
    final TextEditingController newNameController = TextEditingController();
    String? teamNameError;
    String? userNameError;
    String selectedRole = _role ?? 'MEMBER'; // 현재 역할 기본값

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('정보 수정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newTeamController,
                    decoration: InputDecoration(
                      labelText: '새 팀명',
                      errorText: teamNameError,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: newNameController,
                    decoration: InputDecoration(
                      labelText: '새 이름',
                      errorText: userNameError,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'LEADER', child: Text('팀장')),
                      DropdownMenuItem(value: 'MEMBER', child: Text('팀원')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRole = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: '역할 선택'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () async {
                    final newTeam = newTeamController.text.trim();
                    final newName = newNameController.text.trim();

                    setState(() {
                      teamNameError = newTeam.isEmpty ? '팀명을 입력해주세요' : null;
                      userNameError = newName.isEmpty ? '이름을 입력해주세요' : null;
                    });

                    if (newTeam.isEmpty || newName.isEmpty) return;

                    final requestModel = UserUpdateRequest(
                      teamName: _teamName!,
                      userName: _userName!,
                      newTeamName: newTeam,
                      newUserName: newName,
                      newRole: selectedRole,
                    );

                    UIHelpers.showLoading(context);

                    try {
                      await ApiService.updateUser(requestModel);

                      await SessionService.save(
                        teamName: newTeam,
                        userName: newName,
                        role: selectedRole,
                      );

                      if (context.mounted) Navigator.of(context).pop();

                      if (!mounted) return;
                      setState(() { // 상위 위젯의 상태 업데이트
                        _teamName = newTeam;
                        _userName = newName;
                        _role = selectedRole;
                      });

                      _fetchUserScores();
                      if (context.mounted) UIHelpers.showSuccessSnackbar(context, '정보가 수정되었습니다.');
                    } catch (e) {
                      // 역할만 수정하는 경우 등 특수 케이스 처리 방식 단순화
                      if (newTeam == _teamName && newName == _userName) {
                          final session = await SessionService.load();
                          if (session == null) return;
                          await SessionService.save(
                            teamName: session.teamName,
                            userName: session.userName,
                            role: selectedRole,
                          );

                          if (context.mounted) Navigator.of(context).pop();

                          if (!mounted) return;
                          setState(() {
                            _role = selectedRole;
                          });
                          if (context.mounted) UIHelpers.showSuccessSnackbar(context, '역할이 수정되었습니다.');
                      } else {
                         if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('수정 실패'),
                              content: Text(e.toString()),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    } finally {
                       if (context.mounted) UIHelpers.hideLoading(context);
                    }
                  },
                  child: const Text('저장', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
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
                    // 상단 유저 정보 박스
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: '[팀명]   ',
                              style: const TextStyle(fontSize: 16), // 기본 스타일
                              children: [
                                TextSpan(
                                  text: '$_teamName',
                                  style: const TextStyle(fontWeight: FontWeight.bold), // 사용자 정보만 굵게
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              text: '[이름]   ',
                              style: const TextStyle(fontSize: 16),
                              children: [
                                TextSpan(
                                  text: '$_userName',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              text: '[역할]   ',
                              style: const TextStyle(fontSize: 16),
                              children: [
                                TextSpan(
                                  text: _role == 'LEADER' ? '팀장' : '팀원',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              text: '[개인 총점]   ',
                              style: const TextStyle(fontSize: 16),
                              children: [
                                TextSpan(
                                  text: '${_calculateTotalScore()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),


                    // 섹터 + 점수 입력
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedSector,
                            items: List.generate(6, (i) => i + 1).map((num) {
                              return DropdownMenuItem(
                                value: num,
                                child: Text('섹터 $num'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSector = value;
                                _alreadySubmitted = false;
                                _sectorErrorText = null;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: '섹터 번호',
                              errorText: _sectorErrorText ?? (_alreadySubmitted ? '중복 제출 불가!' : null),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _scoreController,
                            decoration: InputDecoration(
                              labelText: '점수',
                              errorText: _scoreErrorText,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _submitScore,
                          child: const Text('제출'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Text('제출 목록', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: scoreList.length,
                      itemBuilder: (context, index) {
                        final item = scoreList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              item.sector == 99
                                  ? '지구력 - 점수: ${item.point}'
                                  : '섹터 ${item.sector} - 점수: ${item.point}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteScore(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ✅ 고정된 하단 버튼
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
