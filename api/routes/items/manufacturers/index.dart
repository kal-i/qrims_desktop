import 'dart:io';

import 'package:api/src/item/repository/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getManufacturerNames(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getManufacturerNames(
    RequestContext context,
    ItemRepository repository,
    ) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final manufacturerName = queryParams['manufacturer_name'];

    final manufacturerNames = await repository.getManufacturerNames(
      page: page,
      pageSize: pageSize,
      manufacturerName: manufacturerName,
    );

    final itemNamesCount = await repository.getManufacturerNamesFilteredCount(
      manufacturerName: manufacturerName,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'manufacturers': manufacturerNames,
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
