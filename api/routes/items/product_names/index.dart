import 'dart:io';

import 'package:api/src/item/repository/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getProductNames(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getProductNames(
    RequestContext context,
    ItemRepository repository,
    ) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final productName = queryParams['product_name'];

    final productNames = await repository.getStocksProductName(
      page: page,
      pageSize: pageSize,
      productName: productName,
    );

    final itemNamesCount = await repository.getStocksProductNameFilteredCount(
      productName: productName,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'product_names': productNames,
        'total_item_count': itemNamesCount,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': e.toString(),
      },
    );
  }
}
