// import 'dart:async';
//
// import 'package:api/src/notification/repository/notification_repository.dart';
// import 'package:broadcast_bloc/broadcast_bloc.dart';
// import 'package:postgres/postgres.dart';
//
// import '../model/notification.dart' as notif;
//
// class NotificationCubit extends BroadcastCubit<List<notif.Notification>> {
//   NotificationCubit({
//     required NotificationRepository notificationRepository,
//   })  : _notificationRepository = notificationRepository,
//         super([]);
//
//   final NotificationRepository _notificationRepository;
//   StreamSubscription<List<Notification>?>? _notificationSubscription;
//
//   void subscribeToNotification(int recipientId) {
//     _notificationSubscription = _notificationRepository
//         .getNotifications(recipientId: recipientId)
//         .listen((notifications) {
//       emit(notifications!);
//     }) as StreamSubscription<List<Notification>?>;
//   }
//
//   Future<void> sendNotification({
//     required int recipientId,
//     required int senderId,
//     required String message,
//     required notif.NotificationType type,
//     int? referenceId,
//   }) async {
//     await _notificationRepository.sendNotification(
//       recipientId: recipientId,
//       senderId: senderId,
//       message: message,
//       type: type,
//       referenceId: referenceId,
//     );
//   }
//
//   // Dispose method to clean up resources
//   @override
//   Future<void> close() {
//     _notificationSubscription?.cancel();
//     return super.close();
//   }
// }
