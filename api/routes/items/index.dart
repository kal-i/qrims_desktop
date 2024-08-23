import 'dart:io';

import 'package:api/src/item/item.dart';
import 'package:api/src/item/item_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = ItemRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getItems(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getItems(
  RequestContext context,
  ItemRepository repository,
) async {
  try {
    final queryParams = await context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final searchQuery = queryParams['search_query']?.trim() ?? '';
    final sortBy = queryParams['sort_by']?.trim() ?? 'id';
    final sortAscending =
        bool.tryParse(queryParams['sort_ascending'] ?? 'false') ?? false;

    final assetClassificationString = queryParams['asset_classification'];
    final assetSubClassString = queryParams['asset_sub_class'];

    final assetClassification = assetClassificationString != null
        ? AssetClassification.values.firstWhere(
            (e) => e.toString().split('.').last == assetClassificationString,
            orElse: () => AssetClassification.unknown,
          )
        : null;

    final assetSubClass = assetSubClassString != null
        ? AssetSubClass.values.firstWhere(
            (e) => e.toString().split('.').last == assetSubClassString,
            orElse: () => AssetSubClass.unknown,
          )
        : null;

    print(page);
    print(pageSize);
    print(searchQuery);
    print(sortBy);
    print(sortAscending);
    print(assetClassification);
    print(assetSubClass);

    final itemList = await repository.getItems(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
      sortBy: sortBy,
      sortAscending: sortAscending,
      classificationFilter: assetClassification,
      subClassFilter: assetSubClass,
    );

    final filteredItemsCount = await repository.getItemsFilteredCount(
      searchQuery: searchQuery,
      classificationFilter: assetClassification,
      subClassFilter: assetSubClass,
    );

    final itemsCount = await repository.getItemsCount();

    if (itemList == null) {
      return Response.json(
        body: [],
      );
    }

    print('$itemsCount');

    final itemJsonList = itemList.map((item) => item.toJson()).toList();

    return Response.json(
      statusCode: 200,
      body: {
        'totalItemCount': searchQuery.isNotEmpty ||
                assetClassification != null ||
                assetSubClass != null
            ? filteredItemsCount
            : itemsCount,
        'items': itemJsonList,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get items request.',
      },
    );
  }
}
