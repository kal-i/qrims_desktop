import 'dart:io';

import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final connection = context.read<Connection>();
  final issuanceRepository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.patch =>
      _updateIssuanceArchiveStatus(context, issuanceRepository, id),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed))
  };
}

Future<Response> _updateIssuanceArchiveStatus(
  RequestContext context,
  IssuanceRepository issuanceRepository,
  String id,
) async {
  final json = await context.request.json() as Map<String, dynamic>;
  final isArchived = json['is_archived'] as bool;

  print(id);
  print(isArchived);

  final result = await issuanceRepository.updateIssuanceArchiveStatus(
    id: id,
    isArchived: isArchived,
  );

  if (result == true) {
    return Response.json(
      statusCode: 200,
      body: {
        'message':
        'Officer #$id\'s  archive status has been updated to $isArchived.',
      },
    );
  } else {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Failed to update officer archive status.',
      },
    );
  }
}
