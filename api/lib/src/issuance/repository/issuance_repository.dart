import 'dart:math';

import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/purchase_request/model/purchase_request.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:api/src/utils/qr_code_utils.dart';
import 'package:postgres/postgres.dart';

import '../models/issuance.dart';

class IssuanceRepository {
  const IssuanceRepository(this._conn);

  final Connection _conn;

  Future<String> _generateUniqueIssuanceId() async {
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    print('Current year-month for ISS ID: $yearMonth');

    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT id FROM Issuances
        WHERE id LIKE 'ISS' || '-' || @year_month || '-%'
        ORDER BY id DESC
        LIMIT 1
        ''',
      ),
      parameters: {
        'year_month': yearMonth,
      },
    );

    int? n; // represent the no. of record
    if (result.isNotEmpty) {
      n = int.parse(result.first[0].toString().split('-').last) + 1;
    } else {
      n = 1;
    }

    final uniqueId = 'ISS-$yearMonth-${n.toString().padLeft(3, '0')}';
    print('Generated ISS ID: $uniqueId');
    return uniqueId;
  }

  Future<String> _generateUniqueIcsId() async {
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    print('Current year-month for ICS ID: $yearMonth');

    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT id FROM InventoryCustodianSlips
        WHERE id LIKE @year_month || '-%'
        ORDER BY id DESC 
        LIMIT 1;
        ''',
      ),
      parameters: {
        'year_month': yearMonth,
      },
    );

    int? n; // represent the no. of record
    if (result.isNotEmpty) {
      n = int.parse(result.first[0].toString().split('-').last) + 1;
    } else {
      n = 1;
    }

    final uniqueId = '$yearMonth-${n.toString().padLeft(3, '0')}';
    print('Generated ICS ID: $uniqueId');
    return uniqueId;
  }

  Future<String> _generateUniqueParId() async {
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    print('Current year-month for PAR ID: $yearMonth');

    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT id FROM PropertyAcknowledgementReceipts
        WHERE id LIKE @year_month || '-%'
        ORDER BY id DESC 
        LIMIT 1;
        ''',
      ),
      parameters: {
        'year_month': yearMonth,
      },
    );

    int? n; // represent the no. of record
    if (result.isNotEmpty) {
      n = int.parse(result.first[0].toString().split('-').last) + 1;
    } else {
      n = 1;
    }

    final uniqueId = '$yearMonth-${n.toString().padLeft(3, '0')}';
    print('Generated PAR ID: $uniqueId');
    return uniqueId;
  }

  Future<List<IssuanceItem>> _getIssuanceItems({
    required String issuance_id,
  }) async {
    final issuanceItems = <IssuanceItem>[];

    final issuanceItemsResult = await _conn.execute(
      Sql.named('''
      SELECT
        iss.*, 
        i.*,
        pn.name as product_name,
        pd.description as product_description,
        mnf.name as manufacturer_name,
        brnd.name as brand_name,
        md.model_name
      FROM 
        IssuanceItems iss
      LEFT JOIN 
        Items i ON iss.item_id = i.id
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
        iss.issuance_id = @issuance_id
      '''),
      parameters: {
        'issuance_id': issuance_id,
      },
    );

    for (final row in issuanceItemsResult) {
      issuanceItems.add(
        IssuanceItem.fromJson(
          {
            'issuance_id': row[0],
            'item': {
              'item_id': row[1],
              'product_name_id': row[4],
              'product_description_id': row[5],
              'manufacturer_id': row[6],
              'brand_id': row[7],
              'model_id': row[8],
              'serial_no': row[9],
              'specification': row[10],
              'asset_classification': row[11],
              'asset_sub_class': row[12],
              'unit': row[13],
              'quantity': row[14],
              'unit_cost': row[15],
              'estimated_useful_life': row[16],
              'acquired_date': row[17],
              'encrypted_id': row[18],
              'qr_code_image_data': row[19],
              'product_name': row[20],
              'product_description': row[21],
              'manufacturer_name': row[22],
              'brand_name': row[23],
              'model_name': row[24],
            },
            'quantity': row[2],
          },
        ),
      );
    }

    return issuanceItems;
  }

  Future<Issuance?> getIssuanceById({
    required String id,
  }) async {
    try {
      final query = '''
      SELECT
        iss.*,
        ics.id AS ics_id,
        ics.sending_officer_id,
        par.id AS par_id,
        par.property_number,
        par.sending_officer_id
      FROM
        Issuances iss
      LEFT JOIN
        InventoryCustodianSlips ics ON iss.id = ics.issuance_id
      LEFT JOIN
        PropertyAcknowledgementReceipts par ON iss.id = par.issuance_id
      WHERE iss.id = @id;
      ''';

      final result = await _conn.execute(
        Sql.named(
          query,
        ),
        parameters: {
          'id': id,
        },
      );

      final row = result.first;
      final isICS = row[8] != null;
      final isPAR = row[10] != null;

      if (isICS) {
        return await getIcsById(id: row[0] as String);
      }

      if (isPAR) {
        return await getParById(id: row[0] as String);
      }

      return null;
    } catch (e) {
      print('Error fetching issuance by id: $e');
      throw Exception('Failed to fetch issuance by id: $e');
    }
  }

  Future<InventoryCustodianSlip?> getIcsById({
    required String id,
  }) async {
    final issuanceItems = await _getIssuanceItems(
      issuance_id: id,
    );

    final issuanceResult = await _conn.execute(
      Sql.named(
        '''
      SELECT
        iss.*,
        ics.id AS ics_id,
        ics.sending_officer_id
      FROM
        Issuances iss
      JOIN
        InventoryCustodianSlips ics ON iss.id = ics.issuance_id
      WHERE
        iss.id = @issuance_id;
      ''',
      ),
      parameters: {
        'issuance_id': id,
      },
    );

    for (final row in issuanceResult) {
      final purchaseRequest =
          await PurchaseRequestRepository(_conn).getPurchaseRequestById(
        id: row[3] as String,
      );

      final receivingOfficer = await OfficerRepository(_conn).getOfficerById(
        officerId: row[4] as String,
      );

      final sendingOfficer = await OfficerRepository(_conn).getOfficerById(
        officerId: row[9] as String,
      );

      return InventoryCustodianSlip.fromJson({
        'id': row[0],
        'ics_id': row[8],
        'items':
            issuanceItems.map((issuanceItem) => issuanceItem.toJson()).toList(),
        'issued_date': row[1],
        'return_date': row[2],
        'purchase_request': purchaseRequest?.toJson(),
        'receiving_officer': receivingOfficer?.toJson(),
        'sending_officer': sendingOfficer?.toJson(),
        'qr_code_image_data': row[5],
        'is_received': row[6],
        'is_archived': row[7],
      });
    }

    return null;
  }

  Future<PropertyAcknowledgementReceipt?> getParById({
    required String id,
  }) async {
    final issuanceItems = await _getIssuanceItems(
      issuance_id: id,
    );

    final issuanceResult = await _conn.execute(
      Sql.named(
        '''
      SELECT
        iss.*,
        par.id AS par_id,
        par.property_number,
        par.sending_officer_id
      FROM
        Issuances iss
      JOIN
        PropertyAcknowledgementReceipts par ON iss.id = par.issuance_id
      WHERE
        iss.id = @issuance_id;
      ''',
      ),
      parameters: {
        'issuance_id': id,
      },
    );

    for (final row in issuanceResult) {
      final purchaseRequest =
          await PurchaseRequestRepository(_conn).getPurchaseRequestById(
        id: row[3] as String,
      );

      final receivingOfficer = await OfficerRepository(_conn).getOfficerById(
        officerId: row[4] as String,
      );

      final sendingOfficer = await OfficerRepository(_conn).getOfficerById(
        officerId: row[10] as String,
      );

      return PropertyAcknowledgementReceipt.fromJson({
        'id': row[0],
        'par_id': row[8],
        'property_number': row[9],
        'items':
            issuanceItems.map((issuanceItem) => issuanceItem.toJson()).toList(),
        'issued_date': row[1],
        'return_date': row[2],
        'purchase_request': purchaseRequest?.toJson(),
        'receiving_officer': receivingOfficer?.toJson(),
        'sending_officer': sendingOfficer?.toJson(),
        'qr_code_image_data': row[5],
        'is_received': row[6],
        'is_archived': row[7],
      });
    }

    return null;
  }

  Future<int> getIssuancesCount({
    String? searchQuery,
    DateTime? issueDateStart,
    DateTime? issueDateEnd,
    String? type,
    bool isArchived = false,
  }) async {
    try {
      final params = <String, dynamic>{};

      final baseQuery = '''
      SELECT COUNT(*)
      FROM Issuances iss
      LEFT JOIN InventoryCustodianSlips ics ON iss.id = ics.issuance_id
      LEFT JOIN PropertyAcknowledgementReceipts par ON iss.id = par.issuance_id
      ''';

      final whereClause = StringBuffer('WHERE iss.is_archived = @is_archived');
      params['is_archived'] = isArchived;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
            ' AND (ics.id ILIKE @search_query OR par.id ILIKE @search_query)');
        params['search_query'] = '%$searchQuery%';
      }

      if (issueDateStart != null) {
        whereClause.write(' AND iss.issued_date >= @issue_date_start');
        params['issue_date_start'] = issueDateStart.toIso8601String();
      }
      if (issueDateEnd != null) {
        whereClause.write(' AND iss.issued_date <= @issue_date_end');
        params['issue_date_end'] = issueDateEnd.toIso8601String();
      } else {
        // Default the end date to today if it's null
        whereClause.write(' AND iss.issued_date <= @issue_date_end');
        params['issue_date_end'] = DateTime.now().toIso8601String();
      }

      if (type != null && type.isNotEmpty) {
        whereClause.write(' AND (ics.id IS NOT NULL OR par.id IS NOT NULL)');
        if (type == 'ics') {
          whereClause.write(' AND ics.id IS NOT NULL');
        } else if (type == 'par') {
          whereClause.write(' AND par.id IS NOT NULL');
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

      print(finalQuery);
      print(params);

      if (result.isNotEmpty) {
        final count = result.first[0] as int;
        print('Total no. of filtered issuances: $count');
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error counting filtered issuances: $e');
      throw Exception('Failed to count filtered issuances.');
    }
  }

  Future<List<Issuance>?> getIssuances({
    required int page,
    required int pageSize,
    String? searchQuery,
    DateTime? issueDateStart,
    DateTime? issueDateEnd,
    String? type,
    bool isArchived = false,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final issuances = <Issuance>[];
      final params = <String, dynamic>{};

      final baseQuery = '''
      SELECT
        iss.*,
        ics.id AS ics_id,
        ics.sending_officer_id,
        par.id AS par_id,
        par.property_number,
        par.sending_officer_id
      FROM
        Issuances iss
      LEFT JOIN
        InventoryCustodianSlips ics ON iss.id = ics.issuance_id
      LEFT JOIN
        PropertyAcknowledgementReceipts par ON iss.id = par.issuance_id
      ''';

      final whereClause = StringBuffer('WHERE iss.is_archived = @is_archived');
      params['is_archived'] = isArchived;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
            ' AND (ics.id ILIKE @search_query OR par.id ILIKE @search_query)');
        params['search_query'] = '%$searchQuery%';
      }

      if (issueDateStart != null) {
        whereClause.write(' AND iss.issued_date >= @issue_date_start');
        params['issue_date_start'] = issueDateStart.toIso8601String();
      }
      if (issueDateEnd != null) {
        whereClause.write(' AND iss.issued_date <= @issue_date_end');
        params['issue_date_end'] = issueDateEnd.toIso8601String();
      } else {
        // Default the end date to today if it's null
        whereClause.write(' AND iss.issued_date <= @issue_date_end');
        params['issue_date_end'] = DateTime.now().toIso8601String();
      }

      if (type != null && type.isNotEmpty) {
        whereClause.write(' AND (ics.id IS NOT NULL OR par.id IS NOT NULL)');
        if (type == 'ics') {
          whereClause.write(' AND ics.id IS NOT NULL');
        } else if (type == 'par') {
          whereClause.write(' AND par.id IS NOT NULL');
        }
      }

      final finalQuery = '''
      $baseQuery
      ${whereClause.toString()}
      ORDER BY iss.issued_date DESC
      LIMIT @page_size OFFSET @offset
      ''';

      params['page_size'] = pageSize;
      params['offset'] = offset;

      print(finalQuery);
      print(params);

      final results = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      print(results);

      for (final row in results) {
        final isICS = row[8] != null;
        final isPAR = row[10] != null;

        if (isICS) {
          final ics = await getIcsById(id: row[0] as String);
          issuances.add(ics!);
        }

        if (isPAR) {
          final par = await getParById(id: row[0] as String);
          issuances.add(par!);
        }
      }

      return issuances;
    } catch (e) {
      print('Error fetching issuances: $e');
      throw Exception('Failed to fetch issuances.');
    }
  }

  Future<List<Map<String, dynamic>>?> matchingItemFromPurchaseRequest({
    required String purchaseRequestId,
    required int requestedQuantity,
  }) async {
    final matchedItemList = <Map<String, dynamic>>[];

    final matchingItemQuery = '''
        SELECT 
          i.id,
          i.quantity
        FROM 
          Items i
        LEFT JOIN
          PurchaseRequests pr
        ON
          i.product_name_id = pr.product_name_id
        AND
          i.product_description_id = pr.product_description_id
        AND
          i.unit = pr.unit
        AND
          i.unit_cost = pr.unit_cost
        WHERE
          pr.id = @pr_id
        AND 
          i.quantity > 0
        LIMIT 1;
        ''';

    await _conn.runTx((ctx) async {
      while (requestedQuantity > 0) {
        /// Check if an item matches the pr and retrieve its id
        final matchedItemResult = await ctx.execute(
          Sql.named(
            matchingItemQuery,
          ),
          parameters: {
            'pr_id': purchaseRequestId,
          },
        );

        if (matchedItemResult.isEmpty) {
          break;
        }

        final itemId = matchedItemResult.first[0] as String;
        final fetchedItemQuantity = matchedItemResult.first[1] as int;
        final issuedQuantity = min(requestedQuantity, fetchedItemQuantity);

        requestedQuantity -= issuedQuantity;

        print(requestedQuantity);

        matchedItemList.add(
          {
            'item_id': itemId,
            'issued_quantity': issuedQuantity,
          },
        );

        /// update item quantity
        await ctx.execute(
          Sql.named(
            '''
          UPDATE Items
          SET quantity = @quantity
          WHERE id = @id;
          ''',
          ),
          parameters: {
            'id': itemId,
            'quantity': fetchedItemQuantity - issuedQuantity,
          },
        );
      }

      // Rollback the transaction to undo changes after testing
      await ctx.rollback();
    });
    return matchedItemList;
  }

  Future<String> _createIssuance({
    required String purchaseRequestId,
    required int requestedQuantity,
    required List<dynamic> issuanceItems,
    required String receivingOfficerId,
    required String concreteIssuanceEntityQuery,
    required Map<String, dynamic> concreteIssuanceEntityParams,
  }) async {
    final issuanceId = await _generateUniqueIssuanceId();
    final qrCodeImageData = await QrCodeUtils.generateQRCode(issuanceId);

    await _conn.runTx((ctx) async {
      // Insert into Issuances table
      await ctx.execute(
        Sql.named(
          '''
        INSERT INTO Issuances (id, purchase_request_id, receiving_officer_id, issued_date, qr_code_image_data)
        VALUES (@id, @purchase_request_id, @receiving_officer_id, @issued_date, @qr_code_image_data);
        ''',
        ),
        parameters: {
          'id': issuanceId,
          'purchase_request_id': purchaseRequestId,
          'receiving_officer_id': receivingOfficerId,
          'issued_date': DateTime.now().toIso8601String(),
          'qr_code_image_data': qrCodeImageData,
        },
      );

      // Insert into the concrete issuance table (either InventoryCustodianSlips or PropertyAcknowledgementReceipts)
      concreteIssuanceEntityParams['issuance_id'] = issuanceId;
      await ctx.execute(
        Sql.named(
          concreteIssuanceEntityQuery,
        ),
        parameters: concreteIssuanceEntityParams,
      );

      for (final issuanceItem in issuanceItems) {
        final itemId = issuanceItem['item_id'] as String;
        final fetchedItemQuantity = issuanceItem['issued_quantity'] as int;
        final issuedQuantity = min(requestedQuantity, fetchedItemQuantity);
        final remainingRequestedQuantityAfterIssued =
            requestedQuantity - issuedQuantity;

        // Insert into IssuanceItems table
        await ctx.execute(
          Sql.named(
            '''
          INSERT INTO IssuanceItems (issuance_id, item_id, quantity)
          VALUES (@issuance_id, @item_id, @quantity);
          ''',
          ),
          parameters: {
            'issuance_id': issuanceId,
            'item_id': itemId,
            'quantity': issuedQuantity,
          },
        );

        // Update PurchaseRequests table
        await ctx.execute(
          Sql.named(
            '''
          UPDATE PurchaseRequests
          SET remaining_quantity = @remaining_quantity, status = @status
          WHERE id = @id;
          ''',
          ),
          parameters: {
            'id': purchaseRequestId,
            'remaining_quantity': remainingRequestedQuantityAfterIssued,
            'status': remainingRequestedQuantityAfterIssued > 0
                ? PurchaseRequestStatus.partiallyFulfilled
                    .toString()
                    .split('.')
                    .last
                : PurchaseRequestStatus.fulfilled.toString().split('.').last,
          },
        );

        // Update Items table
        await ctx.execute(
          Sql.named(
            '''
          UPDATE Items
          SET quantity = quantity - @quantity
          WHERE id = @id;
          ''',
          ),
          parameters: {
            'id': itemId,
            'quantity': fetchedItemQuantity,
          },
        );
      }
    });

    return issuanceId;
  }

  Future<String> createICS({
    required String purchaseRequestId,
    required int requestedQuantity,
    required List<dynamic> issuanceItems,
    required String receivingOfficerId,
    required String sendingOfficerId,
  }) async {
    final icsId = await _generateUniqueIcsId();

    final concreteIssuanceEntityQuery = '''
    INSERT INTO InventoryCustodianSlips (id, issuance_id, sending_officer_id)
    VALUES (@id, @issuance_id, @sending_officer_id);
    ''';

    final concreteIssuanceEntityParams = {
      'id': icsId,
      'sending_officer_id': sendingOfficerId,
    };

    return await _createIssuance(
      purchaseRequestId: purchaseRequestId,
      requestedQuantity: requestedQuantity,
      issuanceItems: issuanceItems,
      receivingOfficerId: receivingOfficerId,
      concreteIssuanceEntityQuery: concreteIssuanceEntityQuery,
      concreteIssuanceEntityParams: concreteIssuanceEntityParams,
    );
  }

  Future<String> createPAR({
    String? propertyNumber,
    required String purchaseRequestId,
    required int requestedQuantity,
    required List<dynamic> issuanceItems,
    required String receivingOfficerId,
    required String sendingOfficerId,
  }) async {
    final parId = await _generateUniqueParId();

    final concreteIssuanceEntityQuery = '''
    INSERT INTO PropertyAcknowledgementReceipts (id, issuance_id, property_number, sending_officer_id)
    VALUES (@id, @issuance_id, @property_number, @sending_officer_id);
    ''';

    final concreteIssuanceEntityParams = {
      'id': parId,
      'property_number': propertyNumber,
      'sending_officer_id': sendingOfficerId,
    };

    return await _createIssuance(
      purchaseRequestId: purchaseRequestId,
      requestedQuantity: requestedQuantity,
      issuanceItems: issuanceItems,
      receivingOfficerId: receivingOfficerId,
      concreteIssuanceEntityQuery: concreteIssuanceEntityQuery,
      concreteIssuanceEntityParams: concreteIssuanceEntityParams,
    );
  }

  Future<bool> receiveIssuance({
    required String issuanceId,
    required String receivingOfficerId,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        UPDATE 
          Issuances
        SET 
          is_received = TRUE
        WHERE 
          id = @id
        AND 
          receiving_officer_id = @receiving_officer_id; 
        ''',
      ),
      parameters: {
        'id': issuanceId,
        'receiving_officer_id': receivingOfficerId,
      },
    );

    print(result);
    print(issuanceId);
    print(receivingOfficerId);

    if (result.affectedRows == 0) {
      throw Exception('You are not the receiving officer for this issuance.');
    }

    return true;
  }

  // choose a pr
  // check for items in db then automatically fill
  // Future<String> createICS({
  //   required String purchaseRequestId,
  //   required int requestedQuantity,
  //   required List<dynamic> issuanceItems,
  //   required String receivingOfficerId,
  //   required String sendingOfficerId,
  //   //required String issuedDate,
  // }) async {
  //   // generate the necessary ids
  //   final issuanceId = await _generateUniqueIssuanceId();
  //   final icsId = await _generateUniqueIcsId();
  //
  //   final qrCodeImageData = await QrCodeUtils.generateQRCode(issuanceId);
  //
  //   await _conn.runTx((ctx) async {
  //     /// insert record to base issuance entity only once
  //     await ctx.execute(
  //       Sql.named(
  //         '''
  //         INSERT INTO Issuances (id, purchase_request_id, receiving_officer_id, issued_date, qr_code_image_data)
  //         VALUES (@id, @purchase_request_id, @receiving_officer_id, @issued_date, @qr_code_image_data);
  //         ''',
  //       ),
  //       parameters: {
  //         'id': issuanceId,
  //         'purchase_request_id': purchaseRequestId,
  //         'receiving_officer_id': receivingOfficerId,
  //         'issued_date': DateTime.now().toIso8601String(),
  //         'qr_code_image_data': qrCodeImageData,
  //       },
  //     );
  //
  //     /// insert record to concrete issuance entity only once
  //     await ctx.execute(
  //       Sql.named(
  //         '''
  //         INSERT INTO InventoryCustodianSlips (id, issuance_id, sending_officer_id)
  //         VALUES (@id, @issuance_id, @sending_officer_id);
  //         ''',
  //       ),
  //       parameters: {
  //         'id': icsId,
  //         'issuance_id': issuanceId,
  //         'sending_officer_id': sendingOfficerId,
  //       },
  //     );
  //
  //     for (int i = 0; i < issuanceItems.length; i++) {
  //       final issuanceItem = issuanceItems[i];
  //       final itemId = issuanceItem['item_id'] as String;
  //       final fetchedItemQuantity =
  //       issuanceItem['issued_quantity'] as int; // fetched item to be issued
  //       final issuedQuantity = min(requestedQuantity, fetchedItemQuantity);
  //       final remainingRequestedQuantityAfterIssued =
  //           requestedQuantity - issuedQuantity;
  //
  //       /// insert record to issuance item table
  //       await ctx.execute(
  //         Sql.named(
  //           '''
  //         INSERT INTO IssuanceItems (issuance_id, item_id, quantity)
  //         VALUES (@issuance_id, @item_id, @quantity);
  //         ''',
  //         ),
  //         parameters: {
  //           'issuance_id': issuanceId,
  //           'item_id': itemId,
  //           'quantity': issuedQuantity,
  //         },
  //       );
  //
  //       /// update remaining quantity and pr status
  //       await ctx.execute(
  //         Sql.named(
  //           '''
  //       UPDATE PurchaseRequests
  //       SET remaining_quantity = @remaining_quantity, status = @status
  //       WHERE id = @id;
  //       ''',
  //         ),
  //         parameters: {
  //           'id': purchaseRequestId,
  //           'remaining_quantity': remainingRequestedQuantityAfterIssued,
  //           'status': remainingRequestedQuantityAfterIssued > 0
  //               ? PurchaseRequestStatus.partiallyFulfilled
  //               .toString()
  //               .split('.')
  //               .last
  //               : PurchaseRequestStatus.fulfilled.toString().split('.').last,
  //         },
  //       );
  //
  //       /// update inventory item quantity
  //       await ctx.execute(
  //         Sql.named(
  //           '''
  //         UPDATE Items
  //         SET quantity = quantity - @quantity
  //         WHERE id = @id;
  //         ''',
  //         ),
  //         parameters: {
  //           'id': itemId,
  //           'quantity': fetchedItemQuantity,
  //         },
  //       );
  //     }
  //     // await ctx.rollback();
  //   });
  //
  //   return issuanceId;
  // }
  //
  // Future<String> createPAR({
  //   String? propertyNumber,
  //   required String purchaseRequestId,
  //   required int requestedQuantity,
  //   required List<dynamic> issuanceItems,
  //   required String receivingOfficerId,
  //   required String sendingOfficerId,
  //   //required String issuedDate,
  // }) async {
  //   // generate the necessary ids
  //   final issuanceId = await _generateUniqueIssuanceId();
  //   final parId = await _generateUniqueParId();
  //
  //   final qrCodeImageData = await QrCodeUtils.generateQRCode(issuanceId);
  //
  //   await _conn.runTx((ctx) async {
  //     /// insert record to base issuance entity only once
  //     await ctx.execute(
  //       Sql.named(
  //         '''
  //         INSERT INTO Issuances (id, purchase_request_id, receiving_officer_id, issued_date, qr_code_image_data)
  //         VALUES (@id, @purchase_request_id, @receiving_officer_id, @issued_date, @qr_code_image_data);
  //         ''',
  //       ),
  //       parameters: {
  //         'id': issuanceId,
  //         'purchase_request_id': purchaseRequestId,
  //         'receiving_officer_id': receivingOfficerId,
  //         'issued_date': DateTime.now().toIso8601String(),
  //         'qr_code_image_data': qrCodeImageData,
  //       },
  //     );
  //
  //     /// insert record to concrete issuance entity only once
  //     await ctx.execute(
  //       Sql.named(
  //         '''
  //         INSERT INTO PropertyAcknowledgementReceipts (id, issuance_id, property_number, sending_officer_id)
  //         VALUES (@id, @issuance_id, @property_number, @sending_officer_id);
  //         ''',
  //       ),
  //       parameters: {
  //         'id': parId,
  //         'issuance_id': issuanceId,
  //         'property_number': propertyNumber,
  //         'sending_officer_id': sendingOfficerId,
  //       },
  //     );
  //
  //     for (int i = 0; i < issuanceItems.length; i++) {
  //       final issuanceItem = issuanceItems[i];
  //       final itemId = issuanceItem['item_id'] as String;
  //       final fetchedItemQuantity =
  //           issuanceItem['issued_quantity'] as int; // fetched item to be issued
  //       final issuedQuantity = min(requestedQuantity, fetchedItemQuantity);
  //       final remainingRequestedQuantityAfterIssued =
  //           requestedQuantity - issuedQuantity;
  //
  //       /// insert record to issuance item table
  //       await ctx.execute(
  //         Sql.named(
  //           '''
  //         INSERT INTO IssuanceItems (issuance_id, item_id, quantity)
  //         VALUES (@issuance_id, @item_id, @quantity);
  //         ''',
  //         ),
  //         parameters: {
  //           'issuance_id': issuanceId,
  //           'item_id': itemId,
  //           'quantity': issuedQuantity,
  //         },
  //       );
  //
  //       /// update remaining quantity and pr status
  //       await ctx.execute(
  //         Sql.named(
  //           '''
  //       UPDATE PurchaseRequests
  //       SET remaining_quantity = @remaining_quantity, status = @status
  //       WHERE id = @id;
  //       ''',
  //         ),
  //         parameters: {
  //           'id': purchaseRequestId,
  //           'remaining_quantity': remainingRequestedQuantityAfterIssued,
  //           'status': remainingRequestedQuantityAfterIssued > 0
  //               ? PurchaseRequestStatus.partiallyFulfilled
  //                   .toString()
  //                   .split('.')
  //                   .last
  //               : PurchaseRequestStatus.fulfilled.toString().split('.').last,
  //         },
  //       );
  //
  //       /// update inventory item quantity
  //       await ctx.execute(
  //         Sql.named(
  //           '''
  //         UPDATE Items
  //         SET quantity = quantity - @quantity
  //         WHERE id = @id;
  //         ''',
  //         ),
  //         parameters: {
  //           'id': itemId,
  //           'quantity': fetchedItemQuantity,
  //         },
  //       );
  //     }
  //     // await ctx.rollback();
  //   });
  //
  //   return issuanceId;
  // }
}
