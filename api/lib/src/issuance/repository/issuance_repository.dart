import 'dart:math';

import 'package:api/src/item/models/item.dart';
import 'package:api/src/organization_management/models/office.dart';
import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/purchase_request/model/purchase_request.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:postgres/postgres.dart';

import '../../utils/generate_id.dart';
import '../models/issuance.dart';

class IssuanceRepository {
  const IssuanceRepository(this._conn);

  final Connection _conn;

  Future<String> _generateUniqueIssuanceId() async {
    while (true) {
      final issuanceId = generatedId('ISSNC');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM Issuances Where id = @id;
        '''),
        parameters: {
          'id': issuanceId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return issuanceId;
      }
    }
  }

  Future<String> _generateUniqueIcsId() async {
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    print('curr ym - $yearMonth');

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

    return '$yearMonth-$n';
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
      print('row res: $row');
      for (var r in row) {
        print(r);
      }
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
    print('returned issuance items: $issuanceItems');
    return issuanceItems;
  }

  Future<InventoryCustodianSlip?> getIcsById({
    required String id,
  }) async {
    final issuanceItems = await _getIssuanceItems(
      issuance_id: id,
    );
    print('issuance items: $issuanceItems');

    final issuanceResult = await _conn.execute(
      Sql.named(
        '''
      SELECT 
        iss.*,
        ics.id AS ics_id,
        ics.sending_officer_id
      FROM 
        Issuances iss
      LEFT JOIN
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
        id: row[1] as String,
      );
      print('pr: $purchaseRequest');
      final receivingOfficer = await OfficerRepository(_conn).getOfficerById(
        id: row[2] as String,
      );
      print('receiving officer: $receivingOfficer');
      final sendingOfficer = await OfficerRepository(_conn).getOfficerById(
        id: row[7] as String,
      );
      print('sending officer: $sendingOfficer');

      print('row res: $row');

      return InventoryCustodianSlip.fromJson({
        'id': row[0],
        'items':
            issuanceItems.map((issuanceItem) => issuanceItem.toJson()).toList(),
        'purchase_request': purchaseRequest?.toJson(),
        'receiving_officer': receivingOfficer?.toJson(),
        'issue_date': row[3],
        'return_date': row[4],
        'is_archived': row[5],
        'ics_id': row[6],
        'sending_officer': sendingOfficer?.toJson(),
      });
    }

    return null;
  }

  // return a list of items id with the quantity reduce
  Future<List<Map<String, dynamic>>> matchingItemFromPurchaseRequest({
    required String purchaseRequestId,
    required int requestedQuantity, // I'll extract this from the prId
  }) async {
    final matchedItemList = <Map<String, dynamic>>[];

    /// query for matching pr items to inventory items
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

  // choose a pr
  // check for items in db then automatically fill
  Future<String> createICS({
    required String purchaseRequestId,
    required int requestedQuantity,
    required List<dynamic>
        issuanceItems, // we use its length to iterate
    required String receivingOfficerId,
    required String sendingOfficerId,
    //required String issuedDate,
  }) async {
    // generate the necessary ids
    final issuanceId = await _generateUniqueIssuanceId();
    final icsId = await _generateUniqueIcsId();

    await _conn.runTx((ctx) async {
      /// insert record to base issuance entity only once
      await ctx.execute(
        Sql.named(
          '''
          INSERT INTO Issuances (id, purchase_request_id, receiving_officer_id, issued_date)
          VALUES (@id, @purchase_request_id, @receiving_officer_id, @issued_date);
          ''',
        ),
        parameters: {
          'id': issuanceId,
          'purchase_request_id': purchaseRequestId,
          'receiving_officer_id': receivingOfficerId,
          'issued_date': DateTime.now().toIso8601String(),
        },
      );

      /// insert record to concrete issuance entity only once
      await ctx.execute(
        Sql.named(
          '''
          INSERT INTO InventoryCustodianSlips (id, issuance_id, sending_officer_id)
          VALUES (@id, @issuance_id, @sending_officer_id);
          ''',
        ),
        parameters: {
          'id': icsId,
          'issuance_id': issuanceId,
          'sending_officer_id': sendingOfficerId,
        },
      );

      for (int i = 0; i < issuanceItems.length; i++) {
        final issuanceItem = issuanceItems[i];
        final itemId = issuanceItem['item_id'] as String;
        final fetchedItemQuantity = issuanceItem['issued_quantity'] as int;
        final issuedQuantity = min(requestedQuantity, fetchedItemQuantity);
        final remainingRequestedQuantityAfterIssued =
            requestedQuantity - issuedQuantity;

        /// insert record to issuance item table
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

        /// update remaining quantity and pr status
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
                ? PurchaseRequestStatus.partiallyFulfilled.toString().split('.').last
                : PurchaseRequestStatus.fulfilled.toString().split('.').last,
          },
        );

        /// update inventory item quantity
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

      //await ctx.rollback();
    });

    return issuanceId;
  }
}
