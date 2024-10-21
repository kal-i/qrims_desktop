import 'dart:math';

import 'package:api/src/purchase_request/model/purchase_request.dart';
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

  // Future<Map<String, dynamic>> matchingItemFromPurchaseRequest({
  //   required String purchaseRequestId,
  // }) async {
  //
  // }

  // choose a pr
  // check for items in db then automatically fill
  Future<String> createICS({
    required String entityId,
    required FundCluster fundCluster,
    required String purchaseRequestId,
    required String receivingOfficerId,
    required String sendingOfficerId,
    required String issuedDate,
    required List<String> itemIds,
    required int requestedQuantity,
  }) async {
    final issuanceId = await _generateUniqueIssuanceId();
    final icsId = await _generateUniqueIcsId();

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
        final matchedItemResult = await _conn.execute(
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

        final itemId = matchedItemResult.first[0] as int;
        final fetchedItemQuantity = matchedItemResult.first[1] as int;
        final issuedQuantity = min(requestedQuantity, fetchedItemQuantity);
        final remainingRequestedQuantityAfterIssued =
            requestedQuantity - issuedQuantity;

        /// insert record to item issuance
        await _conn.execute(
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

        // Update the remaining requested quantity
        requestedQuantity -= issuedQuantity;

        /// update remaining quantity and pr status
        await _conn.execute(
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
                : PurchaseRequestStatus.fulfilled,
          },
        );

        /// update item quantity
        await _conn.execute(
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

      /// insert record to base issuance entity only once
      await _conn.execute(
        Sql.named(
          '''
          INSERT INTO Issuances (id, entity_id, fund_cluster, purchase_request_id, receiving_officer_id, issued_date)
          VALUES (@id, @entity_id, @fund_cluster, @purchase_request_id, @receiving_officer_id, @issued_date);
          ''',
        ),
        parameters: {
          'id': issuanceId,
          'entity_id': entityId,
          'fund_cluster': fundCluster
              .toString()
              .split('.')
              .last,
          'purchase_request_id': purchaseRequestId,
          'receiving_officer_id': receivingOfficerId,
          'issued_date': DateTime.now().toIso8601String(),
        },
      );

      /// insert record to concrete issuance entity only once
      await _conn.execute(
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
    });

    return issuanceId;
  }
}