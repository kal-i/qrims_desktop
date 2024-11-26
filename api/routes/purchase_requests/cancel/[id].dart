import 'dart:io';

import 'package:api/src/notification/repository/notification_repository.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:api/src/session/session_repository.dart';
import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
    RequestContext context,
    String id,
    ) async {
  final connection = context.read<Connection>();
  final notifRepository = NotificationRepository(connection);
  final prRepository = PurchaseRequestRepository(connection);
  final userRepository = UserRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.patch => _cancelPurchaseRequest(
      context,
      notifRepository,
      prRepository,
      userRepository,
      sessionRepository,
      id,
    ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _cancelPurchaseRequest(
    RequestContext context,
    NotificationRepository notifRepository,
    PurchaseRequestRepository prRepository,
    UserRepository userRepository,
    SessionRepository sessionRepository,
    String id,
    ) async {
  try {
    final headers = await context.request.headers;
    final json = await context.request.json() as Map<String, dynamic>;

    // get curr user by bearer token
    final bearerToken = headers['Authorization']?.substring(7) as String;
    final session = await sessionRepository.sessionFromToken(bearerToken);
    final responsibleUserId = session!.userId;
    final responsibleUser = await userRepository.getUserInformation(
      id: responsibleUserId,
    );

    final purchaseRequest = await prRepository.getPurchaseRequestById(
      id: id,
    );

    print('pr info');

    final notifications = await notifRepository.getNotificationTimelineTrail(
      referenceId: id,
    );

    print('notif info: $notifications');

    if (purchaseRequest != null) {
      return Response.json(
        statusCode: 200,
        body: {
          'purchase_request': purchaseRequest.toJson(),
          'notifications': notifications
              ?.map((notification) => notification.toJson())
              .toList(),
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'message': 'Purchase request not found.',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing get purchase request information: $e',
      },
    );
  }
}
