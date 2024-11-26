import '../../../../../core/error/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import 'package:fpdart/src/either.dart';

import '../entities/paginated_notification_result.dart';
import '../repository/notification_repository.dart';

class GetNotifications
    implements UseCase<PaginatedNotificationResultEntity, GetNotificationsParams> {
  const GetNotifications({
    required this.notificationRepository,
  });

  final NotificationRepository notificationRepository;

  @override
  Future<Either<Failure, PaginatedNotificationResultEntity>> call(
      GetNotificationsParams params) async {
    return await notificationRepository.getNotifications(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetNotificationsParams {
  const GetNotificationsParams({
    required this.page,
    required this.pageSize,
  });

  final int page;
  final int pageSize;
}
