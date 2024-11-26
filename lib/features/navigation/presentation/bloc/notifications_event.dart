part of 'notifications_bloc.dart';

sealed class NotificationsEvent {
  const NotificationsEvent();
}

final class GetNotificationsEvent extends NotificationsEvent {
  const GetNotificationsEvent({
    required this.page,
    required this.pageSize,
  });

  final int page;
  final int pageSize;
}

final class ReadNotificationEvent extends NotificationsEvent {
  const ReadNotificationEvent({
    required this.notificationId,
    required this.read,
  });

  final String notificationId;
  final bool read;
}
