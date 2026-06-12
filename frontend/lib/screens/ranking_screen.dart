import 'package:flutter/material.dart';
import '../models/ranking_response.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../utils/ui_helpers.dart';

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

Color? getMedalBackgroundColorByRank(int rank) {
  switch (rank) {
    case 1:
      return const Color(0xFFFFF8DC);
    case 2:
      return const Color(0xFFF5F5F5);
    case 3:
      return const Color(0xFFFBE4D2);
    default:
      return Colors.white;
  }
}

Color? getMedalBorderColorByRank(int rank) {
  switch (rank) {
    case 1:
      return const Color(0xFFFFD700);
    case 2:
      return const Color(0xFFC0C0C0);
    case 3:
      return const Color(0xFFCD7F32);
    default:
      return Colors.transparent;
  }
}

class RankingSectionHeader extends StatelessWidget {
  const RankingSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(
        '전체 등수',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

class RankingTeamCard extends StatelessWidget {
  final String teamName;
  final double averageScore;
  final int rank;
  final bool highlight;
  final String? label;
  final bool isMyTeam;

  const RankingTeamCard({
    super.key,
    required this.teamName,
    required this.averageScore,
    required this.rank,
    required this.highlight,
    required this.isMyTeam,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        highlight ? Colors.deepPurple[50] : getMedalBackgroundColorByRank(rank);
    final borderColor = getMedalBorderColorByRank(rank);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              label!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        Card(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor!, width: 2),
          ),
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Text(
              '$rank등',
              style: TextStyle(
                fontSize: 18,
                fontWeight: isMyTeam ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            title: Text(
              teamName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMyTeam ? Colors.deepPurple : Colors.black,
              ),
            ),
            trailing: Text(
              '팀 평균 점수: ${averageScore.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isMyTeam ? Colors.deepPurple : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
