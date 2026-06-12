import 'package:flutter/material.dart';
import '../models/ranking_response.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../utils/ui_helpers.dart';
import 'ranking_screen_widgets.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final ScrollController _scrollController = ScrollController();
  List<RankingResponse> rankings = [];
  int? _myTeamIndex;
  String? _myTeamName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRankings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchRankings() async {
    final session = await SessionService.load();
    final teamName = session?.teamName ?? '';
    _myTeamName = teamName;

    try {
      final responses = await ApiService.getRankings();

      if (mounted) {
        setState(() {
          rankings = responses;
          _myTeamIndex = responses.indexWhere((team) => team.teamName == _myTeamName);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        UIHelpers.showErrorSnackbar(context, e.toString());
      }
    }
  }

  int _rankAt(int index) {
    final score = rankings[index].averageScore;
    for (var i = index - 1; i >= 0; i--) {
      if (rankings[i].averageScore != score) {
        return i + 2;
      }
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '실시간 팀 랭킹',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xCB9850F3),
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 6,
              radius: const Radius.circular(12),
              interactive: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_myTeamIndex != null && _myTeamIndex! >= 0)
                      RankingTeamCard(
                        teamName: rankings[_myTeamIndex!].teamName,
                        averageScore: rankings[_myTeamIndex!].averageScore,
                        rank: _rankAt(_myTeamIndex!),
                        highlight: true,
                        isMyTeam: true,
                        label: '내 팀 등수',
                      ),
                    if (_myTeamIndex != null && _myTeamIndex! >= 0)
                      const RankingSectionHeader(),
                    for (var i = 0; i < rankings.length; i++)
                      RankingTeamCard(
                        teamName: rankings[i].teamName,
                        averageScore: rankings[i].averageScore,
                        rank: _rankAt(i),
                        highlight: false,
                        isMyTeam: rankings[i].teamName == _myTeamName,
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
