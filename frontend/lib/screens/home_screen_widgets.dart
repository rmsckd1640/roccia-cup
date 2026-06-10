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
  final bool alreadySubmitted;
  final String? scoreErrorText;
  final TextEditingController scoreController;
  final ValueChanged<int?> onSectorChanged;
  final VoidCallback onSubmit;

  const ScoreInputSection({
    super.key,
    required this.selectedSector,
    required this.sectorErrorText,
    required this.alreadySubmitted,
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
              errorText: sectorErrorText ?? (alreadySubmitted ? '중복 제출 불가!' : null),
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
                  item.sector == 99
                      ? '지구력 - 점수: ${item.point}'
                      : '섹터 ${item.sector} - 점수: ${item.point}',
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
