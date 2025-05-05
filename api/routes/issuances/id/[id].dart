import 'dart:io';

import 'package:api/src/entity/repository/entity_repository.dart';
import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:api/src/notification/model/notification.dart';
import 'package:api/src/notification/repository/notification_repository.dart';
import 'package:api/src/organization_management/repositories/office_repository.dart';
import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/organization_management/repositories/position_repository.dart';
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
  final issuanceRepository = IssuanceRepository(connection);
  final entityRepository = EntityRepository(connection);
  final officeRepository = OfficeRepository(connection);
  final positionRepository = PositionRepository(connection);
  final officerRepository = OfficerRepository(connection);
  final prRepository = PurchaseRequestRepository(connection);
  final userRepository = UserRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getIssuanceById(context, issuanceRepository, id),
    // HttpMethod.patch => _receiveIssuance(
    //     context,
    //     notifRepository,
    //     issuanceRepository,
    //     officerRepository,
    //     prRepository,
    //     userRepository,
    //     sessionRepository,
    //     id,
    //   ),
    HttpMethod.patch => _updateIssuance(
        context,
        connection,
        issuanceRepository,
        entityRepository,
        officeRepository,
        positionRepository,
        officerRepository,
        id,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getIssuanceById(
  RequestContext context,
  IssuanceRepository repository,
  String id,
) async {
  try {
    final issuance = await repository.getIssuanceById(
      id: id,
    );

    if (issuance != null) {
      final issuanceData = issuance is InventoryCustodianSlip
          ? issuance.toJson()
          : issuance is PropertyAcknowledgementReceipt
              ? issuance.toJson()
              : issuance is RequisitionAndIssueSlip
                  ? issuance.toJson()
                  : {
                      'message': 'Unrecognized issuance type',
                    };

      return Response.json(
        statusCode: 200,
        body: {'issuance': issuanceData},
      );
    }

    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'message': 'Issuance request not found.',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing get issuance information: $e',
      },
    );
  }
}

Future<Response> _receiveIssuance(
  RequestContext context,
  NotificationRepository notifRepository,
  IssuanceRepository issuanceRepository,
  OfficerRepository officerRepository,
  PurchaseRequestRepository prRepository,
  UserRepository userRepository,
  SessionRepository sessionRepository,
  String id,
) async {
  try {
    // Extract the Authorization header
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

    final officer = await officerRepository.getOfficerById(
      userId: currentUserId,
    );
    if (officer == null) {
      return Response.json(
        statusCode: 404,
        body: {
          'error': 'Officer not found.',
        },
      );
    }

    /// Retrieve the issuance information
    final issuance = await issuanceRepository.getIssuanceById(
      id: id,
    );

    if (issuance == null) {
      return Response.json(
        statusCode: 404,
        body: {
          'error': 'Issuance not found.',
        },
      );
    }

    // Attempt to receive the issuance
    final isIssuanceReceived = await issuanceRepository.receiveIssuance(
      issuanceId: id,
      receivingOfficerId: officer.id,
    );
    if (!isIssuanceReceived) {
      return Response.json(
        statusCode: 500,
        body: {
          'error': 'Unable to mark issuance as received.',
        },
      );
    }

    // Determine the current supply custodian
    final recipient = await userRepository.getCurrentSupplyCustodian();
    if (recipient == null) {
      return Response.json(
        statusCode: 500,
        body: {
          'error': 'No active supply custodian found.',
        },
      );
    }

    // Calculate issued quantity
    int issuedQuantity =
        issuance.items.fold(0, (sum, item) => sum! + item.quantity) ?? 0;

    // Send notification to supply custodian
    if (issuance.purchaseRequest != null) {
      await notifRepository.sendNotification(
        recipientId: recipient.id,
        senderId: currentUserId,
        message:
            '', // 'The issuance for Purchase Request #${issuance.purchaseRequest.id} has been received. Quantity received: $issuedQuantity out of ${issuance.purchaseRequest.quantity}. Tracking ID: $id',
        type: NotificationType.issuanceReceived,
        referenceId: issuance.purchaseRequest!.id,
      );
    }

    final updatedIssuance = await issuanceRepository.getIssuanceById(
      id: id,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'issuance': updatedIssuance is InventoryCustodianSlip
            ? updatedIssuance.toJson()
            : updatedIssuance is PropertyAcknowledgementReceipt
                ? updatedIssuance.toJson()
                : {
                    'message': 'Unrecognized issuance type',
                  },
      },
    );
  } catch (e) {
    // Handle specific error for mismatched receiving officer
    if (e is Exception && e.toString().contains('not the receiving officer')) {
      return Response.json(
        statusCode: 403,
        body: {
          'error': 'You are not the receiving officer for this issuance.',
        },
      );
    }

    // Generic error handling
    return Response.json(
      statusCode: 500,
      body: {
        'error': 'An unexpected error occurred.',
        'details': e.toString(),
      },
    );
  }
}

Future<Response> _updateIssuance(
  RequestContext context,
  Connection connection,
  IssuanceRepository issuanceRepository,
  EntityRepository entityRepository,
  OfficeRepository officeRepository,
  PositionRepository positionRepository,
  OfficerRepository officerRepository,
  String id,
) async {
  final json = await context.request.json();
  final entityName = json['entity'] as String;
  final receivingOfficerOffice = json['receiving_officer_office'] as String;
  final receivingOfficerPosition = json['receiving_officer_position'] as String;
  final receivingOfficerName = json['receiving_officer_name'] as String;
  final receivedDate = json['received_date'] is String
      ? DateTime.parse(json['received_date'] as String)
      : json['received_date'] as DateTime;

  final issuanceEntity = await issuanceRepository.getIssuanceById(id: id);

  if (issuanceEntity == null) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {'message': 'Base issuance entity not found.'},
    );
  }

  final receivingOfficerOfficeId = await officeRepository.checkOfficeIfExist(
    officeName: receivingOfficerOffice,
  );

  final receivingOfficerPositionId =
      await positionRepository.checkIfPositionExist(
    officeId: receivingOfficerOfficeId,
    positionName: receivingOfficerPosition,
  );

  final receivingOfficerId = await officerRepository.checkOfficerIfExist(
        name: receivingOfficerName,
        positionId: receivingOfficerPositionId,
      ) ??
      await officerRepository.registerOfficer(
        name: receivingOfficerName,
        positionId: receivingOfficerPositionId,
      );

  final success = await connection.runTx((ctx) async {
    final updated = await issuanceRepository.receiveIssuanceEntity(
      ctx: ctx,
      entityId: await entityRepository.checkEntityIfExist(
        entityName: entityName,
      ),
      baseIssuanceEntityId: issuanceEntity.id,
      receivingOfficerId: receivingOfficerId,
      receivedDate: receivedDate,
    );

    return updated;
  });

  if (success) {
    return Response.json(
      statusCode: HttpStatus.ok,
      body: {'message': 'Base issuance entity updated: $id'},
    );
  }

  return Response.json(
    statusCode: HttpStatus.internalServerError,
    body: {'message': 'Failed to update issuance.'},
  );
}
