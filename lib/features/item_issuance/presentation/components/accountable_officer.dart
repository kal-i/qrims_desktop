import 'package:flutter/material.dart';

class AccountableOfficerCard extends StatelessWidget {
  final Map<String, dynamic> officer;
  final bool isDragging;

  const AccountableOfficerCard({
    super.key,
    required this.officer,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final officerInfo = officer['officer'] as Map<String, String>;
    final items = officer['items'] as List<Map<String, String>>;

    return Card(
      color: isDragging ? Colors.grey[300] : Colors.white,
      elevation: isDragging ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(officerInfo['name'] ?? '',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(officerInfo['position'] ?? ''),
            Text(officerInfo['office'] ?? ''),
            const Divider(),
            const Text('Items:'),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text('- ${item['name']}'),
              ),
          ],
        ),
      ),
    );
  }
}
