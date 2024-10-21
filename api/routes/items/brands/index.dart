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
    final manufacturerName = queryParams['manufacturer_name'] as String;
    final brandName = queryParams['brand_name'];

    String? manufacturerId;

    final manufacturerResult = await repository.checkManufacturerIfExist(
      manufacturerName: manufacturerName,
    );

    if (manufacturerResult != null) {
      manufacturerId = manufacturerResult;
    } else {
      manufacturerId = await repository.registerManufacturer(
        manufacturerName: manufacturerName,
      );
    }

    print(manufacturerName);
    print(manufacturerId);
    print(brandName);

    final brandNames = await repository.getManufacturerBrandNames(
      page: page,
      pageSize: pageSize,
      manufacturerId: manufacturerId,
      brandName: brandName,
    );

    final itemNamesCount =
        await repository.getManufacturerBrandNamesFilteredCount(
      manufacturerId: manufacturerId,
      brandName: brandName,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'brands': brandNames,
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
