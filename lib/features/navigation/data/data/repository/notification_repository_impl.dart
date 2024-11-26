import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../domain/domain/entities/paginated_notification_result.dart';
import '../../../domain/domain/repository/notification_repository.dart';
import '../data_sources/remote/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({
    required this.notificationRemoteDataSource,
  });

  final NotificationRemoteDataSource notificationRemoteDataSource;
  @override
  Future<Either<Failure, PaginatedNotificationResultEntity>> getNotifications({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await notificationRemoteDataSource.getNotifications(
        page: page,
        pageSize: pageSize,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> readNotification({
    required String notificationId,
    required bool read,
  }) async {
    try {
      final response = await notificationRemoteDataSource.readNotification(
        notificationId: notificationId,
        read: read,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
