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
  final decodedId = Uri.decodeComponent(id);

  return switch (context.request.method) {
    HttpMethod.get => _getItemByEncryptedId(context, repository, decodedId),
    HttpMethod.patch => _updateItemInformation(context, repository, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getItemByEncryptedId(
  RequestContext context,
  ItemRepository repository,
  String id,
) async {
  try {
    print(id);
    final item = await repository.getItemByEncryptedId(encryptedId: id);
    if (item != null) {
      return Response.json(
        statusCode: 200,
        body: {
          'item': item.toJson(),
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
    print(e);
    return Response.json(
      statusCode: HttpStatus.internalServerError,
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

  print(productName);
  print(description);
  print(manufacturerName);
  print(brandName);
  print(modelName);

  final result = await repository.updateItemInformation(
    id: id,
    productName: productName,
    description: description,
    manufacturerName: manufacturerName,
    brandName: brandName,
    modelName: modelName,
    serialNo: serialNo,
    specification: specification,
    assetClassification: assetClassification,
    assetSubClass: assetSubClass,
    unit: unit,
    quantity: quantity,
    unitCost: unitCost,
    estimatedUsefulLife: estimatedUsefulLife,
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
