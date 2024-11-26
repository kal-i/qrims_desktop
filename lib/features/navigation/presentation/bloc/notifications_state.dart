part of 'notifications_bloc.dart';

sealed class NotificationsState {
  const NotificationsState();
}

final class NotificationsInitial extends NotificationsState {}

final class NotificationsLoading extends NotificationsState {}

final class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({
    required this.notifications,
    required this.totalNotificationsCount,
  });

  final List<NotificationEntity> notifications;
  final int totalNotificationsCount;
}

final class NotificationsError extends NotificationsState {
  const NotificationsError({
    required this.message,
  });

  final String message;
}

final class NotificationRead extends NotificationsState {
  const NotificationRead({
    required this.isSuccessful,
  });

  final bool isSuccessful;
}
