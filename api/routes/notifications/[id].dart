import 'dart:io';

import 'package:api/src/notification/repository/notification_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

// get notif
// notif are returns, we will use the getUserINfo method to get info about that particular user id
// update notif

// send update notif
Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final connection = context.read<Connection>();
  final notifRepository = NotificationRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getUserNotification(context, id),
    HttpMethod.patch => _markedNotificationAsRead(context, notifRepository, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _getUserNotification(
  RequestContext context,
  String id,
) async {

  return Response();
}

Future<Response> _markedNotificationAsRead(
  RequestContext context,
  NotificationRepository notificationRepository,
  String id,
) async {
  try {
    final result = await notificationRepository.markAsRead(
      notificationId: id,
    );

    if (result == true) {
      return Response.json(
        statusCode: 200,
        body: {
          'message':
          'Notification $id marked as read.',
        },
      );
    } else {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'message': 'Failed to mark notification as read.',
        },
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error marking notification as read: $e',
      },
    );
  }
}
