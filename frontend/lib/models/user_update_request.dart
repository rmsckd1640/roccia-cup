class UserUpdateRequest {
  final String newTeamName;
  final String newUserName;
  final String? newRole;

  UserUpdateRequest({
    required this.newTeamName,
    required this.newUserName,
    this.newRole,
  });

  Map<String, dynamic> toJson() {
    return {
      'newTeamName': newTeamName,
      'newUserName': newUserName,
      if (newRole != null) 'newRole': newRole,
    };
  }
}
