import 'package:flutter/material.dart';

import '../models/score_response.dart';

class UserInfoCard extends StatelessWidget {
  final String? teamName;
  final String? userName;
  final String? role;
  final int totalScore;

  const UserInfoCard({
    super.key,
    required this.teamName,
    required this.userName,
    required this.role,
    required this.totalScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: '[팀명]   ',
              style: const TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: '$teamName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: '[이름]   ',
              style: const TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: '$userName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: '[역할]   ',
              style: const TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: role == 'LEADER' ? '팀장' : '팀원',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: '[개인 총점]   ',
              style: const TextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: '$totalScore',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreInputSection extends StatelessWidget {
  final int? selectedSector;
  final String? sectorErrorText;
  final String? scoreErrorText;
  final TextEditingController scoreController;
  final ValueChanged<int?> onSectorChanged;
  final VoidCallback onSubmit;

  const ScoreInputSection({
    super.key,
    required this.selectedSector,
    required this.sectorErrorText,
    required this.scoreErrorText,
    required this.scoreController,
    required this.onSectorChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: selectedSector,
            items: List.generate(6, (i) => i + 1)
                .map((sectorNumber) {
                  return DropdownMenuItem(
                    value: sectorNumber,
                    child: Text('섹터 $sectorNumber'),
                  );
                })
                .toList(),
            onChanged: onSectorChanged,
            decoration: InputDecoration(
              labelText: '섹터 번호',
              errorText: sectorErrorText,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: scoreController,
            decoration: InputDecoration(
              labelText: '점수',
              errorText: scoreErrorText,
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onSubmit,
          child: const Text('제출'),
        ),
      ],
    );
  }
}

class ScoreListSection extends StatelessWidget {
  final List<ScoreResponse> scoreList;
  final ValueChanged<int> onDelete;

  const ScoreListSection({
    super.key,
    required this.scoreList,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('제출 목록', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: scoreList.length,
          itemBuilder: (context, index) {
            final item = scoreList[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    '섹터 ${item.sector} - 점수: ${item.point}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                  onPressed: () => onDelete(index),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class HomeFooterActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onRanking;

  const HomeFooterActions({
    super.key,
    required this.onEdit,
    required this.onRanking,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: onEdit,
            child: const Text('정보 수정'),
          ),
          ElevatedButton(
            onPressed: onRanking,
            child: const Text('실시간 팀 랭킹'),
          ),
        ],
      ),
    );
  }
}

class EditUserDialogResult {
  final String teamName;
  final String userName;
  final String role;

  const EditUserDialogResult({
    required this.teamName,
    required this.userName,
    required this.role,
  });
}

class EditUserDialog extends StatefulWidget {
  final String initialTeamName;
  final String initialUserName;
  final String initialRole;

  const EditUserDialog({
    super.key,
    required this.initialTeamName,
    required this.initialUserName,
    required this.initialRole,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late final TextEditingController _teamController;
  late final TextEditingController _nameController;
  late String _selectedRole;
  String? _teamNameError;
  String? _userNameError;

  @override
  void initState() {
    super.initState();
    _teamController = TextEditingController(text: widget.initialTeamName);
    _nameController = TextEditingController(text: widget.initialUserName);
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _teamController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final newTeam = _teamController.text.trim();
    final newName = _nameController.text.trim();

    setState(() {
      _teamNameError = newTeam.isEmpty ? '팀명을 입력해주세요' : null;
      _userNameError = newName.isEmpty ? '이름을 입력해주세요' : null;
    });

    if (newTeam.isEmpty || newName.isEmpty) return;

    Navigator.of(context).pop(
      EditUserDialogResult(
        teamName: newTeam,
        userName: newName,
        role: _selectedRole,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('정보 수정'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _teamController,
            decoration: InputDecoration(
              labelText: '새 팀명',
              errorText: _teamNameError,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '새 이름',
              errorText: _userNameError,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            items: const [
              DropdownMenuItem(value: 'LEADER', child: Text('팀장')),
              DropdownMenuItem(value: 'MEMBER', child: Text('팀원')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRole = value;
                });
              }
            },
            decoration: const InputDecoration(labelText: '역할 선택'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('저장', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
