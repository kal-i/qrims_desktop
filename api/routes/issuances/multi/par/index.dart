import 'dart:io';

import 'package:api/src/entity/repository/entity_repository.dart';
import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/issuance/repository/issuance_repository.dart';
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
    HttpMethod.post => _createMultiplePAR(
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

Future<Response> _createMultiplePAR(
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
  final headers = await context.request.headers;
  final json = await context.request.json() as Map<String, dynamic>;

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
  final entity = json['entity'] as String?;
  final fundClusterData = json['fund_cluster'] as String?;
  final supplierName = json['supplier_name'] as String?;
  final inspectionAndAcceptanceReportId =
      json['inspection_and_acceptance_report_id'] as String?;
  final contractNumber = json['contract_number'] as String?;
  final purchaseOrderNumber = json['purchase_order_number'] as String?;
  final receivingOfficers = json['receiving_officers'] as List<dynamic>? ?? [];

  final issuingOfficerOffice = json['issuing_officer_office'] as String?;
  final issuingOfficerPosition = json['issuing_officer_position'] as String?;
  final issuingOfficerName = json['issuing_officer_name'] as String?;

  final receivedDate = json['received_date'] != null
      ? json['received_date'] is String
          ? DateTime.parse(json['received_date'] as String)
          : json['received_date'] as DateTime
      : null;

  int? supplierId;
  String? issuingOfficerOfficeId;
  String? issuingOfficerPositionId;
  String? issuingOfficerId;

  if (supplierName != null && supplierName.isNotEmpty) {
    supplierId = await issuanceRepository.checkSupplierIfExist(
          supplierName: supplierName,
        ) ??
        await issuanceRepository.registerSupplier(
          supplierName: supplierName,
        );
  }

  if (issuingOfficerOffice != null && issuingOfficerOffice.isNotEmpty) {
    issuingOfficerOfficeId = await officeRepository.checkOfficeIfExist(
      officeName: issuingOfficerOffice,
    );
  }

  if ((issuingOfficerOfficeId != null && issuingOfficerOfficeId.isNotEmpty) &&
      (issuingOfficerPosition != null && issuingOfficerPosition.isNotEmpty)) {
    issuingOfficerPositionId = await positionRepository.checkIfPositionExist(
      officeId: issuingOfficerOfficeId,
      positionName: issuingOfficerPosition,
    );
  }

  if ((issuingOfficerPositionId != null &&
          issuingOfficerPositionId.isNotEmpty) &&
      (issuingOfficerName != null && issuingOfficerName.isNotEmpty)) {
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

  final List<Map<String, dynamic>> registerParItems = [];

  try {
    for (final receivingOfficer in receivingOfficers) {
      final officer = receivingOfficer['officer'] as Map<String, dynamic>;
      final officerName = officer['name'] as String?;
      final positionName = officer['position'] as String?;
      final officeName = officer['office'] as String?;
      final issuanceItems = receivingOfficer['items'] as List<dynamic>;

      String? officeId;
      String? positionId;
      String? officerId;

      if (officeName != null && officeName.isNotEmpty) {
        officeId = await officeRepository.checkOfficeIfExist(
          officeName: officeName,
        );
      }

      if ((officeId != null && officeId.isNotEmpty) &&
          (positionName != null && positionName.isNotEmpty)) {
        positionId = await positionRepository.checkIfPositionExist(
          officeId: officeId,
          positionName: positionName,
        );
      }

      if ((positionId != null && positionId.isNotEmpty) &&
          (officerName != null && officerName.isNotEmpty)) {
        officerId = await officerRepository.checkOfficerIfExist(
              name: officerName,
              positionId: positionId,
            ) ??
            await officerRepository.registerOfficer(
              name: officerName,
              positionId: positionId,
            );
      }

      final baseIssuanceId = await issuanceRepository.createPAR(
        issuedDate: issuedDate,
        issuanceItems: issuanceItems,
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
        receivingOfficerId: officerId,
        issuingOfficerId: issuingOfficerId,
        receivedDate: receivedDate,
      );

      final par = await issuanceRepository.getParById(
        id: baseIssuanceId,
      );

      if (par != null) {
        registerParItems.add(par.toJson());
      }
    }
  } catch (e, stackTrace) {
    print('Error during PAR issuance: $e');
    print(stackTrace);
    return Response.json(
      statusCode: 500,
      body: {
        'message': 'Failed to process one or more PAR issuances.',
        'error': e.toString(),
      },
    );
  }

  return Response.json(
    statusCode: 200,
    body: {
      'par_items': registerParItems,
    },
  );
}
