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
    HttpMethod.post => _createPAR(
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

Future<Response> _createPAR(
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

    // get curr user by bearer token
    final bearerToken = headers['Authorization']?.substring(7) as String;
    final session = await sessionRepository.sessionFromToken(bearerToken);
    final responsibleUserId = session!.userId;
    final responsibleUser = await userRepository.getUserInformation(
      id: responsibleUserId,
    );

    final prId = json['pr_id'] as String?;
    final propertyNumber = json['property_number'] as String?;
    final issuanceItems = json['issuance_items'] as List<dynamic>?;

    if (prId == null || issuanceItems == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Missing required fields: pr_id or issuance_items.'},
      );
    }

    final receivingOfficerOffice = json['receiving_officer_office'] as String;
    final receivingOfficerPosition =
        json['receiving_officer_position'] as String;
    final receivingOfficerName = json['receiving_officer_name'] as String;

    final sendingOfficerOffice = json['sending_officer_office'] as String;
    final sendingOfficerPosition = json['sending_officer_position'] as String;
    final sendingOfficerName = json['sending_officer_name'] as String;

    // final issuedDate = json['issued_date'] is String
    //     ? DateTime.parse(json['issued_date'] as String)
    //     : json['issued_date'] as DateTime;

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

    final sendingOfficerOfficeId = await officeRepository.checkOfficeIfExist(
      officeName: sendingOfficerOffice,
    );
    final sendingOfficerPositionId =
        await positionRepository.checkIfPositionExist(
      officeId: sendingOfficerOfficeId,
      positionName: sendingOfficerPosition,
    );
    final sendingOfficerId = await officerRepository.checkOfficerIfExist(
          name: sendingOfficerName,
          positionId: sendingOfficerPositionId,
        ) ??
        await officerRepository.registerOfficer(
          name: sendingOfficerName,
          positionId: sendingOfficerPositionId,
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

    final issuanceId = await issuanceRepository.createPAR(
      propertyNumber: propertyNumber,
      purchaseRequest: initPurchaseRequestData,
      issuanceItems: issuanceItems,
      receivingOfficerId: receivingOfficerId,
      sendingOfficerId: sendingOfficerId,
      //issuedDate: issuedDate,
    );

    print('issuance id: $issuanceId');

    // todo: solve the problem here
    final par = await issuanceRepository.getParById(
      id: issuanceId,
    );

    print('par id: ${par?.parId}');

    final postIssuancePurchaseRequestData =
        await prRepository.getPurchaseRequestById(
      id: prId,
    );

    int remainingQuantity = postIssuancePurchaseRequestData?.requestedItems
            .map((item) => item.remainingQuantity)
            .fold(0, (sum, qty) => sum! + qty!) ??
        0;

    print('remaining qty: $remainingQuantity');

    String message = remainingQuantity == 0
        ? "Purchase request #$prId has been fulfilled and issued. PAR Tracking ID: ${par?.parId}."
        : "Purchase request #$prId has been partially issued. PAR Tracking ID: ${par?.parId}.";

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

    print('notif done');
    print('response items: ${par?.items}');
    print('response: ${par?.toJson()}');

    return Response.json(
      statusCode: 200,
      body: {
        'par': par?.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'Error processing create PAR: $e'},
    );
  }
}
