import 'dart:io';

import 'package:api/src/item/models/item.dart';
import 'package:api/src/item/repository/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final connection = context.read<Connection>();
  final repository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getItemById(context, repository, id),
    HttpMethod.patch => _updateItemInformation(context, repository, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getItemById(
  RequestContext context,
  ItemRepository repository,
  String id,
) async {
  try {
    final item = await repository.getItemById(id: id);

    if (item != null) {
      return Response.json(
        statusCode: 200,
        body: {
          'item': item is Supply
              ? item.toJson()
              : item is InventoryItem
                  ? item.toJson()
                  : null,
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'message': 'Item not found.',
      },
    );
  } catch (e) {
    return Response.json(
      body: {
        'message': e.toString(),
      },
    );
  }
}

Future<Response> _updateItemInformation(
  RequestContext context,
  ItemRepository repository,
  String id,
) async {
  final json = await context.request.json() as Map<String, dynamic>;
  final productName = json['product_name'] as String?;
  final description = json['description'] as String?;
  final manufacturerName = json['manufacturer_name'] as String?;
  final brandName = json['brand_name'] as String?;
  final modelName = json['model_name'] as String?;
  final serialNo = json['serial_no'] as String?;
  final specification = json['specification'] as String?;
  final assetClassification = json['asset_classification'] != null
      ? AssetClassification.values.firstWhere((assetClassification) =>
          assetClassification.toString().split('.').last ==
          (json['asset_classification'] as String))
      : null;
  final assetSubClass = json['asset_sub_class'] != null
      ? AssetSubClass.values.firstWhere((assetSubClass) =>
          assetSubClass.toString().split('.').last ==
          (json['asset_sub_class'] as String))
      : null;
  final unit = json['unit'] != null
      ? Unit.values.firstWhere(
          (unit) => unit.toString().split('.').last == (json['unit'] as String))
      : null;
  final quantity = json['quantity'] as int?;
  final unitCost = json['unit_cost'] as double?;
  final estimatedUsefulLife = json['estimated_useful_life'] as int?;
  final acquiredDate = json['acquired_date'] is String
      ? DateTime.parse(json['acquired_date'] as String)
      : json['acquired_date'] as DateTime?;

  final result = await repository.updateItemInformation(
    id: id,
    productName: productName,
    description: description,
    specification: specification,
    unit: unit,
    quantity: quantity,
    manufacturerName: manufacturerName,
    brandName: brandName,
    modelName: modelName,
    serialNo: serialNo,
    assetClassification: assetClassification,
    assetSubClass: assetSubClass,
    unitCost: unitCost,
    estimatedUsefulLife: estimatedUsefulLife,
    acquiredDate: acquiredDate,
  );

  if (result == true) {
    return Response.json(
      statusCode: 200,
      body: {
        'message': 'Item $id is updated successfully.',
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
