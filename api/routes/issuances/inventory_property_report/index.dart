import 'dart:io';

import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:api/src/item/models/item.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getInventoryItems(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getInventoryItems(
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
    final assetSubClass = queryParams['asset_sub_class'] != null
        ? AssetSubClass.values.firstWhere(
            (e) =>
                e.toString().split('.').last == queryParams['asset_sub_class'],
          )
        : null;
    final fundCluster = queryParams['fund_cluster'] != null
        ? FundCluster.values.firstWhere(
            (e) => e.toString().split('.').last == queryParams['fund_cluster'],
          )
        : null;

    final inventoryProperty = await repository.getInventoryPropertyReport(
      startDate: startDate,
      endDate: endDate,
      unitCost: 50001.0,
      assetSubClass: assetSubClass,
      fundCluster: fundCluster,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'inventory_property': inventoryProperty,
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
