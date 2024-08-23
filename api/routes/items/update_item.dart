import 'dart:io';

import 'package:api/src/item/item.dart';
import 'package:api/src/item/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final itemRepository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.patch => _updateItemInformation(context, itemRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _updateItemInformation(
  RequestContext context,
  ItemRepository itemRepository,
) async {
  final queryParam = context.request.uri.queryParameters;
  final json = await context.request.json() as Map<String, dynamic>;

  final itemId = int.parse(queryParam['item_id'] as String);
  final productName = json['product_name'] as String?;
  final description = json['description'] as String?;
  final specification = json['specification'] as String?;
  final brand = json['brand'] as String?;
  final model = json['model'] as String?;
  final serialNo = json['serial_no'] as String?;
  final manufacturer = json['manufacturer'] as String?;
  final assetClassification = json['asset_classification'] != null ? AssetClassification.values.firstWhere((assetClassification) => assetClassification.toString().split('.'). last == (json['asset_classification'] as String)) : null;
  final assetSubClass = json['asset_sub_class'] != null ? AssetSubClass.values.firstWhere((assetSubClass) => assetSubClass.toString().split('.').last == (json['asset_sub_class'] as String)) : null;
  final unit = json['unit'] as String?;
  final quantity = json['quantity'] as int?;
  final unitCost = json['unit_cost'] as double?;
  final estimatedUsefulLife = json['estimated_useful_life'] as int?;
  final acquiredDate = json['acquired_date'] is String ? DateTime.parse(json['acquired_date'] as String) : json['acquired_date'] as DateTime?;

  final result = await itemRepository.updateItemInformation(
    id: itemId,
    productName: productName,
    description: description,
    specification: specification,
    brand: brand,
    model: model,
    serialNo: serialNo,
    manufacturer: manufacturer,
    assetClassification: assetClassification,
    assetSubClass: assetSubClass,
    unit: unit,
    quantity: quantity,
    unitCost: unitCost,
    estimatedUsefulLife: estimatedUsefulLife,
    acquiredDate: acquiredDate,
  );

  if (result == true) {
    return Response.json(
      statusCode: 200,
      body: {
        'message': 'Item $itemId is updated successfully.',
      },
    );
  }

  return Response.json(
    statusCode: HttpStatus.internalServerError,
    body: {
      'message': 'Something went wrong while updating user.',
    },
  );
}
