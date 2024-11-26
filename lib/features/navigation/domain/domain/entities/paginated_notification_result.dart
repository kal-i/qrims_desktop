import 'notification.dart';

class PaginatedNotificationResultEntity {
  const PaginatedNotificationResultEntity({
    required this.notifications,
    required this.totalItemsCount,
  });

  final List<NotificationEntity> notifications;
  final int totalItemsCount;
}
