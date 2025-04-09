import 'dart:io';

import 'package:api/src/item/repository/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final itemRepository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getSummaryInformation(
        context,
        itemRepository,
      ),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getSummaryInformation(
  RequestContext context,
  ItemRepository itemRepository,
) async {
  try {
    final weeklyTrends = await itemRepository.getWeeklyTrendsWithPercentage();
    final stockLevels = await itemRepository.getInventoryStockLevels();
    final suppliesCount = await itemRepository.getSuppliesCount();
    final inventoryCount = await itemRepository.getInventoryItemCount();

    return Response.json(
      body: {
        'weekly_trends': weeklyTrends,
        'stock_levels': stockLevels,
        'supplies_count': suppliesCount,
        'inventory_count': inventoryCount,
      },
    );
  } catch (e) {
    return Response.json(
      body: {
        'message': 'Error processing summary information: $e',
      },
    );
  }
}
