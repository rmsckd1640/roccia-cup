class UserUpdateRequest {
  final String teamName;
  final String userName;
  final String newTeamName;
  final String newUserName;
  final String? newRole;

  UserUpdateRequest({
    required this.teamName,
    required this.userName,
    required this.newTeamName,
    required this.newUserName,
    this.newRole,
  });

  Map<String, dynamic> toJson() {
    return {
      'teamName': teamName,
      'userName': userName,
      'newTeamName': newTeamName,
      'newUserName': newUserName,
      if (newRole != null) 'newRole': newRole,
    };
  }
}
