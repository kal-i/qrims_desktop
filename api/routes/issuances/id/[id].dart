import 'dart:io';

import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final connection = context.read<Connection>();
  final repository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getIssuanceById(context, repository, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getIssuanceById(
  RequestContext context,
  IssuanceRepository repository,
  String id,
) async {
  try {
    final issuance = await repository.getIssuanceById(
      id: id,
    );

    if (issuance != null) {
      final issuanceData = issuance is InventoryCustodianSlip
          ? issuance.toJson()
          : issuance is PropertyAcknowledgementReceipt
          ? issuance.toJson()
          : {'message': 'Unrecognized issuance type'};

      return Response.json(
        statusCode: 200,
        body: {'issuance': issuanceData},
      );
    }

    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'message': 'Issuance request not found.',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing get issuance information: $e',
      },
    );
  }
}
