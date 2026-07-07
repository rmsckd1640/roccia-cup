class UserEntryRequest {
  final String teamName;
  final String userName;
  final String? role;

  UserEntryRequest({
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
