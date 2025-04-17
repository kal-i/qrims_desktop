import 'dart:io';

import 'package:api/src/entity/repository/entity_repository.dart';
import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:api/src/notification/model/notification.dart';
import 'package:api/src/notification/repository/notification_repository.dart';
import 'package:api/src/organization_management/repositories/office_repository.dart';
import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/organization_management/repositories/position_repository.dart';
import 'package:api/src/purchase_request/model/purchase_request.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:api/src/session/session_repository.dart';
import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final entityRepository = EntityRepository(connection);
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
        entityRepository,
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
  EntityRepository entityRepository,
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

    print('json received by route: $json');

    /// Get current user from session
    final bearerToken = headers['Authorization']?.substring(7);
    if (bearerToken == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {
          'message': 'Authorization token is missing.',
        },
      );
    }

    final session = await sessionRepository.sessionFromToken(bearerToken);
    if (session == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {
          'message': 'Invalid or expired token.',
        },
      );
    }

    final responsibleUser = await userRepository.getUserInformation(
      id: session.userId,
    );

    /// Process issuance data
    final issuedDate = json['issued_date'] != null
        ? json['issued_date'] is String
            ? DateTime.parse(json['issued_date'] as String)
            : json['issued_date'] as DateTime
        : DateTime.now();
    final issuanceItems = json['issuance_items'] as List<dynamic>?;
    final prId = json['pr_id'] as String?;
    final entity = json['entity'] as String?;
    final fundClusterData = json['fund_cluster'] as String?;
    final supplierName = json['supplier_name'] as String?;
    final inspectionAndAcceptanceReportId =
        json['inspection_and_acceptance_report_id'] as String?;
    final contractNumber = json['contract_number'] as String?;
    final purchaseOrderNumber = json['purchase_order_number'] as String?;

    if (issuanceItems == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'message': 'Missing required fields: issuance_items.'},
      );
    }

    final receivingOfficerOffice = json['receiving_officer_office'] as String?;
    final receivingOfficerPosition =
        json['receiving_officer_position'] as String?;
    final receivingOfficerName = json['receiving_officer_name'] as String?;

    final issuingOfficerOffice = json['issuing_officer_office'] as String?;
    final issuingOfficerPosition = json['issuing_officer_position'] as String?;
    final issuingOfficerName = json['issuing_officer_name'] as String?;

    final receivedDate = json['received_date'] != null
        ? json['received_date'] is String
            ? DateTime.parse(json['received_date'] as String)
            : json['received_date'] as DateTime
        : null;

    int? supplierId;
    String? receivingOfficerOfficeId;
    String? receivingOfficerPositionId;
    String? receivingOfficerId;
    String? issuingOfficerOfficeId;
    String? issuingOfficerPositionId;
    String? issuingOfficerId;

    if (supplierName != null) {
      supplierId = await issuanceRepository.checkSupplierIfExist(
            supplierName: supplierName,
          ) ??
          await issuanceRepository.registerSupplier(
            supplierName: supplierName,
          );
    }

    if (receivingOfficerOffice != null) {
      receivingOfficerOfficeId = await officeRepository.checkOfficeIfExist(
        officeName: receivingOfficerOffice,
      );
    }

    if (receivingOfficerPosition != null && receivingOfficerOfficeId != null) {
      receivingOfficerPositionId =
          await positionRepository.checkIfPositionExist(
        officeId: receivingOfficerOfficeId,
        positionName: receivingOfficerPosition,
      );
    }

    if (receivingOfficerName != null && receivingOfficerPositionId != null) {
      receivingOfficerId = await officerRepository.checkOfficerIfExist(
            name: receivingOfficerName,
            positionId: receivingOfficerPositionId,
          ) ??
          await officerRepository.registerOfficer(
            name: receivingOfficerName,
            positionId: receivingOfficerPositionId,
          );
    }

    if (issuingOfficerOffice != null) {
      issuingOfficerOfficeId = await officeRepository.checkOfficeIfExist(
        officeName: issuingOfficerOffice,
      );
    }

    if (issuingOfficerPosition != null && issuingOfficerOfficeId != null) {
      issuingOfficerPositionId = await positionRepository.checkIfPositionExist(
        officeId: issuingOfficerOfficeId,
        positionName: issuingOfficerPosition,
      );
    }

    if (issuingOfficerName != null && issuingOfficerPositionId != null) {
      issuingOfficerId = await officerRepository.checkOfficerIfExist(
            name: issuingOfficerName,
            positionId: issuingOfficerPositionId,
          ) ??
          await officerRepository.registerOfficer(
            name: issuingOfficerName,
            positionId: issuingOfficerPositionId,
          );
    }

    final fundCluster = fundClusterData != null
        ? FundCluster.values.firstWhere(
            (e) => e.toString().split('.').last == fundClusterData,
          )
        : null;

    /// Create PAR
    final issuanceId = await issuanceRepository.createPAR(
      issuedDate: issuedDate,
      issuanceItems: issuanceItems,
      purchaseRequest: prId != null
          ? await prRepository.getPurchaseRequestById(
              id: prId,
            )
          : null,
      entityId: entity != null
          ? await entityRepository.checkEntityIfExist(
              entityName: entity,
            )
          : null,
      fundCluster: fundCluster,
      supplierId: supplierId,
      inspectionAndAcceptanceReportId: inspectionAndAcceptanceReportId,
      contractNumber: contractNumber,
      purchaseOrderId: purchaseOrderNumber,
      receivingOfficerId: receivingOfficerId,
      issuingOfficerId: issuingOfficerId,
      receivedDate: receivedDate,
    );

    final par = await issuanceRepository.getParById(
      id: issuanceId,
    );

    /// Send notification to recipient officer
    if (prId != null) {
      final pr = await prRepository.getPurchaseRequestById(
        id: prId,
      );

      final recipientOfficer = await officerRepository.getOfficerById(
        officerId: receivingOfficerId,
      );

      String message = pr?.purchaseRequestStatus ==
              PurchaseRequestStatus.fulfilled
          ? "Purchase request #$prId has been fulfilled and issued. PAR Tracking ID: ${par?.id}."
          : "Purchase request #$prId has been partially issued. PAR Tracking ID: ${par?.id}.";

      await notifRepository.sendNotification(
        recipientId: recipientOfficer?.userId ?? '',
        senderId: session.userId,
        message: message,
        type: NotificationType.issuanceCreated,
        referenceId: prId,
      );
    }

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
