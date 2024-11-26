import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/domain/entities/notification.dart';
import '../../domain/domain/usecases/get_notifications.dart';
import '../../domain/domain/usecases/read_notification.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required GetNotifications getNotifications,
    required ReadNotification readNotification,
  })  : _getNotifications = getNotifications,
        _readNotification = readNotification,
        super(NotificationsInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<ReadNotificationEvent>(_onReadNotification);
  }

  final GetNotifications _getNotifications;
  final ReadNotification _readNotification;

  void _onGetNotifications(
      GetNotificationsEvent event, Emitter<NotificationsState> emit) async {
    emit(NotificationsLoading());

    final response = await _getNotifications(GetNotificationsParams(
      page: event.page,
      pageSize: event.pageSize,
    ));

    response.fold(
      (l) => emit(NotificationsError(message: l.message)),
      (r) => emit(NotificationsLoaded(
        notifications: r.notifications,
        totalNotificationsCount: r.totalItemsCount,
      )),
    );
  }

  void _onReadNotification(
      ReadNotificationEvent event, Emitter<NotificationsState> emit) async {
    emit(NotificationsLoading());

    final response = await _readNotification(
      ReadNotificationParams(
        notificationId: event.notificationId,
        read: event.read,
      ),
    );

    response.fold(
      (l) => emit(NotificationsError(message: l.message)),
      (r) => emit(NotificationRead(
        isSuccessful: r,
      )),
    );
  }
}
