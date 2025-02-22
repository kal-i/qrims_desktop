import 'dart:math';

import 'package:api/src/entity/repository/entity_repository.dart';
import 'package:api/src/item/models/item.dart';
import 'package:api/src/organization_management/repositories/office_repository.dart';
import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/purchase_request/model/purchase_request.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:api/src/utils/qr_code_utils.dart';
import 'package:postgres/postgres.dart';

import '../../entity/model/entity.dart';
import '../../organization_management/models/office.dart';
import '../../organization_management/models/officer.dart';
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

  Future<String> _generateUniqueRisId() async {
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    print('Current year-month for RIS ID: $yearMonth');

    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT id FROM RequisitionAndIssueSlips
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
    print('Generated RIS ID: $uniqueId');
    return uniqueId;
  }

  Future<List<IssuanceItem>> _getIssuanceItems({
    required String issuanceId,
  }) async {
    final itemList = <BaseItemModel>[];
    final issuanceItems = <IssuanceItem>[];

    final issuanceItemsResult = await _conn.execute(
      Sql.named('''
      SELECT
        iss.*, 
        i.*,
        pn.name as product_name,
        pd.description as product_description,
        s.id as supply_id,
        e.id as equipment_id,
        e.manufacturer_id,
        e.brand_id,
        e.model_id,
        e.serial_no,
        e.asset_classification,
        e.asset_sub_class,
        e.unit_cost,
        e.estimated_useful_life,
        e.acquired_date,
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
        Supplies s ON i.id = s.base_item_id
      LEFT JOIN
        Equipment e ON i.id = e.base_item_id
      LEFT JOIN
        Manufacturers mnf ON e.manufacturer_id =  mnf.id
      LEFT JOIN
        Brands brnd ON e.brand_id = brnd.id
      LEFT JOIN
        Models md ON e.model_id = md.id
      WHERE 
        iss.issuance_id = @issuance_id
      '''),
      parameters: {
        'issuance_id': issuanceId,
      },
    );

    for (final row in issuanceItemsResult) {
      if (row[13] != null) {
        final supplyMap = {
          'supply_id': row[13],
          'base_item_id': row[3],
          'product_name_id': row[4],
          'product_description_id': row[5],
          'specification': row[6],
          'unit': row[7],
          'quantity': row[8],
          'encrypted_id': row[9],
          'qr_code_image_data': row[10],
          'product_name': row[11],
          'product_description': row[12],
        };
        itemList.add(Supply.fromJson(supplyMap));
      } else if (row[14] != null) {
        final equipmentMap = {
          'equipment_id': row[14],
          'base_item_id': row[3],
          'product_name_id': row[4],
          'product_description_id': row[5],
          'specification': row[6],
          'unit': row[7],
          'quantity': row[8],
          'encrypted_id': row[9],
          'qr_code_image_data': row[10],
          'product_name': row[11],
          'product_description': row[12],
          'manufacturer_id': row[15],
          'brand_id': row[16],
          'model_id': row[17],
          'serial_no': row[18],
          'asset_classification': row[19],
          'asset_sub_class': row[20],
          'unit_cost': row[21],
          'estimated_useful_life': row[22],
          'acquired_date': row[23],
          'manufacturer_name': row[24],
          'brand_name': row[25],
          'model_name': row[26],
        };
        itemList.add(Equipment.fromJson(equipmentMap));
      }

      print('issuance item result: $issuanceItemsResult');

      issuanceItems.add(
        IssuanceItem.fromJson(
          {
            'issuance_id': row[0],
            'item': itemList
                .map((item) => item is Supply
                    ? item.toJson()
                    : (item as Equipment).toJson())
                .toList(),
            'issued_quantity': row[2],
          },
        ),
      );
    }

    print('returned issuance items: $issuanceItems');

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
        par.id AS par_id,
        ris.id AS ris_id
      FROM
        Issuances iss
      LEFT JOIN
        InventoryCustodianSlips ics ON iss.id = ics.issuance_id
      LEFT JOIN
        PropertyAcknowledgementReceipts par ON iss.id = par.issuance_id
      LEFT JOIN
        RequisitionAndIssueSlips ris ON iss.id = ris.issuance_id
      WHERE 
        iss.id = @id;
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
      final isICS = row[11] != null;
      final isPAR = row[12] != null;
      final isRIS = row[13] != null;

      if (isICS) {
        print('ICS');
        return await getIcsById(id: row[0] as String);
      }

      if (isPAR) {
        return await getParById(id: row[0] as String);
      }

      if (isRIS) {
        return await getRisById(id: row[0] as String);
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
      issuanceId: id,
    );

    final issuanceResult = await _conn.execute(
      Sql.named(
        '''
      SELECT
        iss.*,
        ics.id AS ics_id
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
      PurchaseRequest? purchaseRequest;
      Entity? entity;
      FundCluster? fundCluster;
      Officer? receivingOfficer;
      Officer? issuingOfficer;

      if (row[3] != null) {
        purchaseRequest =
            await PurchaseRequestRepository(_conn).getPurchaseRequestById(
          id: row[3] as String,
        );
        print('converted pr');
      }

      if (row[4] != null) {
        entity = await EntityRepository(_conn).getEntityById(
          id: row[4] as String,
        );
        print('converted entity');
      }

      if (row[5] != null) {
        fundCluster = FundCluster.values.firstWhere(
          (e) => e.toString().split('.').last == row[5],
        );
      }

      if (row[6] != null) {
        receivingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[6] as String,
        );
        print('converted receiving off');
      }

      if (row[7] != null) {
        issuingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[7] as String,
        );
        print('converted issuing off');
      }

      return InventoryCustodianSlip.fromJson({
        'id': row[0],
        'ics_id': row[11],
        'issued_date': row[1],
        'return_date': row[2],
        'items':
            issuanceItems.map((issuanceItem) => issuanceItem.toJson()).toList(),
        'purchase_request': purchaseRequest?.toJson(),
        'entity': entity?.toJson(),
        'fund_cluster': fundCluster,
        'receiving_officer': receivingOfficer?.toJson(),
        'issuing_officer': issuingOfficer?.toJson(),
        'qr_code_image_data': row[8],
        'status': row[9],
        'is_archived': row[10],
      });
    }

    return null;
  }

  Future<PropertyAcknowledgementReceipt?> getParById({
    required String id,
  }) async {
    print('processing issuance items');
    final issuanceItems = await _getIssuanceItems(
      issuanceId: id,
    );

    print('processed issuance items: $issuanceItems');

    final issuanceResult = await _conn.execute(
      Sql.named(
        '''
      SELECT
        iss.*,
        par.id AS par_id
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

    print('query executed');

    for (final row in issuanceResult) {
      PurchaseRequest? purchaseRequest;
      Entity? entity;
      FundCluster? fundCluster;
      Officer? receivingOfficer;
      Officer? issuingOfficer;

      if (row[3] != null) {
        purchaseRequest =
            await PurchaseRequestRepository(_conn).getPurchaseRequestById(
          id: row[3] as String,
        );
        print('converted pr');
      }

      if (row[4] != null) {
        entity = await EntityRepository(_conn).getEntityById(
          id: row[4] as String,
        );
        print('converted entity');
      }

      if (row[5] != null) {
        fundCluster = FundCluster.values.firstWhere(
          (e) => e.toString().split('.').last == row[5],
        );
      }

      if (row[6] != null) {
        receivingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[6] as String,
        );
        print('converted receiving off');
      }

      if (row[7] != null) {
        issuingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[7] as String,
        );
        print('converted issuing off');
      }

      print('sen off');
      final parObj = PropertyAcknowledgementReceipt.fromJson(
        {
          'id': row[0],
          'par_id': row[11],
          'issued_date': row[1],
          'return_date': row[2],
          'items': issuanceItems
              .map((issuanceItem) => issuanceItem.toJson())
              .toList(),
          'purchase_request': purchaseRequest?.toJson(),
          'entity': entity?.toJson(),
          'fund_cluster': fundCluster,
          'receiving_officer': receivingOfficer?.toJson(),
          'issuing_officer': issuingOfficer?.toJson(),
          'qr_code_image_data': row[8],
          'status': row[9],
          'is_archived': row[10],
        },
      );

      print('par obj: -------$parObj');
      return parObj;
    }

    return null;
  }

  Future<RequisitionAndIssueSlip?> getRisById({
    required String id,
  }) async {
    print('processing issuance items');
    final issuanceItems = await _getIssuanceItems(
      issuanceId: id,
    );

    print('processed issuance items: $issuanceItems');

    final issuanceResult = await _conn.execute(
      Sql.named(
        '''
      SELECT
        iss.*,
        ris.id AS ris_id,
        ris.division AS division,
        ris.responsibility_center_code AS responsiblity_center_code,
        ris.office AS office,
        ris.purpose AS purpose,
        ris.approving_officer_id as approving_officer_id,
        ris.requesting_officer_id as requesting_officer_id
      FROM
        Issuances iss
      JOIN
        RequisitionAndIssueSlips ris ON iss.id = ris.issuance_id
      WHERE
        iss.id = @issuance_id;
      ''',
      ),
      parameters: {
        'issuance_id': id,
      },
    );

    print('query executed');

    for (final row in issuanceResult) {
      PurchaseRequest? purchaseRequest;
      Entity? entity;
      FundCluster? fundCluster;
      Office? office;
      Officer? receivingOfficer;
      Officer? issuingOfficer;
      Officer? approvingOfficer;
      Officer? requestingOfficer;

      if (row[3] != null) {
        purchaseRequest =
            await PurchaseRequestRepository(_conn).getPurchaseRequestById(
          id: row[3] as String,
        );
        print('converted pr');
      }

      if (row[4] != null) {
        entity = await EntityRepository(_conn).getEntityById(
          id: row[4] as String,
        );
        print('converted entity');
      }

      if (row[5] != null) {
        fundCluster = FundCluster.values.firstWhere(
          (e) => e.toString().split('.').last == row[5],
        );
      }

      if (row[6] != null) {
        receivingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[6] as String,
        );
        print('converted receiving off');
      }

      if (row[7] != null) {
        issuingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[7] as String,
        );
        print('converted issuing off');
      }

      if (row[8] != null) {
        approvingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[16] as String,
        );
        print('converted approving off');
      }

      if (row[9] != null) {
        requestingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[17] as String,
        );
        print('converted requesting off');
      }

      if (row[14] != null) {
        office = await OfficeRepository(_conn).getOfficeById(
          id: row[14] as String,
        );
      }

      final risObj = RequisitionAndIssueSlip.fromJson(
        {
          'id': row[0],
          'ris_id': row[11],
          'issued_date': row[1],
          'return_date': row[2],
          'items': issuanceItems
              .map((issuanceItem) => issuanceItem.toJson())
              .toList(),
          'purchase_request': purchaseRequest?.toJson(),
          'entity': entity?.toJson(),
          'fund_cluster': fundCluster,
          'divison': row[12],
          'responsibility_center_code': row[13],
          'office': office?.toJson(),
          'purpose': row[15],
          'approving_officer': approvingOfficer?.toJson(),
          'issuing_officer': issuingOfficer?.toJson(),
          'receiving_officer': receivingOfficer?.toJson(),
          'requested_officer': requestingOfficer?.toJson(),
          'qr_code_image_data': row[8],
          'status': row[9],
          'is_archived': row[10],
        },
      );

      print('ris obj: -------$risObj');
      return risObj;
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

      print(issueDateStart);

      final baseQuery = '''
      SELECT COUNT(*)
      FROM Issuances iss
      LEFT JOIN InventoryCustodianSlips ics ON iss.id = ics.issuance_id
      LEFT JOIN PropertyAcknowledgementReceipts par ON iss.id = par.issuance_id
      LEFT JOIN RequisitionAndIssueSlips ris ON iss.id = ris.issuance_id
      ''';

      final whereClause = StringBuffer('WHERE iss.is_archived = @is_archived');
      params['is_archived'] = isArchived;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(' AND iss.id ILIKE @search_query');
        params['search_query'] = '%$searchQuery%';
      }

      if (issueDateStart != null) {
        whereClause.write(' AND iss.issued_date >= @issue_date_start');
        params['issue_date_start'] = issueDateStart;
      }
      if (issueDateEnd != null) {
        whereClause.write(' AND iss.issued_date <= @issue_date_end');
        params['issue_date_end'] = issueDateEnd;
      } else {
        // Default the end date to today if it's null
        whereClause.write(' AND iss.issued_date <= @issue_date_end');
        params['issue_date_end'] = DateTime.now();
      }

      if (type != null && type.isNotEmpty) {
        whereClause.write(
            ' AND (ics.id IS NOT NULL OR par.id IS NOT NULL OR ris.id IS NOT NULL)');
        if (type == 'ics') {
          whereClause.write(' AND ics.id IS NOT NULL');
        } else if (type == 'par') {
          whereClause.write(' AND par.id IS NOT NULL');
        } else if (type == 'ris') {
          whereClause.write(' AND ris.id IS NOT NULL');
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
        par.id AS par_id,
        ris.id AS ris_id
      FROM
        Issuances iss
      LEFT JOIN
        InventoryCustodianSlips ics ON iss.id = ics.issuance_id
      LEFT JOIN
        PropertyAcknowledgementReceipts par ON iss.id = par.issuance_id
      LEFT JOIN
        RequisitionAndIssueSlips ris ON iss.id = ris.issuance_id
      ''';

      final whereClause = StringBuffer('WHERE iss.is_archived = @is_archived');
      params['is_archived'] = isArchived;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(' AND iss.id ILIKE @search_query');
        params['search_query'] = '%$searchQuery%';
      }

      if (issueDateStart != null) {
        whereClause.write(' AND iss.issued_date >= @issue_date_start');
        params['issue_date_start'] = issueDateStart;
      }
      if (issueDateEnd != null) {
        whereClause.write(' AND iss.issued_date <= @issue_date_end');
        params['issue_date_end'] = issueDateEnd;
      } else {
        // Default the end date to today if it's null
        whereClause.write(' AND iss.issued_date <= @issue_date_end');
        params['issue_date_end'] = DateTime.now();
      }

      if (type != null && type.isNotEmpty) {
        whereClause.write(
            ' AND (ics.id IS NOT NULL OR par.id IS NOT NULL OR ris.id IS NOT NULL)');
        if (type == 'ics') {
          whereClause.write(' AND ics.id IS NOT NULL');
        } else if (type == 'par') {
          whereClause.write(' AND par.id IS NOT NULL');
        } else if (type == 'ris') {
          whereClause.write(' AND ris.id IS NOT NULL');
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
        final isICS = row[11] != null;
        final isPAR = row[12] != null;
        final isRIS = row[13] != null;

        if (isICS) {
          final ics = await getIcsById(id: row[0] as String);
          issuances.add(ics!);
        }

        if (isPAR) {
          final par = await getParById(id: row[0] as String);
          issuances.add(par!);
        }

        if (isRIS) {
          final ris = await getRisById(id: row[0] as String);
          issuances.add(ris!);
        }
      }

      return issuances;
    } catch (e) {
      print('Error fetching issuances: $e');
      throw Exception('Failed to fetch issuances.');
    }
  }

  // need to fix my logic here, it is a list of items after
  Future<List<Map<String, dynamic>>?> matchingItemFromPurchaseRequest({
    required String purchaseRequestId,
    required List<RequestedItem> requestedItems,
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
        LEFT JOIN
          RequestedItems ri
        ON
          i.product_name_id = ri.product_name_id
        AND
          i.product_description_id = ri.product_description_id
        AND
          i.unit = pr.unit
        -- AND
          -- i.unit_cost = pr.unit_cost
        WHERE
          pr.id = @pr_id
        AND 
          i.quantity > 0
        LIMIT 1;
        ''';

    await _conn.runTx((ctx) async {
      for (int i = 0; i < requestedItems.length; i++) {
        final requestedItem = requestedItems[i];
        int requestedQuantity = requestedItem.quantity;

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
      }

      // while (requestedQuantity > 0) {
      //   /// Check if an item matches the pr and retrieve its id
      //   final matchedItemResult = await ctx.execute(
      //     Sql.named(
      //       matchingItemQuery,
      //     ),
      //     parameters: {
      //       'pr_id': purchaseRequestId,
      //     },
      //   );

      //   if (matchedItemResult.isEmpty) {
      //     break;
      //   }

      //   final itemId = matchedItemResult.first[0] as String;
      //   final fetchedItemQuantity = matchedItemResult.first[1] as int;
      //   final issuedQuantity = min(requestedQuantity, fetchedItemQuantity);

      //   requestedQuantity -= issuedQuantity;

      //   print(requestedQuantity);

      //   matchedItemList.add(
      //     {
      //       'item_id': itemId,
      //       'issued_quantity': issuedQuantity,
      //     },
      //   );

      //   /// update item quantity
      //   await ctx.execute(
      //     Sql.named(
      //       '''
      //     UPDATE Items
      //     SET quantity = @quantity
      //     WHERE id = @id;
      //     ''',
      //     ),
      //     parameters: {
      //       'id': itemId,
      //       'quantity': fetchedItemQuantity - issuedQuantity,
      //     },
      //   );
      // }

      // Rollback the transaction to undo changes after testing
      await ctx.rollback();
    });
    return matchedItemList;
  }

  Future<String> _createIssuance({
    required List<dynamic> issuanceItems,
    PurchaseRequest? purchaseRequest,
    String? entityId,
    FundCluster? fundCluster,
    String? receivingOfficerId,
    String? issuingOfficerId,
    required String concreteIssuanceEntityQuery,
    required Map<String, dynamic> concreteIssuanceEntityParams,
  }) async {
    final issuanceId = await _generateUniqueIssuanceId();
    final qrCodeImageData = await QrCodeUtils.generateQRCode(issuanceId);

    await _conn.runTx(
      (ctx) async {
        try {
          // Step 1: Insert into the Issuances table
          await ctx.execute(
            Sql.named(
              '''
            INSERT INTO Issuances (
              id, purchase_request_id, entity_id, fund_cluster, 
              receiving_officer_id, issuing_officer_id, issued_date, qr_code_image_data
            )
            VALUES (
              @id, @purchase_request_id, @entity_id, @fund_cluster, 
              @receiving_officer_id, @issuing_officer_id, @issued_date, @qr_code_image_data
            );
            ''',
            ),
            parameters: {
              'id': issuanceId,
              'purchase_request_id': purchaseRequest?.id,
              'entity_id': entityId,
              'fund_cluster': fundCluster?.toString().split('.').last,
              'receiving_officer_id': receivingOfficerId,
              'issuing_officer_id': issuingOfficerId,
              'issued_date': DateTime.now().toIso8601String(),
              'qr_code_image_data': qrCodeImageData,
            },
          );

          // Step 2: Insert into the concrete issuance table
          concreteIssuanceEntityParams['issuance_id'] = issuanceId;
          await ctx.execute(
            Sql.named(concreteIssuanceEntityQuery),
            parameters: concreteIssuanceEntityParams,
          );

          if (purchaseRequest == null) {
            // Handle issuance without PR
            for (final issuance in issuanceItems) {
              final itemId = issuance['item_id'] as String;
              final issuedQuantity = issuance['issued_quantity'] as int;

              // Step 3: Insert into IssuanceItems table
              await ctx.execute(
                Sql.named(
                  '''
                INSERT INTO IssuanceItems (issuance_id, item_id, issued_quantity)
                VALUES (@issuance_id, @item_id, @issued_quantity);
                ''',
                ),
                parameters: {
                  'issuance_id': issuanceId,
                  'item_id': itemId,
                  'issued_quantity': issuedQuantity,
                },
              );

              // Step 4: Update the Items table to reduce stock
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
                  'quantity': issuedQuantity,
                },
              );
            }
          } else {
            // Handle issuance with PR
            int totalRemainingQuantities = 0;

            // Preprocess issuanceItems into a map for faster lookup
            final Map<String, dynamic> issuanceItemsMap = {};
            for (final issuanceItem in issuanceItems) {
              final key =
                  '${issuanceItem['product_stock']['product_name']['product_name_id']}-'
                  '${issuanceItem['product_stock']['product_description']['product_description_id']}-'
                  '${issuanceItem['shareable_item_information']['unit']}';
              issuanceItemsMap[key] = issuanceItem;
            }

            // Iterate through each requested item in the purchase request
            for (final requestedItem in purchaseRequest.requestedItems) {
              final requestedProductNameId = requestedItem.productName.id;
              final requestedProductDescriptionId =
                  requestedItem.productDescription.id;
              final requestedUnit =
                  requestedItem.unit.toString().split('.').last;

              // Construct a key for the requested item
              final key =
                  '$requestedProductNameId-$requestedProductDescriptionId-$requestedUnit';

              // Check if the issuanceItems map contains the requested item
              if (issuanceItemsMap.containsKey(key)) {
                final issuanceItem = issuanceItemsMap[key];
                final issuanceBaseItemId =
                    issuanceItem['shareable_item_information']['base_item_id'];
                final issuanceQuantity =
                    int.parse(issuanceItem['issued_quantity'] as String);

                // Calculate the quantity to issue
                final issuedQuantity =
                    min(requestedItem.quantity, issuanceQuantity);

                if (issuedQuantity > 0) {
                  // Step 3: Insert into IssuanceItems table
                  await ctx.execute(
                    Sql.named(
                      '''
                    INSERT INTO IssuanceItems (issuance_id, item_id, issued_quantity)
                    VALUES (@issuance_id, @item_id, @issued_quantity);
                    ''',
                    ),
                    parameters: {
                      'issuance_id': issuanceId,
                      'item_id': issuanceBaseItemId,
                      'issued_quantity': issuedQuantity,
                    },
                  );

                  // Step 4: Update the RequestedItems table
                  final remainingRequestedQuantity =
                      requestedItem.quantity - issuedQuantity;
                  totalRemainingQuantities += remainingRequestedQuantity;

                  await ctx.execute(
                    Sql.named(
                      '''
                    UPDATE RequestedItems
                    SET remaining_quantity = @remaining_quantity
                    WHERE id = @id;
                    ''',
                    ),
                    parameters: {
                      'id': requestedItem.id,
                      'remaining_quantity': remainingRequestedQuantity,
                    },
                  );

                  // Step 5: Update the Items table to reduce stock
                  await ctx.execute(
                    Sql.named(
                      '''
                    UPDATE Items
                    SET quantity = quantity - @quantity
                    WHERE id = @id;
                    ''',
                    ),
                    parameters: {
                      'id': issuanceBaseItemId,
                      'quantity': issuedQuantity,
                    },
                  );
                }
              }
            }

            // Step 6: Update the PurchaseRequest status
            await ctx.execute(
              Sql.named(
                '''
              UPDATE PurchaseRequests
              SET status = @status
              WHERE id = @id;
              ''',
              ),
              parameters: {
                'id': purchaseRequest.id,
                'status': totalRemainingQuantities > 0
                    ? PurchaseRequestStatus.partiallyFulfilled
                        .toString()
                        .split('.')
                        .last
                    : PurchaseRequestStatus.fulfilled
                        .toString()
                        .split('.')
                        .last,
              },
            );
          }

          print('Issuance process completed. Issuance ID: $issuanceId');
        } catch (e, stackTrace) {
          print('Transaction failed: $e');
          print('Stack trace: $stackTrace');
          await ctx.rollback();
          rethrow;
        }
      },
    );

    return issuanceId;
  }

  // Future<String> _createIssuance({
  //   required PurchaseRequest purchaseRequest,
  //   required List<dynamic> issuanceItems,
  //   required String receivingOfficerId,
  //   required String concreteIssuanceEntityQuery,
  //   required Map<String, dynamic> concreteIssuanceEntityParams,
  // }) async {
  //   final issuanceId = await _generateUniqueIssuanceId();
  //   final qrCodeImageData = await QrCodeUtils.generateQRCode(issuanceId);

  //   // re modify logic
  //   // re check first if it matches the item before creating an issuamce

  //   await _conn.runTx(
  //     (ctx) async {
  //       try {
  //         // Insert into Issuances table
  //         await ctx.execute(
  //           Sql.named(
  //             '''
  //       INSERT INTO Issuances (id, purchase_request_id, receiving_officer_id, issued_date, qr_code_image_data)
  //       VALUES (@id, @purchase_request_id, @receiving_officer_id, @issued_date, @qr_code_image_data);
  //       ''',
  //           ),
  //           parameters: {
  //             'id': issuanceId,
  //             'purchase_request_id': purchaseRequest.id,
  //             'receiving_officer_id': receivingOfficerId,
  //             'issued_date': DateTime.now().toIso8601String(),
  //             'qr_code_image_data': qrCodeImageData,
  //           },
  //         );

  //         // Insert into the concrete issuance table (either InventoryCustodianSlips or PropertyAcknowledgementReceipts)
  //         concreteIssuanceEntityParams['issuance_id'] = issuanceId;
  //         await ctx.execute(
  //           Sql.named(
  //             concreteIssuanceEntityQuery,
  //           ),
  //           parameters: concreteIssuanceEntityParams,
  //         );

  //         int remainingQuantities = 0;
  //         final Set<String> processedItems = {}; // track processed items

  //         print('starting the issuance process...');
  //         print('${purchaseRequest.requestedItems.length}');

  //         for (final requestedItem in purchaseRequest.requestedItems) {
  //           print('current requested item being processed: $requestedItem');
  //           int remainingRequestedQuantity = requestedItem.quantity;
  //           final requestedProductNameId = requestedItem.productName.id;
  //           final requestedProductDescriptionId =
  //               requestedItem.productDescription.id;
  //           final requestedUnit = requestedItem.unit.toString().split('.').last;

  //           print(
  //               'Processing requested item: $requestedProductNameId - $requestedProductDescriptionId ($requestedUnit)');

  //           for (final issuanceItem in issuanceItems) {
  //             final issuanceBaseItemId =
  //                 issuanceItem['shareable_item_information']['base_item_id'];

  //             if (processedItems.contains(issuanceBaseItemId))
  //               continue; // Avoid duplicate insertions

  //             final issuanceProductNameId = issuanceItem['product_stock']
  //                 ['product_name']['product_name_id'];
  //             final issuanceProductDescriptionId = issuanceItem['product_stock']
  //                 ['product_description']['product_description_id'];
  //             final issuanceUnit =
  //                 issuanceItem['shareable_item_information']['unit'];
  //             final issuanceQuantity =
  //                 int.parse(issuanceItem['issued_quantity'] as String);

  //             print('matching.......................');
  //             print('$requestedProductNameId - $issuanceProductNameId');
  //             print(
  //                 '$requestedProductDescriptionId - $issuanceProductDescriptionId');
  //             print('$requestedUnit - $issuanceUnit');

  //             if (requestedProductNameId == issuanceProductNameId &&
  //                 requestedProductDescriptionId ==
  //                     issuanceProductDescriptionId &&
  //                 requestedUnit == issuanceUnit) {
  //               print('Item matched. Processing issuance...');

  //               final issuedQuantity =
  //                   min(remainingRequestedQuantity, issuanceQuantity);

  //               print('issued quantity: $issuedQuantity');

  //               if (issuedQuantity > 0) {
  //                 print('issue successful');

  //                 // Insert into IssuanceItems table
  //                 await ctx.execute(
  //                   Sql.named(
  //                     '''
  //                 INSERT INTO IssuanceItems (issuance_id, item_id, issued_quantity)
  //                 VALUES (@issuance_id, @item_id, @issued_quantity);
  //                 ''',
  //                   ),
  //                   parameters: {
  //                     'issuance_id': issuanceId,
  //                     'item_id': issuanceBaseItemId,
  //                     'issued_quantity': issuanceQuantity,
  //                   },
  //                 );

  //                 processedItems.add(
  //                     issuanceBaseItemId as String); // Mark item as processed

  //                 // Update the requested quantity
  //                 remainingRequestedQuantity -= issuedQuantity;
  //                 remainingQuantities = remainingRequestedQuantity;

  //                 // Update the RequestedItems table
  //                 // an id here to avoid confliction if several items with similar info are there
  //                 await ctx.execute(
  //                   Sql.named(
  //                     '''
  //               UPDATE RequestedItems
  //               SET remaining_quantity = @remaining_quantity
  //               WHERE id = @id;
  //               ''',
  //                   ),
  //                   parameters: {
  //                     'id': requestedItem.id,
  //                     'remaining_quantity': remainingRequestedQuantity,
  //                   },
  //                 );

  //                 // Update the Items table to reduce stock
  //                 await ctx.execute(
  //                   Sql.named(
  //                     '''
  //               UPDATE Items
  //               SET quantity = quantity - @quantity
  //               WHERE id = @id;
  //               ''',
  //                   ),
  //                   parameters: {
  //                     'id': issuanceBaseItemId,
  //                     'quantity': issuedQuantity,
  //                   },
  //                 );

  //                 print('update inv item done');

  //                 if (remainingRequestedQuantity <= 0)
  //                   break; // Stop if request is fulfilled
  //               }
  //             }
  //             print('matching item failed');
  //           }
  //         }

  //         print('processing update pr');
  //         // Update PR status
  //         await ctx.execute(
  //           Sql.named(
  //             '''
  //           UPDATE PurchaseRequests
  //           SET status = @status
  //           WHERE id = @id;
  //           ''',
  //           ),
  //           parameters: {
  //             'id': purchaseRequest.id,
  //             'status': remainingQuantities > 0
  //                 ? PurchaseRequestStatus.partiallyFulfilled
  //                     .toString()
  //                     .split('.')
  //                     .last
  //                 : PurchaseRequestStatus.fulfilled.toString().split('.').last,
  //           },
  //         );

  //         print('Issuance process completed. Issuance ID: $issuanceId');
  //       } catch (e) {
  //         print('Transaction failed: $e');
  //         await ctx.rollback();
  //         rethrow;
  //       }
  //     },
  //   );
  //   return issuanceId;
  // }

  Future<String> createICS({
    required List<dynamic> issuanceItems,
    PurchaseRequest? purchaseRequest,
    String? entityId,
    FundCluster? fundCluster,
    String? receivingOfficerId,
    String? issuingOfficerId,
  }) async {
    final icsId = await _generateUniqueIcsId();

    final concreteIssuanceEntityQuery = '''
    INSERT INTO InventoryCustodianSlips (id, issuance_id)
    VALUES (@id, @issuance_id);
    ''';

    final concreteIssuanceEntityParams = {
      'id': icsId,
    };

    return await _createIssuance(
      issuanceItems: issuanceItems,
      purchaseRequest: purchaseRequest,
      entityId: entityId,
      fundCluster: fundCluster,
      receivingOfficerId: receivingOfficerId,
      issuingOfficerId: issuingOfficerId,
      concreteIssuanceEntityQuery: concreteIssuanceEntityQuery,
      concreteIssuanceEntityParams: concreteIssuanceEntityParams,
    );
  }

  Future<String> createPAR({
    required List<dynamic> issuanceItems,
    PurchaseRequest? purchaseRequest,
    String? entityId,
    FundCluster? fundCluster,
    String? receivingOfficerId,
    String? issuingOfficerId,
  }) async {
    final parId = await _generateUniqueParId();

    final concreteIssuanceEntityQuery = '''
    INSERT INTO PropertyAcknowledgementReceipts (id, issuance_id)
    VALUES (@id, @issuance_id);
    ''';

    final concreteIssuanceEntityParams = {
      'id': parId,
    };

    return await _createIssuance(
      issuanceItems: issuanceItems,
      purchaseRequest: purchaseRequest,
      entityId: entityId,
      fundCluster: fundCluster,
      receivingOfficerId: receivingOfficerId,
      issuingOfficerId: issuingOfficerId,
      concreteIssuanceEntityQuery: concreteIssuanceEntityQuery,
      concreteIssuanceEntityParams: concreteIssuanceEntityParams,
    );
  }

  Future<String> createRIS({
    required List<dynamic> issuanceItems,
    PurchaseRequest? purchaseRequest,
    String? entityId,
    FundCluster? fundCluster,
    String? division,
    String? responsibilityCenterCode,
    String? officeId,
    String? purpose,
    String? receivingOfficerId,
    String? issuingOfficerId,
    String? approvingOfficerId,
    String? requestingOfficerId,
  }) async {
    final risId = await _generateUniqueRisId();

    print('Generated RIS id: $risId');

    final concreteIssuanceEntityQuery = '''
    INSERT INTO RequisitionAndIssueSlips (
      id, 
      issuance_id, 
      division,
      responsibility_center_code,
      office_id,
      purpose,
      approving_officer_id,
      requesting_officer_id
    )
    VALUES (
      @id, 
      @issuance_id,
      @division,
      @responsibility_center_code,
      @office_id,
      @purpose, 
      @approving_officer_id,
      @requesting_officer_id
      );
    ''';

    final concreteIssuanceEntityParams = {
      'id': risId,
      'division': division,
      'responsibility_center_code': responsibilityCenterCode,
      'office_id': officeId,
      'purpose': purpose,
      'approving_officer_id': approvingOfficerId,
      'requesting_officer_id': requestingOfficerId,
    };

    return await _createIssuance(
      purchaseRequest: purchaseRequest,
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

  Future<bool> updateIssuanceArchiveStatus({
    required String id,
    required bool isArchived,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        UPDATE Issuances
        SET is_archived = @is_archived
        WHERE id = @id;
        ''',
      ),
      parameters: {
        'id': id,
        'is_archived': isArchived,
      },
    );

    return result.affectedRows == 1;
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
