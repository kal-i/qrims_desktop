import 'dart:io';

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

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final notifRepository = NotificationRepository(connection);
  final issuanceRepository = IssuanceRepository(connection);
  final officeRepository = OfficeRepository(connection);
  final officerRepository = OfficerRepository(connection);
  final positionRepository = PositionRepository(connection);
  final prRepository = PurchaseRequestRepository(connection);
  final userRepository = UserRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.post => _createRIS(
        context,
        notifRepository,
        issuanceRepository,
        officeRepository,
        officerRepository,
        positionRepository,
        prRepository,
        userRepository,
        sessionRepository,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _createRIS(
  RequestContext context,
  NotificationRepository notifRepository,
  IssuanceRepository issuanceRepository,
  OfficeRepository officeRepository,
  OfficerRepository officerRepository,
  PositionRepository positionRepository,
  PurchaseRequestRepository prRepository,
  UserRepository userRepository,
  SessionRepository sessionRepository,
) async {
  try {
    final headers = await context.request.headers;
    final json = await context.request.json() as Map<String, dynamic>;

    print('json received: $json');

    // get curr user by bearer token
    final bearerToken = headers['Authorization']?.substring(7) as String;
    final session = await sessionRepository.sessionFromToken(bearerToken);
    final responsibleUserId = session!.userId;
    final responsibleUser = await userRepository.getUserInformation(
      id: responsibleUserId,
    );

    final prId = json['pr_id'] as String?;
    final issuanceItems = json['issuance_items'] as List<dynamic>?;

    print('issuance items from route: $issuanceItems');

    if (prId == null || issuanceItems == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Missing required fields: pr_id or issuance_items.'},
      );
    }

    final purpose = json['purpose'] as String?;
    final responsibilityCenterCode =
        json['responsibility_center_code'] as String?;

    final receivingOfficerOffice = json['receiving_officer_office'] as String;
    final receivingOfficerPosition =
        json['receiving_officer_position'] as String;
    final receivingOfficerName = json['receiving_officer_name'] as String;

    final approvingOfficerOffice = json['approving_officer_office'] as String;
    final approvingOfficerPosition =
        json['approving_officer_position'] as String;
    final approvingOfficerName = json['approving_officer_name'] as String;

    final issuingOfficerOffice = json['issuing_officer_office'] as String;
    final issuingOfficerPosition = json['issuing_officer_position'] as String;
    final issuingOfficerName = json['issuing_officer_name'] as String;

    print('processing officers...');

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

    final approvingOfficerOfficeId = await officeRepository.checkOfficeIfExist(
      officeName: approvingOfficerOffice,
    );
    final approvingOfficerPositionId =
        await positionRepository.checkIfPositionExist(
      officeId: approvingOfficerOfficeId,
      positionName: approvingOfficerPosition,
    );
    final approvingOfficerId = await officerRepository.checkOfficerIfExist(
          name: approvingOfficerName,
          positionId: approvingOfficerPositionId,
        ) ??
        await officerRepository.registerOfficer(
          name: approvingOfficerName,
          positionId: approvingOfficerPositionId,
        );

    final issuingOfficerOfficeId = await officeRepository.checkOfficeIfExist(
      officeName: issuingOfficerOffice,
    );
    final issuingOfficerPositionId =
        await positionRepository.checkIfPositionExist(
      officeId: issuingOfficerOfficeId,
      positionName: issuingOfficerPosition,
    );
    final issuingOfficerId = await officerRepository.checkOfficerIfExist(
          name: issuingOfficerName,
          positionId: issuingOfficerPositionId,
        ) ??
        await officerRepository.registerOfficer(
          name: issuingOfficerName,
          positionId: issuingOfficerPositionId,
        );

    final recipientOfficer = await officerRepository.getOfficerById(
      officerId: receivingOfficerId,
    );

    final initPurchaseRequestData = await prRepository.getPurchaseRequestById(
      id: prId,
    );

    if (initPurchaseRequestData == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'message': 'Purchase request not found.'},
      );
    }

    print('Starting issuance process...');

    final issuanceId = await issuanceRepository.createRIS(
      purpose: purpose,
      responsibilityCenterCode: responsibilityCenterCode,
      purchaseRequest: initPurchaseRequestData,
      issuanceItems: issuanceItems,
      approvingOfficerId: approvingOfficerId,
      issuingOfficerId: issuingOfficerId,
      receivingOfficerId: receivingOfficerId,
    );

    print('Issuance created.');

    final ris = await issuanceRepository.getRisById(
      id: issuanceId,
    );

    print('Retrieved ris.');

    final postIssuancePurchaseRequestData =
        await prRepository.getPurchaseRequestById(
      id: prId,
    );

    int remainingQuantity = postIssuancePurchaseRequestData?.requestedItems
            .map((item) => item.remainingQuantity)
            .fold(0, (sum, qty) => sum! + qty!) ??
        0;

    String message = remainingQuantity == 0
        ? "Purchase request #$prId has been fulfilled and issued. RIS Tracking ID: ${ris?.id}."
        : "Purchase request #$prId has been partially issued. RIS Tracking ID: ${ris?.id}.";

    /// reference will always refer to the pr id to build a tracking
    //if (recipientOfficer?.userId != null) {
    await notifRepository.sendNotification(
      recipientId: recipientOfficer?.userId ?? '',
      senderId: responsibleUserId,
      message: message,
      type: NotificationType.issuanceCreated,
      referenceId: prId,
    );
    //}

    return Response.json(
      statusCode: 200,
      body: {
        'ris': ris?.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'Error processing create RIS: $e'},
    );
  }
}
