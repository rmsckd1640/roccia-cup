class ScoreSubmitRequest {
  final String teamName;
  final String userName;
  final int sector;
  final int point;

  ScoreSubmitRequest({
    required this.teamName,
    required this.userName,
    required this.sector,
    required this.point,
  });

  Map<String, dynamic> toJson() {
    return {
      'teamName': teamName,
      'userName': userName,
      'sector': sector,
      'point': point,
    };
  }
}
