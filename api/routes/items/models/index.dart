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
    final productName = queryParams['product_name'] as String;
    final brandName = queryParams['brand_name'] as String;
    final modelName = queryParams['model_name'];

    int? productNameId;
    String? brandId;

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

    final brandResult = await repository.checkBrandIfExist(
      brandName: brandName,
    );

    if (brandResult != null) {
      brandId = brandResult;
    } else {
      brandId = await repository.registerBrand(
        brandName: brandName,
      );
    }

    print(productNameId);
    print(brandId);
    print(modelName);

    final modelNames = await repository.getBrandModelNames(
      page: page,
      pageSize: pageSize,
      productNameId: productNameId,
      brandId: brandId,
      modelName: modelName,
    );

    final itemNamesCount = await repository.getBrandModelsFilteredCount(
      productNameId: productNameId,
      brandId: brandId,
      modelName: modelName,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'models': modelNames,
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
