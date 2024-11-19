import 'package:api/src/utils/encryption_utils.dart';
import 'package:api/src/utils/generate_id.dart';
import 'package:api/src/utils/qr_code_utils.dart';
import 'package:postgres/postgres.dart';

import '../models/item.dart';

class ItemRepository {
  ItemRepository(this._conn);

  final Connection _conn;

  Future<String> _generateUniqueProductNameId() async {
    while (true) {
      final productNameId = generatedId('PRDCTNM');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM ProductNames Where id = @id;
        '''),
        parameters: {
          'id': productNameId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return productNameId;
      }
    }
  }

  Future<String> _generateUniqueProductDescriptionId() async {
    while (true) {
      final productDescriptionId = generatedId('PRDCTDSCRPTON');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM ProductDescriptions Where id = @id;
        '''),
        parameters: {
          'id': productDescriptionId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return productDescriptionId;
      }
    }
  }

  Future<String> _generateUniqueItemId(String itemName) async {
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    // Format the item name: remove spaces and capitalize each word's first letter
    final formattedItemName = itemName
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join('');

    print('Current year-month: $yearMonth for item: $itemName');

    // Step 1: Fetch the latest record for the month to get cumulative count
    final monthResult = await _conn.execute(
      Sql.named(
        '''
    SELECT id FROM Items
    WHERE id LIKE '%-' || @year_month || '-%'
    ORDER BY id DESC
    LIMIT 1;
    ''',
      ),
      parameters: {
        'year_month': '%$yearMonth%',
      },
    );
    print('month result: ${monthResult}');
    // we need to extract the

    int cumulativeCount;
    if (monthResult.isNotEmpty) {
      final extractedResult =
          monthResult.first[0].toString().split('-').last.split('(').first;
      print('month result is not empty: ${monthResult.first[0]}');
      print('extracted result: $extractedResult');
      print('extracted result after + 1: ${int.parse(extractedResult) + 1}');
      cumulativeCount = int.parse(monthResult.first[0]
              .toString()
              .split('-')
              .last
              .split('(')
              .first) +
          1;
    } else {
      cumulativeCount = 1;
    }
    print('cumulative count: $cumulativeCount');

    // Step 2: Fetch the latest record for the specific item this month
    final itemResult = await _conn.execute(
      Sql.named(
        '''
    SELECT id FROM Items
    WHERE id ILIKE @item_name || '-' || @year_month || '-%'
    ORDER BY id DESC
    LIMIT 1;
    ''',
      ),
      parameters: {
        'item_name': itemName,
        'year_month': yearMonth,
      },
    );
    print('item result: $itemResult');

    int itemSpecificCount;
    if (itemResult.isNotEmpty && itemResult.first[0] != null) {
      itemSpecificCount = int.parse(itemResult.first[0]
              .toString()
              .split('(')
              .last
              .replaceAll(')', '')) +
          1;
    } else {
      itemSpecificCount = 1;
    }
    print('item specific count: $itemSpecificCount');

    // Construct the unique ID with zero-padded cumulative count
    final uniqueId =
        '$formattedItemName-$yearMonth-${cumulativeCount.toString().padLeft(3, '0')}($itemSpecificCount)';
    print('Generated unique ID: $uniqueId');
    return uniqueId;
  }

  // Future<String> _generateUniqueItemId() async {
  //   while (true) {
  //     final itemId = generatedId('ITM');
  //
  //     final result = await _conn.execute(
  //       Sql.named('''
  //       SELECT COUNT(id) FROM Items Where id = @id;
  //       '''),
  //       parameters: {
  //         'id': itemId,
  //       },
  //     );
  //
  //     final count = result.first[0] as int;
  //
  //     if (count == 0) {
  //       return itemId;
  //     }
  //   }
  // }

  Future<String> _generateUniqueManufacturerId() async {
    while (true) {
      final manufacturerId = generatedId('MNFCTR');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM Manufacturers Where id = @id;
        '''),
        parameters: {
          'id': manufacturerId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return manufacturerId;
      }
    }
  }

  Future<String> _generateUniqueBrandId() async {
    while (true) {
      final brandId = generatedId('BRND');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM Brands Where id = @id;
        '''),
        parameters: {
          'id': brandId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return brandId;
      }
    }
  }

  Future<String> _generateUniqueModelId() async {
    while (true) {
      final modelId = generatedId('MDL');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM Models Where id = @id;
        '''),
        parameters: {
          'id': modelId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return modelId;
      }
    }
  }

  Future<String> registerItemWithStock({
    required String productName,
    String? description,
    required String manufacturerName,
    required String brandName,
    required String modelName,
    String? serialNo,
    required String specification,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    required Unit unit,
    required int quantity,
    required double unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  }) async {
    try {
      /// generate an item id
      final itemId = await _generateUniqueItemId(productName);
      print('item id: $itemId');

      /// generate encrypted id
      final encryptedId = await EncryptionUtils.encryptId(itemId);
      print('encrypted id: $encryptedId');

      /// generate base 64 String qr code image data
      final qrCodeImageData = await QrCodeUtils.generateQRCode(encryptedId);
      print('qr data id: $qrCodeImageData');

      String? productNameId;
      String? productDescriptionId;
      String? manufacturerId;
      String? brandId;
      String? modelId;

      final productNameResult = await checkProductNameIfExist(
        productName: productName,
      );

      if (productNameResult != null) {
        productNameId = productNameResult;
      } else {
        productNameId = await registerProductName(
          productName: productName,
        );
      }
      print('product name id: $productNameId');

      final productDescriptionResult = await checkProductDescriptionIfExist(
        productDescription: description,
      );

      if (productDescriptionResult != null) {
        productDescriptionId = productDescriptionResult;
      } else {
        productDescriptionId = await registerProductDescription(
          productDescription: description,
        );
      }
      print('product name id: $productDescriptionId');

      final productStockResult = await checkProductStockIfExist(
        productNameId: productNameId,
        productDescriptionId: productDescriptionId,
      );

      if (productStockResult == 0) {
        await registerProductStock(
          productNameId: productNameId,
          productDescriptionId: productDescriptionId,
        );
      }
      print('saved product stock!');

      /// check if manufacturer exists
      final manufacturerResult = await checkManufacturerIfExist(
        manufacturerName: manufacturerName,
      );

      if (manufacturerResult != null) {
        manufacturerId = manufacturerResult;
      } else {
        manufacturerId = await registerManufacturer(
          manufacturerName: manufacturerName,
        );
      }
      print('manufacturer id: $manufacturerId');

      /// check if brand exists
      final brandResult = await checkBrandIfExist(
        brandName: brandName,
      );
      if (brandResult != null) {
        brandId = brandResult;
      } else {
        brandId = await registerBrand(
          brandName: brandName,
        );
      }
      print('brand id: $brandId');

      final manufacturerBrandResult = await checkManufacturerBrandIfExist(
        manufacturerId: manufacturerId,
        brandId: brandId,
      );

      if (manufacturerBrandResult == 0) {
        await registerManufacturerBrand(
          manufacturerId: manufacturerId,
          brandId: brandId,
        );
      }

      /// check if model exists
      final modelResult = await checkModelIfExist(
        productNameId: productNameId,
        brandId: brandId,
        modelName: modelName,
      );

      if (modelResult != null) {
        modelId = modelResult;
      } else {
        modelId = await registerModel(
          productNameId: productNameId,
          brandId: brandId,
          modelName: modelName,
        );
      }
      print('model id: $modelId');

      await _conn.execute(
        Sql.named(
          '''
        INSERT INTO Items (
          id, product_name_id, product_description_id, manufacturer_id, brand_id, model_id, serial_no, specification,
          asset_classification, asset_sub_class, unit, quantity,
          unit_cost, estimated_useful_life, acquired_date, encrypted_id,
          qr_code_image_data
        ) VALUES (
          @id, @product_name_id, @product_description_id, @manufacturer_id, @brand_id, @model_id, @serial_no, @specification,
          @asset_classification, @asset_sub_class, @unit, @quantity, 
          @unit_cost, @estimated_useful_life, @acquired_date, @encrypted_id, 
          @qr_code_image_data
        );
        ''',
        ),
        parameters: {
          'id': itemId,
          'product_name_id': productNameId,
          'product_description_id': productDescriptionId,
          'manufacturer_id': manufacturerId,
          'brand_id': brandId,
          'model_id': modelId,
          'serial_no': serialNo,
          'specification': specification,
          'asset_classification':
              assetClassification.toString().split('.').last,
          'asset_sub_class': assetSubClass.toString().split('.').last,
          'unit': unit.toString().split('.').last,
          'quantity': quantity,
          'unit_cost': unitCost,
          'estimated_useful_life': estimatedUsefulLife,
          'acquired_date': acquiredDate,
          'encrypted_id': encryptedId,
          'qr_code_image_data': qrCodeImageData,
        },
      );

      return encryptedId;
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

  Future<String> registerProductName({
    required String productName,
  }) async {
    final productNameId = await _generateUniqueProductNameId();

    await _conn.execute(
      Sql.named('''
      INSERT INTO ProductNames (id, name)
      VALUES (@id, @name)
    '''),
      parameters: {
        'id': productNameId,
        'name': productName,
      },
    );

    return productNameId;
  }

  Future<String?> checkProductNameIfExist({
    required String productName,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
        SELECT id FROM ProductNames WHERE name ILIKE @name;
      '''),
      parameters: {
        'name': productName,
      },
    );

    if (checkIfExists.isEmpty) {
      print('product name result is empty');
      return null;
      //return await registerProductName(productName: productName);
    } else {
      print('product name result is not empty: $checkIfExists');
      return checkIfExists.first[0] as String;
    }
  }

  Future<String> registerProductDescription({
    String? productDescription,
  }) async {
    final productDescriptionId = await _generateUniqueProductDescriptionId();

    await _conn.execute(
      Sql.named('''
      INSERT INTO ProductDescriptions (id, description)
      VALUES (@id, @description)
    '''),
      parameters: {
        'id': productDescriptionId,
        'description': productDescription,
      },
    );

    return productDescriptionId;
  }

  Future<String?> checkProductDescriptionIfExist({
    String? productDescription,
  }) async {
    final checkIfExists = productDescription == null
        ? await _conn.execute(
            Sql.named('''
          SELECT id FROM ProductDescriptions WHERE description IS NULL;
        '''),
          )
        : await _conn.execute(
            Sql.named('''
          SELECT id FROM ProductDescriptions WHERE description ILIKE @description;
        '''),
            parameters: {
              'description': productDescription,
            },
          );

    if (checkIfExists.isEmpty) {
      print('product desc result is empty');
      return null;
      // return await registerProductDescription(
      //   productDescription: productDescription,
      // );
    } else {
      print('product desc result is not empty: $checkIfExists');
      return checkIfExists.first[0] as String;
    }
  }

  Future<void> registerProductStock({
    required String productNameId,
    required String productDescriptionId,
  }) async {
    await _conn.execute(
      Sql.named('''
      INSERT INTO ProductStocks (product_name_id, product_description_id)
      VALUES (@product_name_id, @product_description_id)
    '''),
      parameters: {
        'product_name_id': productNameId,
        'product_description_id': productDescriptionId,
      },
    );
  }

  Future<int> checkProductStockIfExist({
    required String productNameId,
    required String productDescriptionId,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
      SELECT COUNT(*) FROM ProductStocks WHERE product_name_id = @product_name_id AND product_description_id = @product_description_id;
    '''),
      parameters: {
        'product_name_id': productNameId,
        'product_description_id': productDescriptionId,
      },
    );

    return checkIfExists.first[0] as int;
    // final count = checkIfExists.first[0] as int;

    // if (count == 0) {
    //   print('product stock result is empty');
    //   await registerProductStock(
    //     productNameId: productNameId,
    //     productDescriptionId: productDescriptionId,
    //   );
    // } else {
    //   print('product stock result is not empty: $checkIfExists');
    // }
  }

  Future<String> registerManufacturer({
    required String manufacturerName,
  }) async {
    final manufacturerId = await _generateUniqueManufacturerId();

    await _conn.execute(
      Sql.named('''
      INSERT INTO Manufacturers (id, name)
      VALUES (@id, @name)
    '''),
      parameters: {
        'id': manufacturerId,
        'name': manufacturerName,
      },
    );

    return manufacturerId;
  }

  Future<String?> checkManufacturerIfExist({
    required String manufacturerName,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
        SELECT id FROM Manufacturers WHERE name ILIKE @name;
      '''),
      parameters: {
        'name': manufacturerName,
      },
    );

    if (checkIfExists.isEmpty) {
      print('manufacturer result is empty');
      return null;
      //return await registerManufacturer(manufacturerName: manufacturerName);
    } else {
      print('manufacturer result is not empty: $checkIfExists');
      return checkIfExists.first[0] as String;
    }
  }

  Future<String> registerBrand({required String brandName}) async {
    final brandId = await _generateUniqueBrandId();

    await _conn.execute(
      Sql.named('''
      INSERT INTO Brands (id, name)
      VALUES (@id, @name)
    '''),
      parameters: {
        'id': brandId,
        'name': brandName,
      },
    );

    return brandId;
  }

  Future<String?> checkBrandIfExist({
    required String brandName,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
      SELECT id FROM Brands WHERE name ILIKE @name;
    '''),
      parameters: {
        'name': brandName,
      },
    );

    if (checkIfExists.isEmpty) {
      print('brand result is empty');
      return null;
      //return await registerBrand(brandName: brandName);
    } else {
      print('brand result is not empty: $checkIfExists');
      return checkIfExists.first[0] as String;
    }
  }

  Future<void> registerManufacturerBrand({
    required String manufacturerId,
    required String brandId,
  }) async {
    await _conn.execute(
      Sql.named('''
      INSERT INTO ManufacturerBrands (manufacturer_id, brand_id)
      VALUES (@manufacturer_id, @brand_id)
    '''),
      parameters: {
        'manufacturer_id': manufacturerId,
        'brand_id': brandId,
      },
    );
  }

  Future<int> checkManufacturerBrandIfExist({
    required String manufacturerId,
    required String brandId,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
      SELECT COUNT(*) FROM ManufacturerBrands WHERE manufacturer_id = @manufacturer_id AND brand_id = @brand_id;
    '''),
      parameters: {
        'manufacturer_id': manufacturerId,
        'brand_id': brandId,
      },
    );

    return checkIfExists.first[0] as int;
    // final count = checkIfExists.first[0] as int;
    //
    // if (count == 0) {
    //   print('manufacturer brand result is empty');
    //   await registerManufacturerBrand(
    //     manufacturerId: manufacturerId,
    //     brandId: brandId,
    //   );
    // } else {
    //   print('manufacturer brand result is not empty: $checkIfExists');
    // }
  }

  Future<String> registerModel({
    required String productNameId,
    required String brandId,
    required String modelName,
  }) async {
    final modelId = await _generateUniqueModelId();

    await _conn.execute(
      Sql.named('''
      INSERT INTO Models (id, product_name_id, brand_id, model_name)
      VALUES (@id, @product_name_id, @brand_id, @model_name)
    '''),
      parameters: {
        'id': modelId,
        'product_name_id': productNameId,
        'brand_id': brandId,
        'model_name': modelName,
      },
    );

    return modelId;
  }

  Future<String?> checkModelIfExist({
    required String productNameId,
    required String brandId,
    required String modelName,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
      SELECT id FROM Models WHERE product_name_id = @product_name_id AND brand_id = @brand_id AND model_name = @model_name;
    '''),
      parameters: {
        'product_name_id': productNameId,
        'brand_id': brandId,
        'model_name': modelName,
      },
    );

    // ['first'] only to access the id
    if (checkIfExists.isEmpty) {
      print('model result is empty');
      return null;
      // return await registerModel(
      //   productNameId: productNameId,
      //   brandId: brandId,
      //   modelName: modelName,
      // );
    } else {
      print('model result is not empty: ${checkIfExists.first}');
      return checkIfExists.first[0] as String;
    }
  }

  Future<ItemWithStock?> getItemByEncryptedId({
    required String encryptedId,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
          SELECT
            i.*,
            pn.name as product_name,
            pd.description as product_description,
            mnf.name as manufacturer_name,
            brnd.name as brand_name,
            md.model_name
          FROM
            Items i
          LEFT JOIN
            ProductNames pn ON i.product_name_id = pn.id
          LEFT JOIN
            ProductDescriptions pd ON i.product_description_id = pd.id
          LEFT JOIN
            Manufacturers mnf ON i.manufacturer_id =  mnf.id
          LEFT JOIN
            Brands brnd ON i.brand_id = brnd.id
          LEFT JOIN
            Models md ON i.model_id = md.id
          WHERE
            i.encrypted_id = @encrypted_id;
          ''',
      ),
      parameters: {
        'encrypted_id': encryptedId,
      },
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;
    final itemWithStockMap = {
      'item_id': row[0],
      'product_name_id': row[1],
      'product_description_id': row[2],
      'manufacturer_id': row[3],
      'brand_id': row[4],
      'model_id': row[5],
      'serial_no': row[6],
      'specification': row[7],
      'asset_classification': row[8],
      'asset_sub_class': row[9],
      'unit': row[10],
      'quantity': row[11],
      'unit_cost': row[12],
      'estimated_useful_life': row[13],
      'acquired_date': row[14],
      'encrypted_id': row[15],
      'qr_code_image_data': row[16],
      'product_name': row[17],
      'product_description': row[18],
      'manufacturer_name': row[19],
      'brand_name': row[20],
      'model_name': row[21],
    };

    return ItemWithStock.fromJson(itemWithStockMap);
  }

  Future<int> getItemsFilteredCount({
    String? searchQuery,
    String? filter,
    String? manufacturerName,
    String? brandName,
    AssetClassification? classificationFilter,
    AssetSubClass? subClassFilter,
  }) async {
    try {
      final params = <String, dynamic>{};
      final baseQuery = '''
      SELECT
        COUNT(i.*)
      FROM
        Items i
      LEFT JOIN
        ProductNames pn ON i.product_name_id = pn.id
      LEFT JOIN
        ProductDescriptions pd ON i.product_description_id = pd.id
      LEFT JOIN
        Manufacturers mnf ON i.manufacturer_id =  mnf.id
      LEFT JOIN
        Brands brnd ON i.brand_id = brnd.id
      LEFT JOIN
        Models md ON i.model_id = md.id
      ''';

      final whereClause = StringBuffer();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
          '''
          WHERE pn.name ILIKE @search_query
          ''',
        );

        params['search_query'] = '%$searchQuery%';
        // i.id = @search_query OR
        // i.serial_no = @search_query OR
        // mnf.name ILIKE @search_query OR
        // brnd.name ILIKE @search_query OR
        // md.model_name ILIKE @search_query OR
        // i.specification ILIKE @search_query
      }

      if (manufacturerName != null && manufacturerName.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('mnf.name = @manufacturer_name');
        params['manufacturer_name'] = manufacturerName;
      }

      if (brandName != null && brandName.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('brnd.name = @brand_name');
        params['brand_name'] = brandName;
      }

      if (classificationFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('i.asset_classification = @classification_filter');
        params['classification_filter'] =
            classificationFilter.toString().split('.').last;
      }

      if (subClassFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('i.asset_sub_class = @sub_class_filter');
        params['sub_class_filter'] = subClassFilter.toString().split('.').last;
      }

      if (filter != null && filter.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        if (filter == 'in_stock') {
          whereClause.write('i.quantity > 5');
        }

        if (filter == 'low') {
          whereClause.write('i.quantity > 0 AND i.quantity <= 5');
        }

        if (filter == 'out') {
          whereClause.write('i.quantity = 0');
        }
      }

      final finalQuery = '''
      $baseQuery
      $whereClause
      ''';

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

  Future<int> getInStockItemsCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''SELECT COUNT(*) FROM Items WHERE quantity > 5;''',
      ),
    );

    return result.first[0] as int;
  }

  Future<int> getLowItemStocksCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''SELECT COUNT(*) FROM Items WHERE quantity > 0 AND quantity <= 5;''',
      ),
    );
    return result.first[0] as int;
  }

  Future<int> getOutOfStockItemsCount() async {
    final result = await _conn.execute(
      Sql.named(
        '''SELECT COUNT(*)FROM Items WHERE quantity = 0;''',
      ),
    );

    return result.first[0] as int;
  }

  Future<List<ItemWithStock>?> getItems({
    required int page,
    required int pageSize,
    String? searchQuery,
    String sortBy = 'acquired_date',
    bool sortAscending = false,
    String? filter,
    String? manufacturerName,
    String? brandName,
    // double? minimumUnitPrice,
    // double? maximumUnitPrice,
    AssetClassification? classificationFilter,
    AssetSubClass? subClassFilter,
    //DateTime? acquiredDate,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final itemList = <ItemWithStock>[];
      final params = <String, dynamic>{};

      // working fine
      final validSortColumn = {
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
        pn.name as product_name,
        pd.description as product_description,
        mnf.name as manufacturer_name,
        brnd.name as brand_name,
        md.model_name
      FROM
        Items i
      LEFT JOIN
        ProductNames pn ON i.product_name_id = pn.id
      LEFT JOIN
        ProductDescriptions pd ON i.product_description_id = pd.id
      LEFT JOIN
        Manufacturers mnf ON i.manufacturer_id =  mnf.id
      LEFT JOIN
        Brands brnd ON i.brand_id = brnd.id
      LEFT JOIN
        Models md ON i.model_id = md.id
      ''';

      final whereClause = StringBuffer();
      // There really is no problem in the search query, except for the fact that it is confuse between id and serial no.
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
          '''
          WHERE pn.name ILIKE @search_query
          ''',
        );

        params['search_query'] = '%$searchQuery%';
        // i.id = @search_query OR
        // i.serial_no = @search_query
        // mnf.name ILIKE @search_query OR
        // brnd.name ILIKE @search_query OR
        // md.model_name ILIKE @search_query OR
        // i.specification ILIKE @search_query
      }

      if (manufacturerName != null && manufacturerName.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('mnf.name = @manufacturer_name');
        params['manufacturer_name'] = manufacturerName;
      }

      if (brandName != null && brandName.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('brnd.name = @brand_name');
        params['brand_name'] = brandName;
      }

      if (classificationFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('i.asset_classification = @classification_filter');
        params['classification_filter'] =
            classificationFilter.toString().split('.').last;
      }

      if (subClassFilter != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        whereClause.write('i.asset_sub_class = @sub_class_filter');
        params['sub_class_filter'] = subClassFilter.toString().split('.').last;
      }

      if (filter != null && filter.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : 'WHERE ');
        if (filter == 'in_stock') {
          whereClause.write('i.quantity > 5');
        }

        if (filter == 'low') {
          whereClause.write('i.quantity > 0 AND i.quantity <= 5');
        }

        if (filter == 'out') {
          whereClause.write('i.quantity = 0');
        }
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
        final itemWithStockMap = {
          'item_id': row[0],
          'product_name_id': row[1],
          'product_description_id': row[2],
          'manufacturer_id': row[3],
          'brand_id': row[4],
          'model_id': row[5],
          'serial_no': row[6],
          'specification': row[7],
          'asset_classification': row[8],
          'asset_sub_class': row[9],
          'unit': row[10],
          'quantity': row[11],
          'unit_cost': row[12],
          'estimated_useful_life': row[13],
          'acquired_date': row[14],
          'encrypted_id': row[15],
          'qr_code_image_data': row[16],
          'product_name': row[17],
          'product_description': row[18],
          'manufacturer_name': row[19],
          'brand_name': row[20],
          'model_name': row[21],
        };
        itemList.add(ItemWithStock.fromJson(itemWithStockMap));
      }
      print('Fetched items for page $page: ${itemList.length}');
      return itemList;
    } catch (e) {
      print('Error fetching items: $e');
      throw Exception('Failed to fetch users.');
    }
  }

  Future<ItemWithStock?> getItemById({
    required String id,
  }) async {
    try {
      final result = await _conn.execute(
        Sql.named(
          '''
          SELECT
            i.*,
            pn.name as product_name,
            pd.description as product_description,
            mnf.name as manufacturer_name,
            brnd.name as brand_name,
            md.model_name
          FROM
            Items i
          LEFT JOIN
            ProductNames pn ON i.product_name_id = pn.id
          LEFT JOIN
            ProductDescriptions pd ON i.product_description_id = pd.id
          LEFT JOIN
            Manufacturers mnf ON i.manufacturer_id =  mnf.id
          LEFT JOIN
            Brands brnd ON i.brand_id = brnd.id
          LEFT JOIN
            Models md ON i.model_id = md.id
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
          final itemWithStockMap = {
            'item_id': row[0],
            'product_name_id': row[1],
            'product_description_id': row[2],
            'manufacturer_id': row[3],
            'brand_id': row[4],
            'model_id': row[5],
            'serial_no': row[6],
            'specification': row[7],
            'asset_classification': row[8],
            'asset_sub_class': row[9],
            'unit': row[10],
            'quantity': row[11],
            'unit_cost': row[12],
            'estimated_useful_life': row[13],
            'acquired_date': row[14],
            'encrypted_id': row[15],
            'qr_code_image_data': row[16],
            'product_name': row[17],
            'product_description': row[18],
            'manufacturer_name': row[19],
            'brand_name': row[20],
            'model_name': row[21],
          };
          return ItemWithStock.fromJson(itemWithStockMap);
        }
      }
      throw Exception('Item not found.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool?> updateItemInformation({
    required String id,
    String? productName,
    String? description,
    String? manufacturerName,
    String? brandName,
    String? modelName,
    String? serialNo,
    String? specification,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    Unit? unit,
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

      /// Retrieve the info for this particular item
      /// to be re-use when that particular info is not existing, so we just gonna override/ update its value
      /// or we can just create a new record for that updated info
      final existingItemObj = await getItemById(
        id: id,
      );

      String? productNameId;
      String? productDescriptionId;
      String? manufacturerId;
      String? brandId;
      String? modelId;

      /// these are wrong, we just update them
      /// check first if the record exist, if not just update the curr
      /// this is to avoid having the same record data
      ///
      /// what should happen is we will check first if the product name already exists
      /// that is to avoid having more than 1 records
      /// if not, then we will update the data of that particular product name
      if (productName != null && productName.isNotEmpty) {
        final productNameResult = await checkProductNameIfExist(
          productName: productName,
        );

        if (productNameResult != null) {
          productNameId = productNameResult;
        } else {
          productNameId = await registerProductName(
            productName: productName,
          );
          print('product name does not exist; created id: $productNameId');
          // productNameId = existingItemObj?.productStock.productName.id;
          //
          // await _conn.execute(
          //   Sql.named(
          //     '''
          //     UPDATE ProductNames
          //     SET product_name = @product_name
          //     WHERE id = id;
          //     ''',
          //   ),
          //   parameters: {
          //     'id': productNameId,
          //   },
          // );
        }

        setClauses.add('product_name_id = @product_name_id');
        parameters['product_name_id'] = productNameId;
      }

      if ((productNameId != null && productNameId.isNotEmpty) &&
          (description != null && description.isNotEmpty)) {
        final productDescriptionResult = await checkProductDescriptionIfExist(
          productDescription: description,
        );

        if (productDescriptionResult != null) {
          productDescriptionId = productDescriptionResult;
        } else {
          productDescriptionId = await registerProductDescription(
            productDescription: description,
          );
          print(
              'product desc does not exist; created id: $productDescriptionId');
        }

        final productStockResult = await checkProductStockIfExist(
          productNameId: productNameId,
          productDescriptionId: productDescriptionId,
        );

        if (productStockResult == 0) {
          await registerProductStock(
            productNameId: productNameId,
            productDescriptionId: productDescriptionId,
          );
          print('product stock does not exist; created one.');
        }

        setClauses.add('product_description_id = @product_description_id');
        parameters['product_description_id'] = productDescriptionId;
      }

      if (manufacturerName != null && manufacturerName.isNotEmpty) {
        final manufacturerResult = await checkManufacturerIfExist(
          manufacturerName: manufacturerName,
        );

        if (manufacturerResult != null) {
          manufacturerId = manufacturerResult;
        } else {
          manufacturerId = await registerManufacturer(
            manufacturerName: manufacturerName,
          );
          print('manufacturer does not exist; created id: $manufacturerId');
          // manufacturerId = existingItemObj?.manufacturerBrand.manufacturer.id;
          //
          // await _conn.execute(
          //   Sql.named(
          //     '''
          //     UPDATE Manufacturers
          //     SET product_name = @product_name
          //     WHERE id = id;
          //     ''',
          //   ),
          //   parameters: {
          //     'id': productNameId,
          //   },
          // );
        }

        setClauses.add('manufacturer_id = @manufacturer_id');
        parameters['manufacturer_id'] = manufacturerId;
      }

      if ((manufacturerId != null && manufacturerId.isNotEmpty) &&
          (brandName != null && brandName.isNotEmpty)) {
        final brandResult = await checkBrandIfExist(
          brandName: brandName,
        );

        if (brandResult != null) {
          brandId = brandResult;
        } else {
          brandId = await registerBrand(
            brandName: brandName,
          );
          print('brand does not exist; created id: $brandId');
        }
        print('brand id: $brandId');

        /// Check if the manufacturer and brand are connected; otherwise insert new rec
        final manufacturerBrandResult = await checkManufacturerBrandIfExist(
          manufacturerId: manufacturerId,
          brandId: brandId,
        );

        if (manufacturerBrandResult == 0) {
          await registerManufacturerBrand(
            manufacturerId: manufacturerId,
            brandId: brandId,
          );
          print('manufacturer brand does not exist; created one.');
        }

        setClauses.add('brand_id = @brand_id');
        parameters['brand_id'] = brandId;
      }

      if ((productNameId != null && productNameId.isNotEmpty) &&
          (brandId != null && brandId.isNotEmpty) &&
          (modelName != null && modelName.isNotEmpty)) {
        final modelResult = await checkModelIfExist(
          productNameId: productNameId,
          brandId: brandId,
          modelName: modelName,
        );

        if (modelResult != null) {
          modelId = modelResult;
        } else {
          modelId = await registerModel(
            productNameId: productNameId,
            brandId: brandId,
            modelName: modelName,
          );
          print('model does not exist; created id: $modelId');
        }
        print('model id: $modelId');

        setClauses.add('model_id = @model_id');
        parameters['model_id'] = modelId;
      }

      if (serialNo != null) {
        setClauses.add('serial_no = @serial_no');
        parameters['serial_no'] = serialNo;
      }

      if (specification != null) {
        setClauses.add('specification = @specification');
        parameters['specification'] = specification;
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
        parameters['unit'] = unit.toString().split('.').last;
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

  Future<int> getStocksProductNameFilteredCount({
    String? productName,
  }) async {
    Map<String, dynamic> param = {};
    String baseQuery = '''
    SELECT COUNT(name) FROM ProductNames
    ''';

    if (productName != null && productName.isNotEmpty) {
      baseQuery += 'WHERE name ILIKE @name';
      param['name'] = '%$productName%';
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
      SELECT name FROM ProductNames
      ''';

    if (productName != null && productName.isNotEmpty) {
      baseQuery += ' WHERE name ILIKE @name';
      params['name'] = '%$productName%';
    }

    final finalQuery = '''
    $baseQuery
    ORDER BY name ASC LIMIT @page_size OFFSET @offset
    ''';

    params['page_size'] = pageSize;
    params['offset'] = offset;
    final results = await _conn.execute(
      Sql.named(
        finalQuery,
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
    required String productNameId,
    String? productDescription,
  }) async {
    Map<String, dynamic> params = {};

    String baseQuery = '''
    SELECT COUNT(pd.description)
    FROM ProductDescriptions pd
    JOIN ProductStocks ps ON pd.id = ps.product_description_id
    JOIN ProductNames pn ON pn.id = ps.product_name_id
    ''';

    if (productNameId.isNotEmpty) {
      baseQuery += ' WHERE pn.id = @id';
      params['id'] = productNameId;
    }

    if (productDescription != null && productDescription.isNotEmpty) {
      baseQuery += ' AND pd.description ILIKE @description';
      params['description'] = '%$productDescription%';
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: params,
    );

    return result.first[0] as int;
  }

  Future<List<String>?> getStocksDescription({
    required int page,
    required int pageSize,
    required String productNameId,
    String? productDescription,
  }) async {
    print(productNameId);
    final offset = (page - 1) * pageSize;
    final descriptions = <String>[];
    Map<String, dynamic> params = {};

    String baseQuery = '''
    SELECT pd.description
    FROM ProductDescriptions pd
    JOIN ProductStocks ps ON pd.id = ps.product_description_id
    JOIN ProductNames pn ON pn.id = ps.product_name_id
    ''';

    if (productNameId.isNotEmpty) {
      baseQuery += 'WHERE pn.id = @id';
      params['id'] = productNameId;
    }

    if (productDescription != null && productDescription.isNotEmpty) {
      baseQuery += ' AND pd.description ILIKE @description';
      params['description'] = '%$productDescription%';
    }

    final finalQuery = '''
    $baseQuery
    ORDER BY pd.description ASC LIMIT @page_size OFFSET @offset
    ''';

    params['page_size'] = pageSize;
    params['offset'] = offset;
    print(finalQuery);
    print(params);
    final results = await _conn.execute(
      Sql.named(
        finalQuery,
      ),
      parameters: params,
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        final description = row[0] as String? ?? '';
        descriptions.add(description);
      }
      return descriptions;
    }
    return null;
  }

  Future<int> getManufacturerNamesFilteredCount({
    String? manufacturerName,
  }) async {
    Map<String, dynamic> param = {};
    String baseQuery = '''
    SELECT COUNT(*) FROM Manufacturers
    ''';

    if (manufacturerName != null && manufacturerName.isNotEmpty) {
      baseQuery += 'WHERE name ILIKE @name';
      param['name'] = '%$manufacturerName%';
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: param,
    );

    return result.first[0] as int;
  }

  Future<List<String>?> getManufacturerNames({
    required int page,
    required int pageSize,
    String? manufacturerName,
  }) async {
    final offset = (page - 1) * pageSize;
    final manufacturerNames = <String>[];
    final Map<String, dynamic> params = {};

    String baseQuery = '''
      SELECT name FROM Manufacturers
      ''';

    if (manufacturerName != null && manufacturerName.isNotEmpty) {
      baseQuery += ' WHERE name ILIKE @name';
      params['name'] = '%$manufacturerName%';
    }

    final finalQuery = '''
    $baseQuery
    ORDER BY name ASC LIMIT @page_size OFFSET @offset
    ''';

    params['page_size'] = pageSize;
    params['offset'] = offset;
    print(finalQuery);
    print(params);
    final results = await _conn.execute(
      Sql.named(
        finalQuery,
      ),
      parameters: params,
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        manufacturerNames.add(row[0] as String);
      }
      return manufacturerNames;
    }
    return null;
  }

  Future<int> getManufacturerBrandNamesFilteredCount({
    required String manufacturerId,
    String? brandName,
  }) async {
    Map<String, dynamic> params = {};
    String baseQuery = '''
    SELECT COUNT(b.name)
    FROM Brands b
    JOIN ManufacturerBrands mb ON b.id = mb.brand_id
    JOIN Manufacturers m ON m.id = mb.manufacturer_id 
      ''';

    if (manufacturerId.isNotEmpty) {
      baseQuery += 'WHERE m.id = @manufacturer_id';
      params['manufacturer_id'] = manufacturerId;
    }

    if (brandName != null && brandName.isNotEmpty) {
      baseQuery += ' AND b.name ILIKE @brand_name';
      params['brand_name'] = '%$brandName%';
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: params,
    );

    return result.first[0] as int;
  }

  Future<List<String>?> getManufacturerBrandNames({
    required int page,
    required int pageSize,
    required String manufacturerId,
    String? brandName,
  }) async {
    final offset = (page - 1) * pageSize;
    final brandNames = <String>[];
    Map<String, dynamic> params = {};

    String baseQuery = '''
    SELECT b.name
    FROM Brands b
    JOIN ManufacturerBrands mb ON b.id = mb.brand_id
    JOIN Manufacturers m ON m.id = mb.manufacturer_id 
      ''';

    if (manufacturerId.isNotEmpty) {
      baseQuery += 'WHERE m.id = @manufacturer_id';
      params['manufacturer_id'] = manufacturerId;
    }

    if (brandName != null && brandName.isNotEmpty) {
      baseQuery += ' AND b.name ILIKE @brand_name';
      params['brand_name'] = '%$brandName%';
    }

    final finalQuery = '''
    $baseQuery
    ORDER BY b.name ASC LIMIT @page_size OFFSET @offset
    ''';

    params['page_size'] = pageSize;
    params['offset'] = offset;
    print(finalQuery);
    print(params);
    final results = await _conn.execute(
      Sql.named(
        finalQuery,
      ),
      parameters: params,
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        brandNames.add(row[0] as String);
      }
      return brandNames;
    }
    return null;
  }

  Future<int> getBrandModelsFilteredCount({
    required String productNameId,
    required String brandId,
    String? modelName,
  }) async {
    Map<String, dynamic> params = {};
    String baseQuery = '''
    SELECT COUNT(model_name) FROM Models
      ''';

    if (productNameId.isNotEmpty && brandId.isNotEmpty) {
      baseQuery += ' WHERE product_name_id = @product_name_id';
      baseQuery += ' AND brand_id = @brand_id';

      params['product_name_id'] = productNameId;
      params['brand_id'] = brandId;
    }

    if (modelName != null && modelName.isNotEmpty) {
      baseQuery += ' AND model_name ILIKE @model_name';

      params['model_name'] = '%$modelName%';
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: params,
    );

    return result.first[0] as int;
  }

  Future<List<String>?> getBrandModelNames({
    required int page,
    required int pageSize,
    required String productNameId,
    required String brandId,
    String? modelName,
  }) async {
    final offset = (page - 1) * pageSize;
    final productNames = <String>[];
    final Map<String, dynamic> params = {};

    String baseQuery = '''
    SELECT model_name FROM Models
      ''';

    if (productNameId.isNotEmpty && brandId.isNotEmpty) {
      baseQuery += ' WHERE product_name_id = @product_name_id';
      baseQuery += ' AND brand_id = @brand_id';

      params['product_name_id'] = productNameId;
      params['brand_id'] = brandId;
    }

    if (modelName != null && modelName.isNotEmpty) {
      baseQuery += ' AND model_name ILIKE @model_name';

      params['model_name'] = '%$modelName%';
    }

    final finalQuery = '''
    $baseQuery
    ORDER BY model_name ASC LIMIT @page_size OFFSET @offset
    ''';

    params['page_size'] = pageSize;
    params['offset'] = offset;
    print(finalQuery);
    print(params);
    final results = await _conn.execute(
      Sql.named(
        finalQuery,
      ),
      parameters: params,
    );

    if (results.isNotEmpty) {
      for (final row in results) {
        productNames.add(row[0] as String);
      }
      print(productNames);
      return productNames;
    }
    return null;
  }
}
