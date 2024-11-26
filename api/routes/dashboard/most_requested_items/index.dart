import 'dart:io';

import 'package:api/src/item/repository/item_repository.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final purchaseRequestRepository = PurchaseRequestRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getSummaryInformation(
        context,
        purchaseRequestRepository,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getSummaryInformation(
  RequestContext context,
  PurchaseRequestRepository purchaseRequestRepository,
) async {
  try {
    final queryParams = context.request.uri.queryParameters;
    final limit = int.tryParse(queryParams['limit'] ?? '10') ?? 10;
    final period = queryParams['period'] ?? 'month';

    final mostRequestedItemsData =
        await purchaseRequestRepository.getTopRequestedItemsByPeriod(
      limit,
      period,
    );

    return Response.json(
      body: {
        'most_requested_items_data': mostRequestedItemsData,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'An error occurred while processing the request to fetch most requested items: $e',
      },
    );
  }
}
