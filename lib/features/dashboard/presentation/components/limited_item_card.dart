import 'package:flutter/material.dart';

class LimitedItemCard extends StatelessWidget {
  const LimitedItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return ListTile(
      title: Text(
        'A4 Bond Paper (rim)',
        style: currentTheme.textTheme.titleSmall,
      ),
      trailing: Text(
        '5 left',
        style: currentTheme.textTheme.bodySmall,
      ),
    );
  }
}
