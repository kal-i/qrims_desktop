import 'dart:io';

import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = PurchaseRequestRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getPurchaseRequestIds(
        context,
        repository,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getPurchaseRequestIds(
  RequestContext context,
  PurchaseRequestRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final prId = queryParams['pr_id'];
    final type = queryParams['type'];

    final prIds = await repository.getPurchaseRequestIds(
      page: page,
      pageSize: pageSize,
      prId: prId,
    );

    final prIdsCount = await repository.getPurchaseRequestIdsFilteredCount(
      prId: prId,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'totalItemCount': prIdsCount,
        'purchase_request_ids': prIds,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get pr ids request. $e',
      },
    );
  }
}
