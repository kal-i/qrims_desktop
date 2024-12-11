import 'dart:io';

import 'package:api/src/organization_management/repositories/office_repository.dart';
import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/organization_management/repositories/position_repository.dart';
import 'package:api/src/purchase_order/repository/purchase_order_repository.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final officeRepository = OfficeRepository(connection);
  final positionRepository = PositionRepository(connection);
  final officerRepository = OfficerRepository(connection);
  final purchaseRequestRepository = PurchaseRequestRepository(connection);
  final purchaseOrderRepository = PurchaseOrderRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getPurchaseOrders(
        context,
        purchaseOrderRepository,
      ),
    HttpMethod.post => _registerPurchaseOrder(
        context,
        officeRepository,
        positionRepository,
        officerRepository,
        purchaseRequestRepository,
        purchaseOrderRepository,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getPurchaseOrders(
  RequestContext context,
  PurchaseOrderRepository purchaseOrderRepository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final poId = queryParams['po_id'];

    final purchaseOrderCount =
        await purchaseOrderRepository.getPurchaseOrdersCount(
      poId: poId,
    );

    final purchaseOrders = await purchaseOrderRepository.getPurchaseOrders(
      page: page,
      pageSize: pageSize,
      poId: poId,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'totalItemCount': purchaseOrderCount,
        'purchase_orders': purchaseOrders?.map((po) => po.toJson()).toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get purchase orders. $e',
      },
    );
  }
}

Future<Response> _registerPurchaseOrder(
  RequestContext context,
  OfficeRepository officeRepository,
  PositionRepository positionRepository,
  OfficerRepository officerRepository,
  PurchaseRequestRepository purchaseRequestRepository,
  PurchaseOrderRepository purchaseOrderRepository,
) async {
  try {
    final json = await context.request.json();

    final supplierName = json['supplier_name'] as String;
    final supplierAddress = json['supplier_address'] as String;
    final date = json['date'] is String
        ? DateTime.parse(json['date'] as String)
        : json['date'] as DateTime;
    final procurementMode = json['procurement_mode'] as String;
    final gentleman = json['gentleman'] as String;
    final deliveryPlace = json['delivery_place'] as String;
    final deliveryDate = json['delivery_date'] is String
        ? DateTime.parse(json['delivery_date'] as String)
        : json['delivery_date'] as DateTime;
    final deliveryTerm = json['delivery_term'] as int;
    final paymentTerm = json['payment_term'] as int;
    final description = json['description'] as String;
    final purchaseRequestId = json['pr_id'] as String;
    final conformeOfficerOffice = json['conforme_officer_office'] as String?;
    final conformeOfficerPosition =
        json['conforme_officer_position'] as String?;
    final conformeOfficerName = json['conforme_officer_name'] as String?;
    final conformeDate = json['conforme_date'] is String
        ? DateTime.parse(json['conforme_date'] as String)
        : json['conforme_date'] as DateTime?;
    final fundsHolderOfficerOffice =
        json['funds_holder_officer_office'] as String;
    final fundsHolderOfficerPosition =
        json['funds_holder_officer_position'] as String;
    final fundsHolderOfficerName = json['funds_holder_officer_name'] as String;

    final supplierId = await purchaseOrderRepository.checkIfSupplierExist(
          name: supplierName,
          address: supplierAddress,
        ) ??
        await purchaseOrderRepository.registerSupplier(
          name: supplierName,
          address: supplierAddress,
        );

    final superintendentOfficerId =
        await officerRepository.getCurrentSchoolDivisionSuperintendent();
    if (superintendentOfficerId == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'message': 'No active School Division Superintendent.'},
      );
    }

    String? conformeOfficerId;
    if (conformeOfficerOffice != null &&
        conformeOfficerPosition != null &&
        conformeOfficerName != null) {
      final conformeOfficerOfficeId = await officeRepository.checkOfficeIfExist(
        officeName: conformeOfficerOffice,
      );

      final conformeOfficerPositionId =
          await positionRepository.checkIfPositionExist(
        officeId: conformeOfficerOfficeId,
        positionName: conformeOfficerPosition,
      );

      conformeOfficerId = await officerRepository.checkOfficerIfExist(
            name: conformeOfficerName,
            positionId: conformeOfficerPositionId,
          ) ??
          await officerRepository.registerOfficer(
            name: conformeOfficerName,
            positionId: conformeOfficerPositionId,
          );
    }

    final fundsHolderOfficerOfficeId =
        await officeRepository.checkOfficeIfExist(
      officeName: fundsHolderOfficerOffice,
    );

    final fundsHolderOfficerPositionId =
        await positionRepository.checkIfPositionExist(
      officeId: fundsHolderOfficerOfficeId,
      positionName: fundsHolderOfficerPosition,
    );

    final fundsHolderOfficerId = await officerRepository.checkOfficerIfExist(
          name: fundsHolderOfficerName,
          positionId: fundsHolderOfficerPositionId,
        ) ??
        await officerRepository.registerOfficer(
          name: fundsHolderOfficerName,
          positionId: fundsHolderOfficerPositionId,
        );

    final purchaseOrderId = await purchaseOrderRepository.registerPurchaseOrder(
      supplierId: supplierId,
      date: date,
      procurementMode: procurementMode,
      gentleman: gentleman,
      deliveryPlace: deliveryPlace,
      deliveryDate: deliveryDate,
      deliveryTerm: deliveryTerm,
      paymentTerm: paymentTerm,
      description: description,
      prId: purchaseRequestId,
      conformeOfficerId: conformeOfficerId,
      conformeDate: conformeDate,
      superintendentOfficerId: superintendentOfficerId,
      fundsHolderOfficerId: fundsHolderOfficerId,
    );

    final purchaseOrder = await purchaseOrderRepository.getPurchaseOrderById(
      id: purchaseOrderId,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'purchase_order': purchaseOrder?.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the registering po: $e.',
      },
    );
  }
}
