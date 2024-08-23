import 'package:postgres/postgres.dart';

import 'item.dart';

/// if stock don't exist, allow user to type, which means it will insert in the db
class ItemRepository {
  ItemRepository(this._conn);

  final Connection _conn;

  Future<int> registerItem({
    required ItemWithStock itemWithStock,
  }) async {
    try {
      int? stockId;

      if (itemWithStock.item.stockId == null) {
        print('null stock id');
        if (itemWithStock.stock != null) {
          final stock = itemWithStock.stock!;
          print('not null stock');
          final stockResult = await _conn.execute(
            Sql.named(
              '''
            SELECT id FROM Stocks
            WHERE product_name = @product_name
            AND description = @description;
            ''',
            ),
            parameters: {
              'product_name': stock.productName,
              'description': stock.description,
            },
          );

          print('stock res: $stockResult');

          if (stockResult.isEmpty) {
            print('stock res not empty - create new record');
            final insertStockResult = await _conn.execute(
              Sql.named(
                '''
              INSERT INTO Stocks (product_name, description)
              VALUES (@product_name, @description)
              RETURNING id;
              ''',
              ),
              parameters: {
                'product_name': stock.productName,
                'description': stock.description,
              },
            );

            stockId = insertStockResult.first[0] as int;
            print('created new record: $stockId');
          } else {
            print('existing record');
            stockId = stockResult.first[0] as int;
            print('existing record $stockId');
          }
        } else {
          print('item stock null');
          stockId = null;
        }
      } else {
        print('defined stock id');
        stockId = itemWithStock.item.stockId;
        print('defined stock id: $stockId');
      }

      print('stock id: $stockId');

      final result = await _conn.execute(
        Sql.named(
          '''
        INSERT INTO Items (
          stock_id, specification, brand, model, serial_no, manufacturer,
          asset_classification, asset_sub_class, unit, quantity,
          unit_cost, estimated_useful_life, acquired_date, encrypted_id,
          qr_code_image_data
        ) VALUES (
          @stock_id, @specification, @brand, @model, @serial_no, @manufacturer, 
          @asset_classification, @asset_sub_class, @unit, @quantity, 
          @unit_cost, @estimated_useful_life, @acquired_date, @encrypted_id, 
          @qr_code_image_data
        )
        RETURNING id
        ''',
        ),
        parameters: {
          'stock_id': stockId,
          'specification': itemWithStock.item.specification,
          'brand': itemWithStock.item.brand,
          'model': itemWithStock.item.model,
          'serial_no': itemWithStock.item.serialNo,
          'manufacturer': itemWithStock.item.manufacturer,
          'asset_classification':
              itemWithStock.item.assetClassification.toString().split('.').last,
          'asset_sub_class':
              itemWithStock.item.assetSubClass.toString().split('.').last,
          'unit': itemWithStock.item.unit.toString().split('.').last,
          'quantity': itemWithStock.item.quantity,
          'unit_cost': itemWithStock.item.unitCost,
          'estimated_useful_life': itemWithStock.item.estimatedUsefulLife,
          'acquired_date': itemWithStock.item.acquiredDate?.toIso8601String(),
          'encrypted_id': itemWithStock.item.encryptedId,
          'qr_code_image_data': itemWithStock.item.qrCodeImageData,
        },
      );

      print('default: ${itemWithStock.item.assetSubClass}');

      final int id = result.first[0] as int;
      return id;
    } catch (e) {
      print(e);
      if (e
          .toString()
          .contains('duplicate key value violates unique constraint')) {
        print('Serial no. already exists');
        throw Exception('Serial no. already exists.');
      }
      throw Exception('Error registering item: $e');
    }
  }

  Future<int> registerStock({
    required String productName,
    String? description,
  }) async {
    final result = await _conn.execute(
      Sql.named('''
    INSERT INTO Stocks (product_name, description)
    VALUES (@product_name, @description)
    RETURNING id;
    '''),
      parameters: {
        'product_name': productName,
        'description': description ?? null,
      },
    );

    return result.first[0] as int;
  }

  Future<int?> checkStockIfExist({
    int? stockId,
    String? productName,
    String? description,
  }) async {
    /// If stock id is provided, just return it
    /// Otherwise, return null
    if (stockId != null) {
      return stockId;
    }

    /// If product_name and description is not empty or null
    /// Check if product_name and description exists in the Stocks table
    /// Description won't be checked because it is nullable
    if (productName != null && productName.isNotEmpty) {
      final result = await _conn.execute(
        Sql.named(
          '''
        SELECT id FROM Stocks
        WHERE product_name = @product_name
        AND description = @description;
        ''',
        ),
        parameters: {
          'product_name': productName,
          'description': description,
        },
      );

      /// If query result is empty, register stock
      /// Otherwise, return the id from result
      if (result.isEmpty) {
        final result = registerStock(
          productName: productName,
          description: description,
        );
        return result;
      } else {
        return result.first[0] as int;
      }
    }

    return null;
  }

  Future<void> updateItemAfterInsert({
    required int id,
    required String encryptedId,
    required String qrCodeImageData,
  }) async {
    // update the item info since we already got the id from the insert query
    await _conn.execute(
      Sql.named(
        '''
        UPDATE Items
        SET encrypted_id = @encrypted_id, qr_code_image_data = @qr_code_image_data
        WHERE id = @id;
        ''',
      ),
      parameters: {
        'id': id,
        'encrypted_id': encryptedId,
        'qr_code_image_data': qrCodeImageData,
      },
    );
  }

  // I think item id, encrypted id, and quantity should not be shown
  Future<ItemWithStock?> getItemByEncryptedId({
    required String encryptedId,
  }) async {
    final results = await _conn.execute(
        Sql.named(
          '''
          SELECT
            i.*,
            s.product_name,
            s.description
          FROM
            Items i
          LEFT JOIN
            Stocks s ON i.stock_id = s.id
          WHERE
            i.encrypted_id = @encrypted_id
          ''',
        ),
        parameters: {
          'encrypted_id': encryptedId,
        });

    print('results: ${results.first[0]}');

    for (final row in results) {
      int i = 0;
      print('row ${i++}: ${row[i]}');
      final itemWithStockMap = {
        'item_id': row[0],
        'specification': row[1],
        'brand': row[2],
        'model': row[3],
        'serial_no': row[4],
        'manufacturer': row[5],
        'asset_classification': row[6],
        'asset_sub_class': row[7],
        'unit': row[8],
        'quantity': row[9],
        'unit_cost': row[10],
        'estimated_useful_life': row[11],
        'acquired_date': row[12],
        'encrypted_id': row[13],
        'qr_code_image_data': row[14],
        'stock_id': row[15],
        'product_name': row[16],
        'description': row[17],
      };
      return ItemWithStock.fromJson(itemWithStockMap);
    }
    return null;
  }

  Future<int> getItemsCount() async {
    try {
      final result = await _conn.execute(
        Sql('''
        SELECT COUNT(*) FROM Items;
        '''),
      );

      print('unfiltered items count: $result');
      return result.first[0] as int;
    } catch (e) {
      throw Exception('Failed to fetch user count. ${e.toString()}');
    }
  }

  Future<int> getItemsFilteredCount({
    String? searchQuery,
    AssetClassification? classificationFilter,
    AssetSubClass? subClassFilter,
  }) async {
    try {
      final int? searchQueryAsInt =
          searchQuery != null ? int.tryParse(searchQuery) : null;

      final baseQuery = '''
      SELECT
        COUNT(*)
      FROM
        Items i
      LEFT JOIN
        Stocks s ON i.stock_id = s.id
      ''';

      final whereClause = StringBuffer();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write('''
          WHERE 
            i.id = @search_query_as_int OR 
            i.brand ILIKE @search_query OR
            i.model ILIKE @search_query OR
            i.specification ILIKE @search_query OR
            i.serial_no ILIKE @search_query OR
            i.manufacturer ILIKE @search_query OR
            s.product_name ILIKE @search_query
          ''');
      }

      if (classificationFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('i.asset_classification = @classification_filter');
      }

      if (subClassFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('i.asset_sub_class = @sub_class_filter');
      }

      final finalQuery = '''
      $baseQuery
      $whereClause
      ''';

      final params = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['search_query'] = '%$searchQuery%';
        params['search_query_as_int'] = searchQueryAsInt;
      }

      if (classificationFilter != null) {
        params['classification_filter'] =
            classificationFilter.toString().split('.').last;
      }

      if (subClassFilter != null) {
        params['sub_class_filter'] = subClassFilter.toString().split('.').last;
      }

      final result = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      if (result.isNotEmpty) {
        final count = result.first[0] as int;
        print('Total no. of filtered items: $count');
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error fetching items: $e');
      throw Exception('Failed to fetch users.');
    }
  }

  Future<List<ItemWithStock>?> getItems({
    String? searchQuery,
    required int page,
    required int pageSize,
    String sortBy = 'id',
    bool sortAscending = false,
    AssetClassification? classificationFilter,
    AssetSubClass? subClassFilter,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final itemList = <ItemWithStock>[];
      final int? searchQueryAsInt =
          searchQuery != null ? int.tryParse(searchQuery) : null;

      // working fine
      final validSortColumn = {
        'id',
        'quantity',
        'unit_cost',
        'estimated_useful_life',
        'acquired_date'
      };
      if (!validSortColumn.contains(sortBy)) {
        throw ArgumentError('Invalid sort column: $sortBy');
      }

      final baseQuery = '''
      SELECT
        i.*,
        s.product_name,
        s.description
      FROM
        Items i
      LEFT JOIN
        Stocks s ON i.stock_id = s.id
      ''';

      final whereClause = StringBuffer();
      // There really is no problem in the search query, except for the fact that it is confuse between id and serial no.
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write('''
          WHERE
            i.id = @search_query_as_int OR
            i.brand ILIKE @search_query OR
            i.model ILIKE @search_query OR
            i.specification ILIKE @search_query OR
            i.serial_no ILIKE @search_query OR
            i.manufacturer ILIKE @search_query OR
            s.product_name ILIKE @search_query
          ''');
      }

      if (classificationFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('i.asset_classification = @classification_filter');
      }

      if (subClassFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('i.asset_sub_class = @sub_class_filter');
      }

      final sortDirection = sortAscending ? 'ASC' : 'DESC';
      print('sort dir: $sortDirection');

      final finalQuery = '''
      $baseQuery
      $whereClause
      ORDER BY
        $sortBy $sortDirection
      LIMIT @page_size OFFSET @offset;
      ''';

      final params = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['search_query'] = '%$searchQuery%';
        params['search_query_as_int'] = searchQueryAsInt;
      }

      if (classificationFilter != null) {
        params['classification_filter'] =
            classificationFilter.toString().split('.').last;
      }

      if (subClassFilter != null) {
        params['sub_class_filter'] = subClassFilter.toString().split('.').last;
      }

      params['page_size'] = pageSize;
      params['offset'] = offset;

      print('final query: $finalQuery');
      print('params: $params');

      final results = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      print('raw res: $results');

      for (final row in results) {
        final itemMap = {
          'item_id': row[0],
          'specification': row[1],
          'brand': row[2],
          'model': row[3],
          'serial_no': row[4],
          'manufacturer': row[5],
          'asset_classification': row[6],
          'asset_sub_class': row[7],
          'unit': row[8],
          'quantity': row[9],
          'unit_cost': row[10],
          'estimated_useful_life': row[11],
          'acquired_date': row[12],
          'encrypted_id': row[13],
          'qr_code_image_data': row[14],
          'stock_id': row[15],
          'product_name': row[16],
          'description': row[17],
        };
        itemList.add(ItemWithStock.fromJson(itemMap));
      }
      print('Fetched items for page $page: ${itemList.length}');
      return itemList;
    } catch (e) {
      print('Error fetching items: $e');
      throw Exception('Failed to fetch users.');
    }
  }

  Future<ItemWithStock?> getItemById({
    required int id,
  }) async {
    try {
      final result = await _conn.execute(
        Sql.named(
          '''
          SELECT
            i.*,
            s.product_name,
            s.description
          FROM
            Items i
          LEFT JOIN
            Stocks s ON i.stock_id = s.id
          WHERE 
            i.id = @id;
          ''',
        ),
        parameters: {
          'id': id,
        },
      );

      if (result.isNotEmpty) {
        for (final row in result) {
          final itemMap = {
            'item_id': row[0],
            'specification': row[1],
            'brand': row[2],
            'model': row[3],
            'serial_no': row[4],
            'manufacturer': row[5],
            'asset_classification': row[6],
            'asset_sub_class': row[7],
            'unit': row[8],
            'quantity': row[9],
            'unit_cost': row[10],
            'estimated_useful_life': row[11],
            'acquired_date': row[12],
            'encrypted_id': row[13],
            'qr_code_image_data': row[14],
            'stock_id': row[15],
            'product_name': row[16],
            'description': row[17],
          };

          return ItemWithStock.fromJson(itemMap);
        }
      }
      throw Exception('Item not found.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool?> updateItemInformation({
    required int id,
    String? productName,
    String? description,
    String? specification,
    String? brand,
    String? model,
    String? serialNo,
    String? manufacturer,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    String? unit,
    int? quantity,
    double? unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  }) async {
    try {
      final List<String> setClauses = [];
      final Map<String, dynamic> parameters = {
        'id': id,
      };

      int? stockId;

      if (productName != null && productName.isNotEmpty) {
        stockId = await checkStockIfExist(
          productName: productName,
          description: description,
        );

        if (stockId != null) {
          setClauses.add('stock_id = @stock_id');
          parameters['stock_id'] = stockId;
        }
      }

      if (specification != null) {
        setClauses.add('specification = @specification');
        parameters['specification'] = specification;
      }

      if (brand != null) {
        setClauses.add('brand = @brand');
        parameters['brand'] = brand;
      }

      if (model != null) {
        setClauses.add('model = @model');
        parameters['model'] = model;
      }

      if (serialNo != null) {
        setClauses.add('serial_no = @serial_no');
        parameters['serial_no'] = serialNo;
      }

      if (manufacturer != null) {
        setClauses.add('manufacturer = @manufacturer');
        parameters['manufacturer'] = manufacturer;
      }

      if (assetClassification != null) {
        setClauses.add('asset_classification = @asset_classification');
        parameters['asset_classification'] =
            assetClassification.toString().split('.').last;
      }

      if (assetSubClass != null) {
        setClauses.add('asset_sub_class = @asset_sub_class');
        parameters['asset_sub_class'] =
            assetSubClass.toString().split('.').last;
      }

      if (unit != null) {
        setClauses.add('unit = @unit');
        parameters['unit'] = unit;
      }

      if (quantity != null) {
        setClauses.add('quantity = @quantity');
        parameters['quantity'] = quantity;
      }

      if (unitCost != null) {
        setClauses.add('unit_cost = @unit_cost');
        parameters['unit_cost'] = unitCost;
      }

      if (estimatedUsefulLife != null) {
        setClauses.add('estimated_useful_life = @estimated_useful_life');
        parameters['estimated_useful_life'] = estimatedUsefulLife;
      }

      if (acquiredDate != null) {
        setClauses.add('acquired_date = @acquired_date');
        parameters['acquired_date'] = acquiredDate;
      }

      if (setClauses.isEmpty) {
        return false;
      }

      final setClause = setClauses.join(', ');

      final result = await _conn.execute(
        Sql.named(
          '''
        UPDATE Items
        SET $setClause
        WHERE id = @id;
        ''',
        ),
        parameters: parameters,
      );

      return result.affectedRows == 1;
    } catch (e) {
      if (e.toString().contains(
          'duplicate key value violates unique constraints "items_serial_no_key"')) {
        throw Exception('Serial no. already exists.');
      }
      throw Exception('Error registering item: $e');
    }
  }

  Future<List<Stock>?> getStockInformation({
    String? productName,
    String? description,
  }) async {
    final stockList = <Stock>[];

    final baseQuery = '''
    SELECT * FROM Stocks
    ''';

    final whereClause = StringBuffer();
    final parameters = <String, dynamic>{};

    if (productName != null && productName.isNotEmpty) {
      whereClause.write(' WHERE product_name = @product_name');
      parameters['product_name'] = productName;
    }

    if (description != null && description.isNotEmpty) {
      whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
      whereClause.write('description = @description');
      parameters['description'] = description;
    }

    final finalQuery = '$baseQuery$whereClause ORDER BY product_name ASC';

    final results = await _conn.execute(
      Sql.named(
        finalQuery,
      ),
      parameters: parameters,
    );

    for (final row in results) {
      final stockMap = {
        'stock_id': row[0],
        'product_name': row[1],
        'description': row[2],
      };
      stockList.add(Stock.fromJson(stockMap));
    }

    return stockList;
  }

  Future<Stock?> getStockById({
    required int id,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT * FROM Stocks
        WHERE id = @id;
        ''',
      ),
      parameters: {
        'id': id,
      },
    );

    if (result.isNotEmpty) {
      for (final row in result) {
        final stockMap = {
          'stock_id': row[0],
          'product_name': row[1],
          'description': row[2],
        };

        return Stock.fromJson(stockMap);
      }
    }
    return null;
  }

  Future<int> getStocksProductNameFilteredCount({
    String? productName,
  }) async {
    Map<String, dynamic> param = {};
    String baseQuery = '''
    SELECT COUNT(DISTINCT product_name) FROM Stocks
    ''';

    if (productName != null && productName.isNotEmpty) {
      baseQuery += 'WHERE product_name ILIKE @product_name';
      param['product_name'] = '%$productName%';
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: param,
    );

    return result.first[0] as int;
  }

  Future<List<String>?> getStocksProductName({
    required int page,
    required int pageSize,
    String? productName,
  }) async {
    final offset = (page - 1) * pageSize;
    final productNames = <String>[];
    final Map<String, dynamic> params = {};

    String baseQuery = '''
      SELECT DISTINCT product_name FROM Stocks
      ''';

    if (productName != null && productName.isNotEmpty) {
      baseQuery += ' WHERE product_name ILIKE @product_name';
      params['product_name'] = '%$productName%';
    }

    params['page_size'] = pageSize;
    params['offset'] = offset;
    final results = await _conn.execute(
      Sql.named(
        '''
        $baseQuery
        ORDER BY product_name ASC LIMIT @page_size OFFSET @offset
        ''',
      ),
      parameters: params,
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        productNames.add(row[0] as String);
      }
      return productNames;
    }
    return null;
  }

  Future<int> getStocksDescriptionFilteredCount({
    required String productName,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT COUNT(description) FROM Stocks
        WHERE product_name ILIKE @product_name;
        ''',
      ),
      parameters: {
        'product_name': '%$productName%',
      },
    );

    return result.first[0] as int;
  }

  Future<List<String>?> getStocksDescription({
    required int page,
    required int pageSize,
    required String productName,
  }) async {
    final offset = (page - 1) * pageSize;
    final descriptions = <String>[];

    final results = await _conn.execute(
      Sql.named('''
      SELECT description FROM Stocks 
      WHERE product_name ILIKE @product_name
      LIMIT @page_size OFFSET @offset;
      '''),
      parameters: {
        'product_name': '%$productName%',
        'page_size': pageSize,
        'offset': offset,
      },
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        descriptions.add(row[0] as String);
      }
      return descriptions;
    }
    return null;
  }
}
