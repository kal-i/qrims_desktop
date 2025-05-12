import 'dart:io';

import 'package:api/src/item/repository/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.post => _manageStock(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _manageStock(
  RequestContext context,
  ItemRepository itemRepository,
) async {
  final json = await context.request.json() as Map<String, dynamic>;
  final productName = json['product_name'] as String;
  final description = json['description'] as String?;
  final stockNo = json['stock_no'] as int;

  int productNameId;
  int productDescriptionId;

  try {
    productNameId = await itemRepository.checkProductNameIfExist(
          productName: productName,
        ) ??
        await itemRepository.registerProductName(
          productName: productName,
        );

    productDescriptionId = await itemRepository.checkProductDescriptionIfExist(
          productDescription: description,
        ) ??
        await itemRepository.registerProductDescription(
          productDescription: description,
        );

    // Register product stock if needed
    final productStockResult = await itemRepository.checkProductStockIfExist(
      productNameId: productNameId,
      productDescriptionId: productDescriptionId,
    );

    if (productStockResult == 0) {
      await itemRepository.registerProductStock(
        productNameId: productNameId,
        productDescriptionId: productDescriptionId,
        stockNo: stockNo,
      );
    } else {
      await itemRepository.updateStockNo(
        productNameId: productNameId,
        productDescriptionId: productDescriptionId,
        newStockNo: stockNo,
      );
    }

    return Response.json(
      statusCode: 200,
      body: {
        'message': 'Stock saved.',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'Error registering product information: $e'},
    );
  }
}
