import 'dart:io';

import 'package:api/src/issuance/models/issuance.dart';
import 'package:api/src/issuance/repository/issuance_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final issuanceRepository = IssuanceRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getIssuances(context, issuanceRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getIssuances(
  RequestContext context,
  IssuanceRepository issuanceRepository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final searchQuery = queryParams['search_query'];
    final issueDateStart = queryParams['start_date'] is String
        ? DateTime.parse(queryParams['start_date'] as String)
        : queryParams['start_date'] as DateTime?;
    final issueDateEnd = queryParams['end_date'] is String
        ? DateTime.parse(queryParams['end_date'] as String)
        : queryParams['end_date'] as DateTime?;
    final type = queryParams['type'];
    final isArchived =
        bool.tryParse(queryParams['is_archived'] ?? 'false') ?? false;

    final issuances = await issuanceRepository.getIssuances(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
      issueDateStart: issueDateStart,
      issueDateEnd: issueDateEnd,
      type: type,
      isArchived: isArchived,
    );

    final issuancesCount = await issuanceRepository.getIssuancesCount(
      searchQuery: searchQuery,
      issueDateStart: issueDateStart,
      issueDateEnd: issueDateEnd,
      type: type,
      isArchived: isArchived,
    );

    return Response.json(
      statusCode: 200,
      body: {
        'totalItemCount': issuancesCount,
        'issuances': issuances
            ?.map(
              (issuance) => issuance is InventoryCustodianSlip
                  ? issuance.toJson()
                  : issuance is PropertyAcknowledgementReceipt
                      ? issuance.toJson()
                      : issuance is RequisitionAndIssueSlip
                          ? issuance.toJson()
                          : null,
            )
            .where((issuanceJson) => issuanceJson != null)
            .toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get issuance(s) requests: $e.',
      },
    );
  }
}
