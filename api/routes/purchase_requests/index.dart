import 'dart:io';

import 'package:api/src/entity/repository/entity_repository.dart';
import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/item/models/item.dart';
import 'package:api/src/item/repository/item_repository.dart';
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
  final officeRepository = OfficeRepository(connection);
  final officerRepository = OfficerRepository(connection);
  final positionRepository = PositionRepository(connection);
  final itemRepository = ItemRepository(connection);
  final notifRepository = NotificationRepository(connection);
  final prRepository = PurchaseRequestRepository(connection);
  final userRepository = UserRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getPurchaseRequests(context, prRepository),
    HttpMethod.post => _registerPurchaseRequest(
        context,
        entityRepository,
        officeRepository,
        officerRepository,
        positionRepository,
        itemRepository,
        notifRepository,
        prRepository,
        userRepository,
        sessionRepository,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getPurchaseRequests(
  RequestContext context,
  PurchaseRequestRepository prRepository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final prId = queryParams['pr_id'];
    final date = queryParams['date'] as DateTime?;
    final prStatusString = queryParams['pr_status'];

    final prStatus = prStatusString != null
        ? PurchaseRequestStatus.values
            .firstWhere((e) => e.toString().split('.').last == prStatusString)
        : null;

    final prFilteredCount = await prRepository.getPurchaseRequestsFilteredCount(
      prId: prId,
      date: date,
      prStatus: prStatus,
    );

    final purchaseRequests = await prRepository.getPurchaseRequests(
      page: page,
      pageSize: pageSize,
      prId: prId,
      date: date,
      prStatus: prStatus,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'totalItemCount': prFilteredCount,
        'purchase_requests':
            purchaseRequests?.map((pr) => pr.toJson()).toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get purchase requests.',
      },
    );
  }
}

Future<Response> _registerPurchaseRequest(
  RequestContext context,
  EntityRepository entityRepository,
  OfficeRepository officeRepository,
  OfficerRepository officerRepository,
  PositionRepository positionRepository,
  ItemRepository itemRepository,
  NotificationRepository notifRepository,
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

    final entityName = json['entity_name'] as String;
    final fundClusterString = json['fund_cluster'] as String;
    final officeName = json['office_name'] as String;
    final responsibilityCenterCode =
        json['responsibility_center_code'] as String?;
    final date = json['date'] is String
        ? DateTime.parse(json['date'] as String)
        : json['date'] as DateTime;
    final productName = json['product_name'] as String;
    final productDescription = json['product_description'] as String;
    final unitString = json['unit'] as String;
    final quantity = json['quantity'] as int;
    final unitCost = json['unit_cost'] as double;
    final purpose = json['purpose'] as String;

    final requestingOfficerOffice = json['requesting_officer_office'] as String;
    final requestingOfficerPosition =
        json['requesting_officer_position'] as String;
    final requestingOfficerName = json['requesting_officer_name'] as String;

    final approvingOfficerOffice = json['approving_officer_office'] as String;
    final approvingOfficerPosition =
        json['approving_officer_position'] as String;
    final approvingOfficerName = json['approving_officer_name'] as String;

    final entityId = await entityRepository.checkEntityIfExist(
      entityName: entityName,
    );
    final officeId = await officeRepository.checkOfficeIfExist(
      officeName: officeName,
    );

    final productNameId = await itemRepository.checkProductNameIfExist(
          productName: productName,
        ) ??
        await itemRepository.registerProductName(
          productName: productName,
        );

    final productDescriptionId =
        await itemRepository.checkProductDescriptionIfExist(
              productDescription: productDescription,
            ) ??
            await itemRepository.registerProductDescription(
              productDescription: productDescription,
            );

    print(
        'product name id: $productNameId - product desc id: $productDescriptionId');

    final productStockResult = await itemRepository.checkProductStockIfExist(
      productNameId: productNameId,
      productDescriptionId: productDescriptionId,
    );

    print('product stock count: $productStockResult');

    if (productStockResult == 0) {
      await itemRepository.registerProductStock(
        productNameId: productNameId,
        productDescriptionId: productDescriptionId,
      );
      print('product stock registered.');
    }

    /// requesting officer info
    final requestingOfficerOfficeId = await officeRepository.checkOfficeIfExist(
      officeName: requestingOfficerOffice,
    );
    final requestingOfficerPositionId =
        await positionRepository.checkIfPositionExist(
      officeId: requestingOfficerOfficeId,
      positionName: requestingOfficerPosition,
    );
    final requestingOfficerId = await officerRepository.checkOfficerIfExist(
          name: requestingOfficerName,
          positionId: requestingOfficerPositionId,
        ) ??
        await officerRepository.registerOfficer(
          name: requestingOfficerName,
          positionId: requestingOfficerPositionId,
        );
    print(
        'req office id: $requestingOfficerOfficeId - req pos id: $requestingOfficerPositionId - req officer id: $requestingOfficerId');

    /// approving officer info
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
    print(
        'app office id: $approvingOfficerOfficeId - app pos id: $approvingOfficerPositionId - app officer id: $approvingOfficerId');

    final fundCluster = FundCluster.values.firstWhere(
      (e) => e.toString().split('.').last == fundClusterString,
    );
    final unit = Unit.values.firstWhere(
      (e) => e.toString().split('.').last == unitString,
    );

    final purchaseRequestId = await prRepository.registerPurchaseRequest(
      entityId: entityId,
      fundCluster: fundCluster,
      officeId: officeId,
      responsibilityCenterCode: responsibilityCenterCode,
      date: date,
      productNameId: productNameId,
      productDescriptionId: productDescriptionId,
      unit: unit,
      quantity: quantity,
      unitCost: unitCost,
      purpose: purpose,
      requestingOfficerId: requestingOfficerId,
      approvingOfficerId: approvingOfficerId,
    );

    print('pr id: $purchaseRequestId');

    final recipientOfficer = await officerRepository.getOfficerById(
      id: requestingOfficerId,
    );
    print('recipient officer: $recipientOfficer');

    /// notif
    /// must be a user
    if (recipientOfficer?.userId != null) {
      await notifRepository.sendNotification(
        recipientId: recipientOfficer!.userId!,
        senderId: responsibleUserId,
        message:
            'Your purchase request has been registered to the system with a tracking id of $purchaseRequestId.',
        type: NotificationType.prCreated,
        referenceId: purchaseRequestId,
      );
    }
    print('after notif');

    final purchaseRequest = await prRepository.getPurchaseRequestById(
      id: purchaseRequestId,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'purchase_request': purchaseRequest?.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the registering pr: $e.',
      },
    );
  }
}
