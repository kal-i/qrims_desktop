import 'dart:io';

import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/purchase_request/model/purchase_request.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:api/src/session/session_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
) async {
  final connection = context.read<Connection>();
  final officerRepository = OfficerRepository(connection);
  final prRepository = PurchaseRequestRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getReceivingOfficerPurchaseRequests(
        context,
        officerRepository,
        prRepository,
        sessionRepository,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getReceivingOfficerPurchaseRequests(
  RequestContext context,
  OfficerRepository officerRepository,
  PurchaseRequestRepository prRepository,
  SessionRepository sessionRepository,
) async {
  try {
    final headers = await context.request.headers;
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final prId = queryParams['pr_id'];
    final prStatusString = queryParams['pr_status'];
    final filter = queryParams['filter'];

    final bearerToken = headers['Authorization']?.substring(7) as String;
    final session = await sessionRepository.sessionFromToken(bearerToken);
    final userId = session!.userId;

    final officer = await officerRepository.getOfficerById(
      userId: userId,
    );
    print(officer);
    print('retrieved officer id: ${officer?.id}');

    final prStatus = prStatusString != null
        ? PurchaseRequestStatus.values
        .firstWhere((e) => e.toString().split('.').last == prStatusString)
        : null;

    final purchaseRequests = await prRepository.getPurchaseRequests(
      page: page,
      pageSize: pageSize,
      prId: prId,
      prStatus: prStatus,
      filter: filter,
      receivingOfficerId: officer?.id,
    );

    final prFilteredCount = await prRepository.getPurchaseRequestsFilteredCount(
      prId: prId,
      prStatus: prStatus,
      filter: filter,
      requestingOfficerId: officer?.id,
    );

    final pendingPurchaseRequestCount = await prRepository
        .getReceivingOfficerPurchaseRequestsCountBasedOnStatus(
      receivingOfficerId: officer!.id,
      status: PurchaseRequestStatus.pending,
    );

    final incompletePurchaseRequestCount = await prRepository
        .getReceivingOfficerPurchaseRequestsCountBasedOnStatus(
      receivingOfficerId: officer.id,
      status: PurchaseRequestStatus.partiallyFulfilled,
    );

    final completePurchaseRequestCount = await prRepository
        .getReceivingOfficerPurchaseRequestsCountBasedOnStatus(
      receivingOfficerId: officer.id,
      status: PurchaseRequestStatus.fulfilled,
    );

    final cancelledPurchaseRequestCount = await prRepository
        .getReceivingOfficerPurchaseRequestsCountBasedOnStatus(
      receivingOfficerId: officer.id,
      status: PurchaseRequestStatus.cancelled,
    );

    final purchaseRequestJsonList =
        purchaseRequests?.map((pr) => pr.toJson()).toList();

    return Response.json(
      statusCode: 200,
      body: {
        'total_item_count': prFilteredCount,
        'pending_count': pendingPurchaseRequestCount,
        'incomplete_count': incompletePurchaseRequestCount,
        'complete_count': completePurchaseRequestCount,
        'cancelled_count': cancelledPurchaseRequestCount,
        'purchase_requests': purchaseRequestJsonList,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message':
            'Error processing get receiving officer\'s purchase requests: $e',
      },
    );
  }
}
