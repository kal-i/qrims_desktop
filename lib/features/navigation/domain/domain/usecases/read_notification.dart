import '../../../../../core/error/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import 'package:fpdart/src/either.dart';

import '../repository/notification_repository.dart';

class ReadNotification implements UseCase<bool, ReadNotificationParams> {
  const ReadNotification({
    required this.notificationRepository,
  });

  final NotificationRepository notificationRepository;

  @override
  Future<Either<Failure, bool>> call(ReadNotificationParams params) async {
    return await notificationRepository.readNotification(
      notificationId: params.notificationId,
      read: params.read,
    );
  }
}

class ReadNotificationParams {
  const ReadNotificationParams({
    required this.notificationId,
    required this.read,
  });

  final String notificationId;
  final bool read;
}
