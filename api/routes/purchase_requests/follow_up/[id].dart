import 'dart:io';

import 'package:api/src/notification/model/notification.dart';
import 'package:api/src/notification/repository/notification_repository.dart';
import 'package:api/src/purchase_request/model/purchase_request.dart';
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
  final purchaseRequestRepository = PurchaseRequestRepository(connection);
  final userRepository = UserRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.post => _followUpPR(
        context,
        notifRepository,
        purchaseRequestRepository,
        userRepository,
        sessionRepository,
        id,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _followUpPR(
  RequestContext context,
  NotificationRepository notifRepository,
  PurchaseRequestRepository purchaseRepository,
  UserRepository userRepository,
  SessionRepository sessionRepository,
  String id,
) async {
  try {
    final headers = context.request.headers;
    final bearerToken = headers['Authorization']?.substring(7);
    if (bearerToken == null || bearerToken.isEmpty) {
      return Response.json(
        statusCode: 401,
        body: {
          'error': 'Authorization token is missing or invalid.',
        },
      );
    }

    // Retrieve the session using the token
    final session = await sessionRepository.sessionFromToken(bearerToken);
    if (session == null) {
      return Response.json(
        statusCode: 401,
        body: {
          'error': 'Invalid session. Please log in again.',
        },
      );
    }

    final currentUserId = session.userId;

    final purchaseRequest = await purchaseRepository.getPurchaseRequestById(
      id: id,
    );
    if (purchaseRequest == null) {
      return Response.json(
        statusCode: 401,
        body: {
          'error': 'Purchase request not found.',
        },
      );
    }

    if (purchaseRequest.purchaseRequestStatus ==
        PurchaseRequestStatus.cancelled) {
      return Response.json(
        statusCode: 403,
        body: {
          'error': 'Action forbidden: Purchase request rejected.',
        },
      );
    }

    if (purchaseRequest.purchaseRequestStatus ==
        PurchaseRequestStatus.fulfilled) {
      return Response.json(
        statusCode: 403,
        body: {
          'error': 'Action forbidden: Purchase request already fulfilled.',
        },
      );
    }

    final recipient = await userRepository.getCurrentSupplyCustodian();
    if (recipient == null) {
      return Response.json(
        statusCode: 500,
        body: {
          'error': 'No active supply custodian found.',
        },
      );
    }

    // condition not follow up
    await notifRepository.sendNotification(
      recipientId: recipient.id,
      senderId: currentUserId,
      message:
          'Purchase Request #${purchaseRequest.id} would like to follow up on its status.',
      type: NotificationType.prFollowUp,
      referenceId: purchaseRequest.id,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'message': 'Your request has been followed up.',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'error': 'An unexpected error occurred.',
        'details': e.toString(),
      },
    );
  }
}
