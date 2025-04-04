import 'dart:math';

import 'package:api/src/entity/repository/entity_repository.dart';
import 'package:api/src/item/models/item.dart';
import 'package:api/src/organization_management/repositories/office_repository.dart';
import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/purchase_request/model/purchase_request.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:api/src/utils/fund_cluster_value_extension.dart';
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

  // Future<String> _generateUniqueIcsId({
  //   IcsType? type,
  //   FundCluster? fundCluster,
  //   required DateTime issuedDate,
  // }) async {
  //   final yearMonth =
  //       "${issuedDate.year}-${issuedDate.month.toString().padLeft(2, '0')}";

  //   // Fetch the maximum sequence number (NNN) for the given year and month
  //   final result = await _conn.execute(
  //     Sql.named(
  //       '''
  //     SELECT id FROM InventoryCustodianSlips
  //     WHERE id LIKE '%$yearMonth-%'
  //     ORDER BY id DESC
  //     LIMIT 1;
  //     ''',
  //     ),
  //   );

  //   int n = 1; // Default sequence number
  //   if (result.isNotEmpty) {
  //     final lastId = result.first[0].toString();
  //     // Extract the sequence number (NNN) from the last ID
  //     final parts = lastId.split('-');
  //     final lastPart = parts.last;
  //     n = int.parse(lastPart) + 1; // Increment the sequence number
  //   }

  //   String uniqueId = '';

  //   // Add type prefix if type exists
  //   if (type != null) {
  //     uniqueId += '${type == IcsType.sphv ? 'SPHV' : 'SPLV'}-';
  //   }

  //   // Add year and fund cluster if fund cluster exists
  //   uniqueId += '${issuedDate.year}';
  //   if (fundCluster != null) {
  //     uniqueId += '(${fundCluster.value})';
  //   }

  //   // Add month and sequence number
  //   uniqueId +=
  //       '-${issuedDate.month.toString().padLeft(2, '0')}-${n.toString().padLeft(3, '0')}';

  //   print('Generated ICS ID: $uniqueId');
  //   return uniqueId;
  // }

  Future<String> _generateUniqueIcsId({
    IcsType? type,
    FundCluster? fundCluster,
    required DateTime issuedDate,
  }) async {
    final yearMonth =
        "${issuedDate.year}-${issuedDate.month.toString().padLeft(2, '0')}";

    // Start building the LIKE pattern for the query
    String likePattern = '%$yearMonth-%';

    // If fundCluster is provided, include it in the pattern
    if (fundCluster != null) {
      likePattern =
          '%${issuedDate.year}(${fundCluster.value})-${issuedDate.month.toString().padLeft(2, '0')}-%';
    }

    // Fetch all IDs for the given year, month, and fund cluster
    final result = await _conn.execute(
      Sql.named(
        '''
    SELECT id FROM InventoryCustodianSlips
    WHERE id LIKE @likePattern
    ORDER BY id DESC;
    ''',
      ),
      parameters: {
        'likePattern': likePattern,
      },
    );

    int maxN = 0; // Track the maximum sequence number

    if (result.isNotEmpty) {
      for (final row in result) {
        final id = row[0].toString();
        // Extract the sequence number (NNN) from the ID
        final parts = id.split('-');
        if (parts.length >= 4) {
          // Changed from 3 to 4 to match your ID structure
          final lastPart = parts.last;
          final currentN = int.tryParse(lastPart) ?? 0;
          if (currentN > maxN) {
            maxN = currentN; // Update the maximum sequence number
          }
        }
      }
    }

    // Increment the maximum sequence number
    final n = maxN + 1;

    String uniqueId = '';

    // Add type prefix if type exists
    if (type != null) {
      uniqueId += '${type == IcsType.sphv ? 'SPHV' : 'SPLV'}-';
    }

    // Add year and fund cluster if fund cluster exists
    uniqueId += '${issuedDate.year}';
    if (fundCluster != null) {
      uniqueId += '(${fundCluster.value})';
    }

    // Add month and sequence number
    uniqueId +=
        '-${issuedDate.month.toString().padLeft(2, '0')}-${n.toString().padLeft(3, '0')}';

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
        e.estimated_useful_life,
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
      Map<String, dynamic> item = {};

      if (row[15] != null) {
        final supplyMap = {
          'supply_id': row[15],
          'base_item_id': row[3],
          'product_name_id': row[4],
          'product_description_id': row[5],
          'specification': row[6],
          'unit': row[7],
          'quantity': row[8],
          'unit_cost': row[11],
          'encrypted_id': row[9],
          'qr_code_image_data': row[10],
          'acquired_date': row[12],
          'product_name': row[13],
          'product_description': row[14],
        };
        item = Supply.fromJson(supplyMap).toJson();
      } else if (row[16] != null) {
        final equipmentMap = {
          'equipment_id': row[16],
          'base_item_id': row[3],
          'product_name_id': row[4],
          'product_description_id': row[5],
          'specification': row[6],
          'unit': row[7],
          'quantity': row[8],
          'unit_cost': row[11],
          'encrypted_id': row[9],
          'qr_code_image_data': row[10],
          'acquired_date': row[12],
          'product_name': row[13],
          'product_description': row[14],
          'manufacturer_id': row[17],
          'brand_id': row[18],
          'model_id': row[19],
          'serial_no': row[20],
          'asset_classification': row[21],
          'asset_sub_class': row[22],
          'estimated_useful_life': row[23],
          'manufacturer_name': row[24],
          'brand_name': row[25],
          'model_name': row[26],
        };
        item = Equipment.fromJson(equipmentMap).toJson();
      }

      print('issuance item result: $issuanceItemsResult');

      issuanceItems.add(
        IssuanceItem.fromJson(
          {
            'issuance_id': row[0],
            'item': item,
            'issued_quantity': row[2],
          },
        ),
      );
    }

    print('returned issuance items: $issuanceItems');

    return issuanceItems;
  }

  Future<List<BatchItem>> _getBatchItems({
    required String issuanceId,
  }) async {
    final batchItems = <BatchItem>[];

    final results = await _conn.execute(
      Sql.named(
        '''
        SELECT * FROM BatchItems
        WHERE issuance_id = @issuance_id;
        ''',
      ),
      parameters: {
        'issuance_id': issuanceId,
      },
    );

    for (final row in results) {
      final batchMap = {
        'id': row[0],
        'base_item_id': row[1],
        'batch_code': row[2],
        'status': row[3],
        'issuance_id': row[4],
        'created_at': row[5],
        'updated_at': row[6]
      };

      batchItems.add(BatchItem.fromJson(batchMap));
    }

    return batchItems;
  }

  Future<int?> checkSupplierIfExist({
    required String supplierName,
  }) async {
    print('Checking if supplier exists...');
    final result = await _conn.execute(
      Sql.named(
        '''
      SELECT * FROM Suppliers
      WHERE name ILIKE @supplier_name;
      ''',
      ),
      parameters: {
        'supplier_name': supplierName,
      },
    );
    print('Checked if supplier exists.');

    if (result.isNotEmpty) {
      print('Supplier exists.');
      return result.first[0] as int;
    } else {
      print('Supplier does not exist.');
      return null;
    }
  }

  Future<int> registerSupplier({
    required String supplierName,
  }) async {
    print('Registering a new supplier...');
    final result = await _conn.execute(
      Sql.named(
        '''
      INSERT INTO Suppliers (name)
      VALUES (@supplier_name)
      RETURNING supplier_id;
      ''',
      ),
      parameters: {
        'supplier_name': supplierName,
      },
    );
    print('Registered a new supplier.');

    return result.first[0] as int;
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

    // final batchItems = await _getBatchItems(
    //   issuanceId: id,
    // );

    print('ICS issuance items converted.');

    final issuanceResult = await _conn.execute(
      Sql.named(
        '''
      SELECT
        iss.*,
        ics.id AS ics_id,
        ics.supplier_id AS supplier_id,
        s.name AS supplier_name,
        ics.inspection_and_acceptance_report_id AS iar_no,
        ics.contract_number AS cn,
        ics.purchase_order_id AS po_no
      FROM
        Issuances iss
      JOIN
        InventoryCustodianSlips ics ON iss.id = ics.issuance_id
      LEFT JOIN
        Suppliers s ON ics.supplier_id = s.supplier_id
      WHERE
        iss.id = @issuance_id;
      ''',
      ),
      parameters: {
        'issuance_id': id,
      },
    );

    print('ICS query executed.');

    for (final row in issuanceResult) {
      PurchaseRequest? purchaseRequest;
      Entity? entity;
      FundCluster? fundCluster;
      Supplier? supplier;
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

      if (row[12] != null && row[13] != null) {
        supplier = Supplier.fromJson({
          'supplier_id': row[12],
          'name': row[13],
        });
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
        // 'batch_items':
        //     batchItems.map((batchItem) => batchItem.toJson()).toList(),
        'purchase_request': purchaseRequest?.toJson(),
        'entity': entity?.toJson(),
        'fund_cluster': fundCluster,
        'supplier': supplier?.toJson(),
        'inspection_and_acceptance_report_no': row[14],
        'contract_number': row[15],
        'purchase_order_number': row[16],
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
        par.id AS par_id,
		    par.supplier_id AS supplier_id,
		    s.name AS supplier_name,
		    par.inspection_and_acceptance_report_id AS iar_no,
		    par.contract_number AS cn,
		    par.purchase_order_id AS po_no
      FROM
        Issuances iss
      JOIN
        PropertyAcknowledgementReceipts par ON iss.id = par.issuance_id
	    LEFT JOIN
	  	  Suppliers s ON par.supplier_id = s.supplier_id
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
      Supplier? supplier;

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

      if (row[12] != null && row[13] != null) {
        supplier = Supplier.fromJson({
          'supplier_id': row[12],
          'name': row[13],
        });
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
          'supplier': supplier?.toJson(),
          'inspection_and_acceptance_report_no': row[14],
          'contract_number': row[15],
          'purchase_order_number': row[16],
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
        ris.office_id AS office_id,
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

    print('query executed: $issuanceResult');

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
        print('converted fund cluster: $fundCluster');
      }

      if (row[6] != null) {
        receivingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[6] as String,
        );
        print('converted receiving off from ris');
      }

      if (row[7] != null) {
        issuingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[7] as String,
        );
        print('converted issuing off');
      }

      if (row[16] != null) {
        approvingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[16] as String,
        );
        print('converted approving off');
      }

      if (row[17] != null) {
        requestingOfficer = await OfficerRepository(_conn).getOfficerById(
          officerId: row[17] as String,
        );
        print('converted requesting off');
      }

      if (row[14] != null) {
        office = await OfficeRepository(_conn).getOfficeById(
          id: row[14] as String,
        );
        print('converted office');
      }

      print('ris convertion---');

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
        ofc.name,
        ics.id AS ics_id,
        par.id AS par_id,
        ris.id AS ris_id
      FROM
        Issuances iss
      LEFT JOIN
        Officers ofc ON iss.receiving_officer_id = ofc.id
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
        whereClause.write(
            ' AND iss.id ILIKE @search_query OR ofc.name ILIKE @search_query');
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
        final isICS = row[12] != null;
        final isPAR = row[13] != null;
        final isRIS = row[14] != null;

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
    required DateTime issuedDate,
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
          await _insertIssuance(
              ctx,
              issuanceId,
              issuedDate,
              purchaseRequest,
              entityId,
              fundCluster,
              receivingOfficerId,
              issuingOfficerId,
              qrCodeImageData);

          // Step 2: Insert into the concrete issuance table
          await _insertConcreteIssuance(
            ctx,
            concreteIssuanceEntityQuery,
            concreteIssuanceEntityParams,
            issuanceId,
          );

          if (purchaseRequest == null) {
            // Handle issuance without PR
            await _handleIssuanceWithoutPR(
              ctx,
              issuanceId,
              issuanceItems,
            );
          } else {
            // Handle issuance with PR
            await _handleIssuanceWithPR(
              ctx,
              issuanceId,
              purchaseRequest,
              issuanceItems,
            );
          }

          print('Issuance process completed. Issuance ID: $issuanceId');

          // To be remove later
          //await ctx.rollback();
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

  Future<void> _insertIssuance(
    TxSession ctx,
    String issuanceId,
    DateTime issuedDate,
    PurchaseRequest? purchaseRequest,
    String? entityId,
    FundCluster? fundCluster,
    String? receivingOfficerId,
    String? issuingOfficerId,
    String qrCodeImageData,
  ) async {
    await ctx.execute(
      Sql.named(
        '''
        INSERT INTO Issuances (
          id, issued_date, purchase_request_id, entity_id, fund_cluster, 
          receiving_officer_id, issuing_officer_id, qr_code_image_data
        )
        VALUES (
          @id, @issued_date, @purchase_request_id, @entity_id, @fund_cluster, 
          @receiving_officer_id, @issuing_officer_id, @qr_code_image_data
        );
        ''',
      ),
      parameters: {
        'id': issuanceId,
        'issued_date': issuedDate.toIso8601String(),
        'purchase_request_id': purchaseRequest?.id,
        'entity_id': entityId,
        'fund_cluster': fundCluster?.toString().split('.').last,
        'receiving_officer_id': receivingOfficerId,
        'issuing_officer_id': issuingOfficerId,
        'qr_code_image_data': qrCodeImageData,
      },
    );

    print('Base Issuance created.');
  }

  Future<void> _insertConcreteIssuance(
    TxSession ctx,
    String concreteIssuanceEntityQuery,
    Map<String, dynamic> concreteIssuanceEntityParams,
    String issuanceId,
  ) async {
    print('contrete issuance entity query: $concreteIssuanceEntityQuery');
    print('contrete issuance entity params: $concreteIssuanceEntityParams');

    concreteIssuanceEntityParams['issuance_id'] = issuanceId;
    await ctx.execute(
      Sql.named(concreteIssuanceEntityQuery),
      parameters: concreteIssuanceEntityParams,
    );

    print('Concrete Issuance created.');
  }

  Future<void> _handleIssuanceWithoutPR(
    TxSession ctx,
    String issuanceId,
    List<dynamic> issuanceItems,
  ) async {
    for (final issuance in issuanceItems) {
      final itemId =
          issuance['shareable_item_information']['base_item_id'] as String;
      final issuedQuantity = int.parse(issuance['issued_quantity'] as String);

      // Step 3: Insert into IssuanceItems table
      await _insertIssuanceItem(ctx, issuanceId, itemId, issuedQuantity);

      // Step 4: Update the Items table to reduce stock
      await _updateItemStock(ctx, itemId, issuedQuantity);
    }
  }

  Future<void> _insertIssuanceItem(
    TxSession ctx,
    String issuanceId,
    String itemId,
    int issuedQuantity,
  ) async {
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
  }

  Future<void> _updateItemStock(
    TxSession ctx,
    String itemId,
    int issuedQuantity,
  ) async {
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

  Future<void> _handleIssuanceWithPR(
    TxSession ctx,
    String issuanceId,
    PurchaseRequest purchaseRequest,
    List<dynamic> issuanceItems,
  ) async {
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
      final requestedProductDescriptionId = requestedItem.productDescription.id;
      final requestedUnit = requestedItem.unit.toString().split('.').last;

      // Construct a key for the requested item
      final key =
          '$requestedProductNameId-$requestedProductDescriptionId-$requestedUnit';

      // Check if the issuanceItems map contains the requested item
      if (issuanceItemsMap.containsKey(key)) {
        final issuanceItem = issuanceItemsMap[key];
        final issuanceBaseItemId = issuanceItem['shareable_item_information']
            ['base_item_id'] as String;
        final issuanceQuantity =
            int.parse(issuanceItem['issued_quantity'] as String);

        final remainingToFulfill =
            requestedItem.remainingQuantity ?? requestedItem.quantity;

        // Calculate the quantity to issue
        // Why do I feel like the problem is here
        final issuedQuantity = min(remainingToFulfill, issuanceQuantity);

        if (issuedQuantity > 0) {
          // Step 3: Insert into IssuanceItems table
          await _insertIssuanceItem(
            ctx,
            issuanceId,
            issuanceBaseItemId,
            issuedQuantity,
          );

          // Step 4: Update the RequestedItems table
          final remainingRequestedQuantity =
              requestedItem.quantity - issuedQuantity;
          totalRemainingQuantities += remainingRequestedQuantity;

          // Step: 5 Update RequestedItem remaining quantity and status
          await ctx.execute(
            Sql.named(
              '''
               UPDATE RequestedItems
               SET remaining_quantity = @remaining_quantity, status = @status
               WHERE id = @id;
               ''',
            ),
            parameters: {
              'id': requestedItem.id,
              'remaining_quantity': remainingRequestedQuantity,
              'status': remainingRequestedQuantity > 0
                  ? FulfillmentStatus.partiallyFulfilled
                      .toString()
                      .split('.')
                      .last
                  : FulfillmentStatus.fulfilled.toString().split('.').last,
            },
          );

          // Step 5: Update the Items table to reduce stock
          await _updateItemStock(ctx, issuanceBaseItemId, issuedQuantity);
        }
      }
    }

    // Step 7: Update the PurchaseRequest status
    await _updatePurchaseRequestStatus(
      ctx,
      purchaseRequest.id,
      totalRemainingQuantities,
    );
  }

  Future<void> _updatePurchaseRequestStatus(
    TxSession ctx,
    String prId,
    int totalRemainingQuantities,
  ) async {
    final allItemsFulfilled = await _areAllRequestedItemsFulfilled(ctx, prId);

    final status = allItemsFulfilled
        ? PurchaseRequestStatus.fulfilled
        : (totalRemainingQuantities > 0
            ? PurchaseRequestStatus.partiallyFulfilled
            : PurchaseRequestStatus.pending);

    await ctx.execute(
      Sql.named(
        '''
        UPDATE PurchaseRequests
        SET status = @status
        WHERE id = @id;
        ''',
      ),
      parameters: {
        'id': prId,
        'status': status.toString().split('.').last,
      },
    );
  }

  Future<bool> _areAllRequestedItemsFulfilled(
    TxSession ctx,
    String prId,
  ) async {
    final result = await ctx.execute(
      Sql.named(
        '''
        SELECT COUNT(*) as unfulfilled_count
        FROM RequestedItems
        WHERE pr_id = @pr_id
        AND status != @status;
        ''',
      ),
      parameters: {
        'pr_id': prId,
        'status': FulfillmentStatus.fulfilled.toString().split('.').last,
      },
    );

    return (result.first[0] as int) == 0;
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
    IcsType? type,
    required DateTime issuedDate,
    required List<dynamic> issuanceItems,
    PurchaseRequest? purchaseRequest,
    String? entityId,
    FundCluster? fundCluster,
    int? supplierId,
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderId,
    String? receivingOfficerId,
    String? issuingOfficerId,
  }) async {
    final icsId = await _generateUniqueIcsId(
      type: type,
      fundCluster: fundCluster,
      issuedDate: issuedDate,
    );

    print('Generated ICS ID: $icsId');

    final concreteIssuanceEntityQuery = '''
    INSERT INTO InventoryCustodianSlips (id, issuance_id, supplier_id, inspection_and_acceptance_report_id, contract_number, purchase_order_id)
    VALUES (@id, @issuance_id, @supplier_id, @inspection_and_acceptance_report_id, @contract_number, @purchase_order_id);
    ''';

    final concreteIssuanceEntityParams = {
      'id': icsId,
      'supplier_id': supplierId,
      'inspection_and_acceptance_report_id': inspectionAndAcceptanceReportId,
      'contract_number': contractNumber,
      'purchase_order_id': purchaseOrderId,
    };

    return await _createIssuance(
      issuedDate: issuedDate,
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
    required DateTime issuedDate,
    required List<dynamic> issuanceItems,
    PurchaseRequest? purchaseRequest,
    String? entityId,
    FundCluster? fundCluster,
    int? supplierId,
    String? inspectionAndAcceptanceReportId,
    String? contractNumber,
    String? purchaseOrderId,
    String? receivingOfficerId,
    String? issuingOfficerId,
  }) async {
    final parId = await _generateUniqueParId();

    final concreteIssuanceEntityQuery = '''
    INSERT INTO PropertyAcknowledgementReceipts (id, issuance_id, supplier_id, inspection_and_acceptance_report_id, contract_number, purchase_order_id)
    VALUES (@id, @issuance_id, @supplier_id, @inspection_and_acceptance_report_id, @contract_number, @purchase_order_id);
    ''';

    final concreteIssuanceEntityParams = {
      'id': parId,
      'supplier_id': supplierId,
      'inspection_and_acceptance_report_id': inspectionAndAcceptanceReportId,
      'contract_number': contractNumber,
      'purchase_order_id': purchaseOrderId,
    };

    return await _createIssuance(
      issuedDate: issuedDate,
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
    required DateTime issuedDate,
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
      issuedDate: issuedDate,
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

  Future<List<Map<String, dynamic>>> getInventorySupplyReport({
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final inventorySupply = <Map<String, dynamic>>[];

    final results = await _conn.execute(
      Sql.named(
        '''
      WITH IssuanceData AS (
          SELECT
              i.id AS item_id,
              i.product_name_id, -- Include product_name_id from Items
              i.product_description_id, -- Include product_description_id from Items
              i.unit, -- Include unit from Items
              i.unit_cost, -- Include unit_cost from Items
              pn.name AS product_name,
              pd.description AS product_description,
              s.id AS supply_id,
              i.quantity AS current_quantity_in_stock,
              issi.issued_quantity AS total_quantity_issued_for_a_particular_row,
              ent.id AS entity_id,
              ent.name AS entity_name,
              rec_off.name AS receiving_officer_name,
              ROW_NUMBER() OVER (PARTITION BY i.id ORDER BY iss.id) AS row_num -- To order issuances for each item
          FROM
              Items i
          JOIN
              Supplies s ON i.id = s.base_item_id
          LEFT JOIN
              ProductNames pn ON i.product_name_id = pn.id
          LEFT JOIN
              ProductDescriptions pd ON i.product_description_id = pd.id
          LEFT JOIN
              IssuanceItems issi ON i.id = issi.item_id
          LEFT JOIN
              Issuances iss ON issi.issuance_id = iss.id
          LEFT JOIN
              RequisitionAndIssueSlips ris ON iss.id = ris.issuance_id
          LEFT JOIN
              entities ent ON iss.entity_id = ent.id
          LEFT JOIN
              officers rec_off ON iss.receiving_officer_id = rec_off.id
          WHERE
              i.acquired_date BETWEEN @start_date AND @end_date -- Add date filter here
      ),
      CumulativeIssued AS (
          SELECT
              item_id,
              product_name_id, -- Include product_name_id
              product_description_id, -- Include product_description_id
              unit, -- Include unit
              unit_cost, -- Include unit_cost
              product_name,
              product_description,
              supply_id,
              current_quantity_in_stock,
              total_quantity_issued_for_a_particular_row,
              entity_id,
              entity_name,
              receiving_officer_name,
              row_num,
              SUM(total_quantity_issued_for_a_particular_row) OVER (PARTITION BY item_id) AS total_issued_quantity_all_entities,
              SUM(total_quantity_issued_for_a_particular_row) OVER (PARTITION BY item_id ORDER BY row_num) AS cumulative_issued_quantity
          FROM
              IssuanceData
      ),
      RunningBalance AS (
          SELECT
              item_id,
              product_name_id, -- Include product_name_id
              product_description_id, -- Include product_description_id
              unit, -- Include unit
              unit_cost, -- Include unit_cost
              product_name,
              product_description,
              supply_id,
              current_quantity_in_stock,
              total_quantity_issued_for_a_particular_row,
              entity_id,
              entity_name,
              receiving_officer_name,
              row_num,
              total_issued_quantity_all_entities,
              current_quantity_in_stock + total_issued_quantity_all_entities AS total_quantity_available_and_issued,
              COALESCE(
                  LAG(current_quantity_in_stock + total_issued_quantity_all_entities - cumulative_issued_quantity) 
                  OVER (PARTITION BY item_id ORDER BY row_num), 
                  0
              ) AS balance_from_previous_row_after_issuance,
              current_quantity_in_stock + total_issued_quantity_all_entities - cumulative_issued_quantity 
                  AS balance_per_row_after_issuance
          FROM
              CumulativeIssued
      )
      SELECT
          item_id,
          product_name_id, -- Include product_name_id
          product_description_id, -- Include product_description_id
          unit, -- Include unit
          unit_cost, -- Include unit_cost
          product_name,
          product_description,
          supply_id,
          current_quantity_in_stock,
          total_quantity_issued_for_a_particular_row,
          total_quantity_available_and_issued,
          balance_from_previous_row_after_issuance,
          balance_per_row_after_issuance,
          entity_id,
          entity_name,
          receiving_officer_name
      FROM
          RunningBalance
      ORDER BY
          item_id, row_num;
      ''',
      ),
      parameters: {
        'start_date': startDate.toIso8601String(),
        'end_date':
            endDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      },
    );

    print('results: $results');

    for (final row in results) {
      inventorySupply.add(
        {
          'article': row[5],
          'description': row[6],
          'stock_number': '${row[1]}${row[2]}',
          'unit': row[3],
          'unit_value': row[4],
          'current_quantity_in_stock': row[8],
          'total_quantity_issued_for_a_particular_row': row[9],
          'total_quantity_available_and_issued': row[10],
          'balance_from_previous_row_after_issuance': row[11],
          'balance_per_row_after_issuance': row[12],
          'entity_name': row[14],
          'receiving_officer_name': row[15],
        },
      );
    }

    return inventorySupply;
  }

  Future<List<Map<String, dynamic>>> getInventoryPropertyReport({
    required DateTime startDate,
    DateTime? endDate,
    double? unitCost, // Optional to support both cases
    AssetSubClass? assetSubClass,
  }) async {
    final inventoryProperty = <Map<String, dynamic>>[];

    try {
      final results = await _conn.execute(
        Sql.named(
          '''
        WITH IssuanceData AS (
            SELECT
                i.id AS item_id,
                i.product_name_id,
                i.product_description_id,
                i.unit,
                i.unit_cost, 
                pn.name AS product_name,
                pd.description AS product_description,
                e.id AS equipment_id,
                i.specification, 
                mnf.name AS manufacturer_name,
                b.name AS brand_name,
                m.model_name AS model_name,
                e.serial_no,
                e.estimated_useful_life,
                e.asset_classification,
                e.asset_sub_class,
                i.quantity AS current_quantity_in_stock,
                issi.issued_quantity AS total_quantity_issued_for_a_particular_row,
                ent.id AS entity_id,
                ent.name AS entity_name,
                rec_off.name AS receiving_officer_name,
                rec_ofc.name AS receiving_officer_office,
                rec_off_pos.position_name AS receiving_officer_position,
                ROW_NUMBER() OVER (PARTITION BY i.id ORDER BY iss.id) AS row_num 
            FROM
                Items i
            JOIN
                Equipment e ON i.id = e.base_item_id 
            LEFT JOIN
                ProductNames pn ON i.product_name_id = pn.id
            LEFT JOIN
                ProductDescriptions pd ON i.product_description_id = pd.id
            LEFT JOIN
                Manufacturers mnf ON e.manufacturer_id = mnf.id
            LEFT JOIN
                Brands b ON e.brand_id = b.id
            LEFT JOIN
                Models m ON e.model_id = m.id
            LEFT JOIN
                IssuanceItems issi ON i.id = issi.item_id
            LEFT JOIN
                Issuances iss ON issi.issuance_id = iss.id
            LEFT JOIN
                InventoryCustodianSlips ics ON iss.id = ics.issuance_id
            LEFT JOIN
                entities ent ON iss.entity_id = ent.id
            LEFT JOIN
                officers rec_off ON iss.receiving_officer_id = rec_off.id
            LEFT JOIN
                positions rec_off_pos ON rec_off.position_id = rec_off_pos.id
            LEFT JOIN
                offices rec_ofc ON rec_off_pos.office_id = rec_ofc.id
            WHERE
                i.acquired_date BETWEEN @start_date AND @end_date
                ${unitCost != null ? 'AND i.unit_cost ' + (unitCost <= 50000.0 ? '<= 50000' : '> 50000') : ''}
                ${assetSubClass != null ? 'AND e.asset_sub_class = @asset_sub_class' : ''}
        ),
        CumulativeIssued AS (
            SELECT
                item_id,
                product_name_id, 
                product_description_id, 
                unit,
                unit_cost, 
                product_name,
                product_description,
                equipment_id, 
                specification, 
                manufacturer_name,
                brand_name, 
                model_name, 
                serial_no,
                estimated_useful_life,
                asset_classification,
                asset_sub_class,
                current_quantity_in_stock,
                total_quantity_issued_for_a_particular_row,
                entity_id,
                entity_name,
                receiving_officer_name,
                receiving_officer_office,
                receiving_officer_position,
                row_num,
                SUM(total_quantity_issued_for_a_particular_row) OVER (PARTITION BY item_id) AS total_issued_quantity_all_entities,
                SUM(total_quantity_issued_for_a_particular_row) OVER (PARTITION BY item_id ORDER BY row_num) AS cumulative_issued_quantity
            FROM
                IssuanceData
        ),
        RunningBalance AS (
            SELECT
                item_id,
                product_name_id, 
                product_description_id,
                unit, 
                unit_cost, 
                product_name,
                product_description,
                equipment_id, 
                specification, 
                manufacturer_name,
                brand_name, 
                model_name, 
                serial_no,
                estimated_useful_life,
                asset_classification,
                asset_sub_class,
                current_quantity_in_stock,
                total_quantity_issued_for_a_particular_row,
                entity_name,
                receiving_officer_name,
                receiving_officer_office,
                receiving_officer_position,
                row_num,
                total_issued_quantity_all_entities,
                current_quantity_in_stock + total_issued_quantity_all_entities AS total_quantity_available_and_issued,
                COALESCE(
                    LAG(current_quantity_in_stock + total_issued_quantity_all_entities - cumulative_issued_quantity) 
                    OVER (PARTITION BY item_id ORDER BY row_num), 
                    0
                ) AS balance_from_previous_row_after_issuance,
                current_quantity_in_stock + total_issued_quantity_all_entities - cumulative_issued_quantity 
                    AS balance_per_row_after_issuance
            FROM
                CumulativeIssued
        )
        SELECT
            item_id,
            product_name_id,
            product_description_id, 
            unit,
            unit_cost,
            product_name,
            product_description,
            equipment_id,
            specification,
            manufacturer_name,
            brand_name,
            model_name, 
            serial_no,
            estimated_useful_life,
            asset_classification,
            asset_sub_class,
            current_quantity_in_stock,
            total_quantity_issued_for_a_particular_row,
            total_quantity_available_and_issued,
            balance_from_previous_row_after_issuance,
            balance_per_row_after_issuance,
            entity_name,
            receiving_officer_name,
            receiving_officer_office,
            receiving_officer_position
        FROM
            RunningBalance
        ORDER BY
            item_id, row_num;
        ''',
        ),
        parameters: {
          'start_date': startDate.toIso8601String(),
          'end_date':
              endDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
          if (assetSubClass != null)
            'asset_sub_class': assetSubClass.toString().split('.').last,
        },
      );

      print('results: $results');

      // Map results to a list of maps
      for (final row in results) {
        inventoryProperty.add(
          {
            'article': row[5], // product_name
            'description': row[6], // product_description
            'specification': row[8], // specification
            'manufacturer_name': row[9],
            'brand_name': row[10], // brand_name
            'model_name': row[11], // model_name
            'serial_no': row[12], // serial_no
            unitCost != null && unitCost <= 50000.0
                ? 'semi_expendable_property_no'
                : 'property_no': row[0], // item_id
            'estimated_useful_life': row[13],
            'asset_classification': row[14],
            'asset_sub_class': row[15],
            'unit': row[3], // unit
            'unit_value': row[4], // unit_cost
            'current_quantity_in_stock': row[16], // current_quantity_in_stock
            'total_quantity_issued_for_a_particular_row':
                row[17], // total_quantity_issued_for_a_particular_row
            'total_quantity_available_and_issued':
                row[18], // total_quantity_available_and_issued
            'balance_from_previous_row_after_issuance':
                row[19], // balance_from_previous_row_after_issuance
            'balance_per_row_after_issuance':
                row[20], // balance_per_row_after_issuance
            'entity_name': row[21], // entity_name
            'receiving_officer_name': row[22], // receiving_officer_name
            'receiving_officer_office': row[23], // receiving_officer_office
            'receiving_officer_position': row[24], // receiving_officer_position
          },
        );
      }
    } catch (e) {
      // Handle any errors that occur during execution
      print('Error fetching inventory property report: $e');
      rethrow; // Optionally rethrow the error if needed
    }

    return inventoryProperty;
  }

  Future<List<Map<String, dynamic>>> generateSemiExpendablePropertyCardData({
    required String icsId,
    required FundCluster fundCluster,
    DateTime? date, // if null, fallback to the date in the ICS
  }) async {
    final semiExpendablePropertyCardData = <Map<String, dynamic>>[];

    // Retrieve the issuance details by ICS ID
    final ics = await getIcsById(
      id: icsId,
    );

    // Check if this issuance has already been referenced in BatchItems
    final existingData = await _conn.execute(
      Sql.named('''
      SELECT base_pattern, generated_pattern_id, issuance_id, supplier_id 
      FROM BatchItems
      WHERE issuance_id = @issuance_id;
    '''),
      parameters: {'issuance_id': icsId},
    );

    if (existingData.isNotEmpty) {
      // If referenced, map and return the existing data
      for (final data in existingData) {
        semiExpendablePropertyCardData.add({
          'base_pattern_id': data[0],
          'generated_pattern_id': data[1],
          'issuance_id': data[2],
          'supplier_id': data[3],
        });
      }
      return semiExpendablePropertyCardData;
    }

    // Generate a base pattern from the supplier's name
    final supplierId = ics?.supplier?.supplierId.toString() ?? '';
    final supplierName = ics?.supplier?.supplierName ?? '';
    final issuedItems = ics?.items ?? [];
    final basePattern = supplierName.split(' ').map((e) => e[0]).join();

    // Increment base pattern if it already exists in BatchItems
    var uniquePattern = basePattern;
    int counter = 1;
    while (await checkPatternIfExistsInBatchItems(
        pattern: uniquePattern, supplierId: supplierId)) {
      uniquePattern = '$basePattern${counter++}';
    }

    // Generate IDs for each issued item based on the base pattern and quantity
    for (final issuedItem in issuedItems) {
      final quantity = issuedItem.quantity;
      final generatedIds = <String>[];

      // Generate semi-expendable IDs following the pattern: ABC-YYYY(FC)-MM-NNN(i)
      for (int i = 1; i <= quantity; i++) {
        final datePart = (date ?? ics?.issuedDate)
            ?.toIso8601String()
            .substring(0, 10); // YYYY-MM-DD
        final fundClusterPart =
            fundCluster.toString(); // Simplified fund cluster
        final generatedId =
            '$uniquePattern-$datePart($fundClusterPart)-NNN($i)';
        generatedIds.add(generatedId);

        await _conn.execute(
          Sql.named(
            '''
          INSERT INTO BatchItems (base_pattern, generated_pattern_id, issuance_id, supplier_id)
          VALUES (@base_pattern, @generated_pattern_id, @issuance_id, @supplier_id);
          ''',
          ),
          parameters: {
            'base_pattern': basePattern,
            'generated_pattern_id': generatedId,
            'issuance_id': ics?.id,
            'supplier_id': supplierId,
          },
        );

        semiExpendablePropertyCardData.add({
          'base_pattern_id': basePattern,
          'generated_pattern_id': generatedId,
          'issuance_id': ics?.id,
          'supplier_id': supplierId,
        });
      }
    }

    return semiExpendablePropertyCardData;
  }

  Future<bool> checkPatternIfExistsInBatchItems({
    required String pattern,
    required String supplierId,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
      SELECT 1 FROM BatchItems WHERE base_pattern = @base_pattern AND supplier_id = @supplier_id;
    ''',
      ),
      parameters: {
        'base_pattern': pattern,
        'supplier_id': supplierId,
      },
    );
    return result.affectedRows > 0;
  }
}
