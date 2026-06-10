import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../utils/ui_helpers.dart';
import '../utils/ranking_utils.dart';
import '../models/ranking_display_item.dart';
import 'ranking_screen_widgets.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final ScrollController _scrollController = ScrollController();
  List<RankingDisplayItem> rankings = [];
  RankingDisplayItem? _myTeamData;
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
      final rankingResponses = await ApiService.getRankings();
      final displayItems = buildRankingDisplayItems(rankingResponses);

      if (mounted) {
        setState(() {
          rankings = displayItems;
          _myTeamData = displayItems.firstWhere(
            (team) => team.teamName == _myTeamName,
            orElse: () => const RankingDisplayItem(
              teamName: '',
              averageScore: 0.0,
              rank: null,
            ),
          );
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
                    if (_myTeamData != null)
                      RankingTeamCard(
                        item: _myTeamData!,
                        highlight: true,
                        isMyTeam: true,
                        label: '내 팀 등수',
                      ),
                    if (_myTeamData != null)
                      const RankingSectionHeader(),
                    ...rankings.map(
                      (team) => RankingTeamCard(
                        item: team,
                        highlight: false,
                        isMyTeam: team.teamName == _myTeamName,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
