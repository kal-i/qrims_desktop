import 'package:flutter/material.dart';

import '../../../../core/common/components/filter_table_row.dart';

class NotificationWindow extends StatefulWidget {
  const NotificationWindow({super.key});

  @override
  State<NotificationWindow> createState() => _NotificationWindowState();
}

class _NotificationWindowState extends State<NotificationWindow> {
  final ValueNotifier<String> _selectedFilterNotifier = ValueNotifier('');
  final filterMapping = {
    'Unread': '',
    'Read': '',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      constraints: const BoxConstraints(
        maxWidth: 500.0,
        maxHeight: 550.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(
              height: 20.0,
            ),
            FilterTableRow(
              selectedFilterNotifier: _selectedFilterNotifier,
              filterMapping: filterMapping,
            ),
            const SizedBox(
              height: 30.0,
            ),
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('$index'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
