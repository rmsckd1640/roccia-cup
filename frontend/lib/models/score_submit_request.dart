class ScoreSubmitRequest {
  final int userId;
  final int sector;
  final int point;

  ScoreSubmitRequest({
    required this.userId,
    required this.sector,
    required this.point,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'sector': sector,
      'point': point,
    };
  }
}
