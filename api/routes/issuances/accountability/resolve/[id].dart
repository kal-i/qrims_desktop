import 'dart:io';

import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  final connection = await context.read<Connection>();
  final issuanceRepository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.patch => _updateIssuanceItem(
        context,
        issuanceRepository,
        id,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _updateIssuanceItem(
  RequestContext context,
  IssuanceRepository repository,
  String id,
) async {
  try {
    final json = await context.request.json();
    final statusRaw = json['status'];
    final dateRaw = json['date'];
    final remarks = json['remarks'] as String?;

    final status = IssuanceItemStatus.values.firstWhere(
      (e) => e.toString().split('.').last == statusRaw,
      orElse: () => throw FormatException('Invalid status value: $statusRaw'),
    );

    final date =
        dateRaw is String ? DateTime.tryParse(dateRaw) : dateRaw as DateTime?;
    if (date == null) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid or missing date.'},
      );
    }

    // loop if have multiple ids
    final success = await repository.updateIssuanceItemEntityStatus(
      baseItemId: id,
      status: status,
      date: date,
      remarks: remarks,
    );

    if (success) {
      return Response.json(
        statusCode: 200,
        body: {'message': 'Issuance item updated successfully.'},
      );
    } else {
      return Response.json(
        statusCode: 500,
        body: {'error': 'Failed to update issuance item.'},
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'An error occurred: ${e.toString()}'},
    );
  }
}
