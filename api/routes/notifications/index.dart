import 'dart:io';

import 'package:api/src/notification/repository/notification_repository.dart';
import 'package:api/src/session/session_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await context.read<Connection>();
  final notifRepository = NotificationRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get =>
      _getUserNotifications(context, notifRepository, sessionRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _getUserNotifications(
  RequestContext context,
  NotificationRepository notificationRepository,
  SessionRepository sessionRepository,
) async {
  try {
    final headers = await context.request.headers;
    final queryParams = await context.request.uri.queryParameters;

    final bearerToken = headers['Authorization']?.substring(7) as String;
    final session = await sessionRepository.sessionFromToken(bearerToken);
    final recipientId = session!.userId;

    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;

    final notifications = await notificationRepository.getNotifications(
      page: page,
      pageSize: pageSize,
      recipientId: recipientId,
    );

    final notificationsCount =
        await notificationRepository.getNotificationsCount(
      recipientId: recipientId,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'total_item_count': notificationsCount,
        'notifications': notifications
            ?.map((notification) => notification.toJson())
            .toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing get user notifications: $e',
      },
    );
  }
}
