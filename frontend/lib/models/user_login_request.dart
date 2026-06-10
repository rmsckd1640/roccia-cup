class UserLoginRequest {
  final String teamName;
  final String userName;
  final String? role;

  UserLoginRequest({
    required this.teamName,
    required this.userName,
    this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'teamName': teamName,
      'userName': userName,
      if (role != null) 'role': role,
    };
  }
}
