import 'dart:io';

import 'package:api/src/item/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
) async {
  final connection = context.read<Connection>();
  final repository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getStockById(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getStockById(
  RequestContext context,
  ItemRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final id = int.parse(queryParams['id'] as String);

    final result = await repository.getStockById(
      id: id,
    );

    if (result != null) {
      return Response.json(
        statusCode: 200,
        body: {
          'stock': result.toJson(),
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'message': 'Stock not found',
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
