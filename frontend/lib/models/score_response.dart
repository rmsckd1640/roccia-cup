class ScoreResponse {
  final int id;
  final int sector;
  final int point;
  final String submittedAt;

  ScoreResponse({
    required this.id,
    required this.sector,
    required this.point,
    required this.submittedAt,
  });

  factory ScoreResponse.fromJson(Map<String, dynamic> json) {
    return ScoreResponse(
      id: json['id'] as int,
      sector: json['sector'] as int,
      point: json['point'] as int,
      submittedAt: json['submittedAt'] as String,
    );
  }
}
