import 'dart:io';

import 'package:api/src/notification/model/notification.dart';
import 'package:api/src/notification/repository/notification_repository.dart';
import 'package:api/src/organization_management/repositories/officer_repository.dart';
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
  final officerRepository = OfficerRepository(connection);
  final notifRepository = NotificationRepository(connection);
  final prRepository = PurchaseRequestRepository(connection);
  final userRepository = UserRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.patch => _updatePurchaseRequestStatus(
        context,
        officerRepository,
        notifRepository,
        prRepository,
        userRepository,
        sessionRepository,
        id,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _updatePurchaseRequestStatus(
  RequestContext context,
  OfficerRepository officerRepository,
  NotificationRepository notifRepository,
  PurchaseRequestRepository prRepository,
  UserRepository userRepository,
  SessionRepository sessionRepository,
  String id,
) async {
  try {
    final headers = await context.request.headers;
    final json = await context.request.json() as Map<String, dynamic>;

    print('received id: $id');
    print('received status: ${json['pr_status']}');

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

    final prStatus = PurchaseRequestStatus.values
        .firstWhere((e) => e.toString().split('.').last == json['pr_status']);

    print(prStatus);

    final result = await prRepository.updatePurchaseRequestStatus(
      id: id,
      status: prStatus,
    );

    print(result);

    if (result == true) {
      final recipientOfficer = await officerRepository.getOfficerById(
        officerId: purchaseRequest?.requestingOfficer.id,
      );

      if (recipientOfficer?.userId != null) {
        await notifRepository.sendNotification(
          recipientId: recipientOfficer!.userId!,
          senderId: responsibleUserId,
          message: prStatus == PurchaseRequestStatus.cancelled
              ? 'Purchase request #$id has been updated to ${prStatus.toString().split('.').last}.'
              : 'Purchase request #$id has been updated to ${prStatus.toString().split('.').last}.',
          type: prStatus == PurchaseRequestStatus.cancelled ? NotificationType.prCancelled : NotificationType.prPending,
          referenceId: id,
        );
      }

      return Response.json(
        statusCode: 200,
        body: {
          'message': 'Purchase Request #$id status updated to $prStatus.',
        },
      );
    } else {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {
          'message': 'Failed to update pr status.',
        },
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing update purchase request status: $e',
      },
    );
  }
}
