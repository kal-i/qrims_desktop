import 'dart:io';

import 'package:api/src/item/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getDescriptions(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getDescriptions(
  RequestContext context,
  ItemRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final productName = queryParams['product_name'];

    if (productName == null && productName!.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'message': 'No product name specified.',
        },
      );
    }

    final productDescriptions = await repository.getStocksDescription(
      page: page,
      pageSize: pageSize,
      productName: productName,
    );

    final descriptionCount =
        await repository.getStocksDescriptionFilteredCount(
      productName: productName,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'descriptions':  productDescriptions,
        'total_description_count': descriptionCount,
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
