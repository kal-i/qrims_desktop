import '../../models/paginated_notification_result.dart';

abstract interface class NotificationRemoteDataSource {
  Future<PaginatedNotificationResulModel> getNotifications({
    required int page,
    required int pageSize,
  });

  Future<bool> readNotification({
    required String notificationId,
    required bool read,
  });
}
