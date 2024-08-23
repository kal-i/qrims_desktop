import 'package:flutter/material.dart';
import '../../../../core/enums/auth_status.dart';

// Convert enum to a list
List<String> get authStatusOptions => AuthStatus.values
    .map((status) => status.toString().split('.').last)
    .toList();

class AuthStatusCellRenderer extends StatelessWidget {
  const AuthStatusCellRenderer({
    super.key,
    required this.onStatusChanged,
  });

  final Function(AuthStatus) onStatusChanged;

  @override
  Widget build(BuildContext context) {

    return PopupMenuButton<String>(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 5,
      position: PopupMenuPosition.under,
      tooltip: 'Actions',
      onSelected: (newStatus) {
        final selectedStatus = AuthStatus.values.firstWhere(
            (status) => status.toString().split('.').last == newStatus);
        onStatusChanged(selectedStatus);
      },
      itemBuilder: (context) {
        return authStatusOptions.map((status) {
          return PopupMenuItem<String>(
            value: status,
            child: Text(status, style: Theme.of(context).textTheme.bodySmall,),
          );
        }).toList();
      },
      icon: const Icon(
        Icons.more_vert,
        size: 20.0,
      ),
    );
  }
}
