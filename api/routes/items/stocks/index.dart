import 'dart:io';

import 'package:api/src/item/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getStocks(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getStocks(
  RequestContext context,
  ItemRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final String? productName = queryParams['product_name'];
    final String? description = queryParams['description'];

    final stockList = await repository.getStockInformation(
      productName: productName,
      description: description,
    );

    final stockJsonList = stockList?.map((stock) => stock.toJson()).toList();

    return Response.json(
      statusCode: 200,
      body: stockJsonList,
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
