import '../../../domain/domain/entities/paginated_notification_result.dart';
import 'notification.dart';

class PaginatedNotificationResulModel
    extends PaginatedNotificationResultEntity {
  const PaginatedNotificationResulModel({
    required super.notifications,
    required super.totalItemsCount,
  });

  factory PaginatedNotificationResulModel.fromJson(Map<String, dynamic> json) {
    return PaginatedNotificationResulModel(
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
      totalItemsCount: json['total_item_count'],
    );
  }
}
