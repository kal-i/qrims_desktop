import 'dart:io';

import 'package:api/src/item/repository/item_repository.dart';
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
    final productName = queryParams['product_name'] as String;
    final productDescription = queryParams['product_description'];

    print(productName);

    String? productNameId;

    final productNameResult = await repository.checkProductNameIfExist(
      productName: productName,
    );

    if (productNameResult != null) {
      productNameId = productNameResult;
    } else {
      productNameId = await repository.registerProductName(
        productName: productName,
      );
    }
    print(productNameId);

    final productDescriptions = await repository.getStocksDescription(
      page: page,
      pageSize: pageSize,
      productNameId: productNameId,
      productDescription: productDescription,
    );

    final descriptionCount = await repository.getStocksDescriptionFilteredCount(
      productNameId: productNameId,
      productDescription: productDescription,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'descriptions': productDescriptions,
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
