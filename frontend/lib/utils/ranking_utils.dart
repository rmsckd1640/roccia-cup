import '../models/ranking_display_item.dart';
import '../models/ranking_response.dart';

List<RankingDisplayItem> buildRankingDisplayItems(
  List<RankingResponse> responses,
) {
  final sorted = List<RankingResponse>.from(responses)
    ..sort((a, b) => b.averageScore.compareTo(a.averageScore));

  final items = <RankingDisplayItem>[];
  int rank = 1;
  double? previousScore;

  for (var i = 0; i < sorted.length; i++) {
    final score = sorted[i].averageScore;
    if (previousScore != null && score == previousScore) {
      items.add(
        RankingDisplayItem(
          teamName: sorted[i].teamName,
          averageScore: score,
          rank: rank,
        ),
      );
    } else {
      rank = i + 1;
      previousScore = score;
      items.add(
        RankingDisplayItem(
          teamName: sorted[i].teamName,
          averageScore: score,
          rank: rank,
        ),
      );
    }
  }

  return items;
}
