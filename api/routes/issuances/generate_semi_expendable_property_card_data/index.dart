import 'dart:io';

import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getSemiExpendablePropertyCardData(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getSemiExpendablePropertyCardData(
  RequestContext context,
  IssuanceRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final icsId = queryParams['ics_id'] as String;
    final fundCluster = queryParams['fund_cluster'];

    final semiExpendablePropertyCardData =
        await repository.generateSemiExpendablePropertyCardData(
      icsId: icsId,
      fundCluster: FundCluster.values
          .firstWhere((e) => e.toString().split('.').last == fundCluster),
    );

    return Response.json(
      statusCode: 200,
      body: {
        'semi_expendable_property_card_data': semiExpendablePropertyCardData,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message':
            'Error processing the get semi expendable property card data: $e',
      },
    );
  }
}
