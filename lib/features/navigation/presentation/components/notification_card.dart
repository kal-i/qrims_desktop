import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/sizing/sizing_config.dart';
import '../../../../config/themes/app_color.dart';
import '../../../../core/common/components/profile_avatar.dart';
import '../../../../core/models/mobile_user.dart';
import '../../../../core/models/supply_department_employee.dart';
import '../../../../core/utils/format_position.dart';
import '../../data/data/models/notification.dart';
import '../../../../core/utils/capitalizer.dart';
import '../../../../core/utils/readable_enum_converter.dart';
import '../../../../core/utils/time_ago_formatter.dart';
import '../../../../core/common/components/base_container.dart';

typedef NotificationTapCallback = void Function(NotificationModel notification);
typedef MarkAsReadCallback = void Function(NotificationModel notification);

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.onNotificationTap,
    required this.onMarkAsRead,
    required this.notification,
  });

  final NotificationTapCallback onNotificationTap;
  final MarkAsReadCallback onMarkAsRead;
  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final user = _mapNotificationSender(notification.sender);

    return GestureDetector(
      onTap: () => onNotificationTap(notification),
      child: BaseContainer(
        marginBottom: 3.0,
        height: 140.0,
        child: badges.Badge(
          showBadge: !notification.read,
          child: Row(
            children: [
              ProfileAvatar(
                user: user,
              ),
              const SizedBox(
                width: 10.0,
              ),
              Expanded(
                child: _buildNotificationDetails(
                  user,
                  context,
                ),
              ),
              _buildNotificationActions(
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }

  dynamic _mapNotificationSender(dynamic sender) {
    return sender is SupplyDepartmentEmployeeModel
        ? SupplyDepartmentEmployeeModel.fromEntity(sender)
        : sender is MobileUserModel
            ? MobileUserModel.fromEntity(sender)
            : null;
  }

  Widget _buildNotificationDetails(dynamic user, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              capitalizeWord(user.name ?? 'Unknown'),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Text(
              _buildUserInfo(user),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColor.accent,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(
          notification.message,
          softWrap: true,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
              ),
        ),
      ],
    );
  }

  String _buildUserInfo(dynamic user) {
    return user is SupplyDepartmentEmployeeModel
        ? readableEnumConverter(user.role)
        : user is MobileUserModel
            ? '${user.officerEntity.officeName.toUpperCase()} - ${formatPosition(user.officerEntity.positionName)}'
            : 'Unknown';
  }

  Widget _buildNotificationActions(BuildContext context) {
    return SizedBox(
      width: 30.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timeAgo(notification.createdAt!),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                ),
          ),
          PopupMenuButton(
            icon: const Icon(
              HugeIcons.strokeRoundedMoreVertical,
              size: 24.0,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => onMarkAsRead(notification),
                child:
                    Text(notification.read ? 'Mark as unread' : 'Mark as read'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// typedef is used to define a custom type for a function signature, making the code more readable and reusable.
// It allows you to reference a function type without repeating the entire signature, which is particularly useful
// when you have multiple functions that share the same signature. This improves maintainability by making it clear
// what kind of function is expected, and allows you to easily pass around functions as first-class objects.

// Example:
// typedef NotificationTapCallback = void Function(NotificationModel notification);
// This typedef creates a type alias for functions that take a NotificationModel as an argument and return void.
// Instead of writing 'void Function(NotificationModel notification)' repeatedly, we can simply use NotificationTapCallback
// to make the code cleaner and easier to understand.

