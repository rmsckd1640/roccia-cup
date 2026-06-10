class UserResponse {
  final int id;
  final String teamName;
  final String userName;
  final String role;

  UserResponse({
    required this.id,
    required this.teamName,
    required this.userName,
    required this.role,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as int,
      teamName: json['teamName'] as String,
      userName: json['userName'] as String,
      role: json['role'] as String,
    );
  }
}
