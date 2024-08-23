import 'package:flutter/material.dart';

import '../../../../core/constants/assets_path.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../navigation/presentation/components/account_profile.dart';
import '../../domain/entities/user_activity.dart';

class ActivityLogCard extends StatelessWidget {
  const ActivityLogCard({
    super.key,
    required this.userActivityEntity,
  });

  final UserActivityEntity userActivityEntity;

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.all(0.0),
      leading: const AccountProfile(
        imagePath: ImagePath.profile,
      ),
      title: Text(
        userActivityEntity.actionType.toString().split('.').last,
        style: currentTheme.textTheme.titleSmall,
      ),
      subtitle: Text(
        userActivityEntity.description,
        overflow: TextOverflow.ellipsis,
        style: currentTheme.textTheme.bodySmall,
      ),
      trailing: Text(
        dateFormatter(userActivityEntity.createdAt),
        style: currentTheme.textTheme.bodySmall,
      ),
    );
  }
}
