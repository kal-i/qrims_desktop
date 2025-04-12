import 'dart:io';

import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getInventorySupply(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getInventorySupply(
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
    final fundCluster = queryParams['fund_cluster'] != null
        ? FundCluster.values.firstWhere(
            (e) => e.toString().split('.').last == queryParams['fund_cluster'],
          )
        : null;

    final inventorySupply = await repository.getInventorySupplyReport(
      startDate: startDate,
      endDate: endDate,
      fundCluster: fundCluster,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'inventory_supply': inventorySupply,
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
