import 'dart:io';

import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:api/src/item/models/item.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getInventoryEquipment(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getInventoryEquipment(
  RequestContext context,
  IssuanceRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;

    print(queryParams);
    final startDate = queryParams['start_date'] is String
        ? DateTime.parse(queryParams['start_date'] as String)
        : queryParams['start_date'] as DateTime;
    final endDate = queryParams['end_date'] is String
        ? DateTime.parse(queryParams['end_date'] as String)
        : queryParams['end_date'] as DateTime?;

    final inventoryProperty = await repository.getInventoryPropertyReport(
      startDate: startDate,
      endDate: endDate,
      unitCost: 50000.0,
      assetSubClass: queryParams['asset_sub_class'] != null
          ? AssetSubClass.values.firstWhere(
              (e) =>
                  e.toString().split('.').last ==
                  queryParams['asset_sub_class'],
            )
          : null,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'inventory_semi_expendable_property': inventoryProperty,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get issuance(s) requests: $e',
      },
    );
  }
}
