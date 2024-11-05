import 'dart:io';

import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final prRepository = PurchaseRequestRepository(connection);
  final issuanceRepository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get =>
      _matchPrItemWithInventory(context, prRepository, issuanceRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _matchPrItemWithInventory(
  RequestContext context,
  PurchaseRequestRepository prRepository,
  IssuanceRepository issuanceRepository,
) async {
  final queryParams = await context.request.uri.queryParameters;
  final prId = queryParams['pr_id'] as String;

  final purchaseRequest = await prRepository.getPurchaseRequestById(
    id: prId,
  );

  final items = await issuanceRepository.matchingItemFromPurchaseRequest(
    purchaseRequestId: prId,
    requestedQuantity: purchaseRequest!.quantity,
  );

  // we need this to show some of the info required by
  return Response.json(
    body: {
      'purchase_request': purchaseRequest.toJson(),
      'matched_items': items,
    },
  );
}
