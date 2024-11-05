import 'dart:io';

import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final connection = context.read<Connection>();
  final prRepository = PurchaseRequestRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getPurchaseRequestInformation(context, prRepository, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getPurchaseRequestInformation(
  RequestContext context,
  PurchaseRequestRepository prRepository,
  String id,
) async {
  try {
    final purchaseRequest = await prRepository.getPurchaseRequestById(
      id: id,
    );

    if (purchaseRequest != null) {
      return Response.json(
        statusCode: 200,
        body: {
          'purchase_request': purchaseRequest.toJson(),
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'message': 'Purchase request not found.',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing get purchase request information: $e',
      },
    );
  }
}
