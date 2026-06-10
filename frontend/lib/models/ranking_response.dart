class RankingResponse {
  final String teamName;
  final double averageScore;

  RankingResponse({
    required this.teamName,
    required this.averageScore,
  });

  factory RankingResponse.fromJson(Map<String, dynamic> json) {
    return RankingResponse(
      teamName: json['teamName'] as String,
      averageScore: (json['averageScore'] as num).toDouble(),
    );
  }
}
