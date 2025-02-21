import 'dart:io';

import 'package:api/src/item/repository/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getOutOfStockItems(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getOutOfStockItems(
  RequestContext context,
  ItemRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;

    final outOfStockItems = await repository.getOutOfStockItems(
      page: page,
      pageSize: pageSize,
    );

    final outOfStockItemsFilteredCount =
        await repository.getOutOfStockItemsFilteredCount();

    return Response.json(
      statusCode: 200,
      body: {
        'items': outOfStockItems,
        'total_item_count': outOfStockItemsFilteredCount,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get items request.',
      },
    );
  }
}
