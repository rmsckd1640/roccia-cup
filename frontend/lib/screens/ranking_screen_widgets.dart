import 'package:flutter/material.dart';

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
