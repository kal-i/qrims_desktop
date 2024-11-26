import 'package:fpdart/fpdart.dart';

import '../../../../../core/error/failure.dart';
import '../entities/paginated_notification_result.dart';

abstract interface class NotificationRepository {
  Future<Either<Failure, PaginatedNotificationResultEntity>> getNotifications({
    required int page,
    required int pageSize,
  });

  Future<Either<Failure, bool>> readNotification({
    required String notificationId,
    required bool read,
  });
}
