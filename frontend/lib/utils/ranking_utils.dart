import '../models/ranking_display_item.dart';
import '../models/ranking_response.dart';

List<RankingDisplayItem> buildRankingDisplayItems(
  List<RankingResponse> responses,
) {
  final items = <RankingDisplayItem>[];
  int rank = 1;
  double? previousScore;

  // 서버가 이미 내림차순 정렬해서 내려주므로, 프론트에서는 rank만 계산한다.
  for (var i = 0; i < responses.length; i++) {
    final score = responses[i].averageScore;
    if (previousScore != null && score == previousScore) {
      items.add(
        RankingDisplayItem(
          teamName: responses[i].teamName,
          averageScore: score,
          rank: rank,
        ),
      );
    } else {
      rank = i + 1;
      previousScore = score;
      items.add(
        RankingDisplayItem(
          teamName: responses[i].teamName,
          averageScore: score,
          rank: rank,
        ),
      );
    }
  }

  return items;
}
