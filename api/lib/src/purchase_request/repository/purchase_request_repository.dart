import 'package:api/src/purchase_request/model/purchase_request.dart';
import 'package:postgres/postgres.dart';

import '../../issuance/models/issuance.dart';
import '../../item/models/item.dart';

class PurchaseRequestRepository {
  const PurchaseRequestRepository(this._conn);

  final Connection _conn;

  Future<String> _generateUniquePurchaseRequestId() async {
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    print('curr ym - $yearMonth');

    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT id FROM PurchaseRequests
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

  Future<String> registerPurchaseRequest({
    required String entityId,
    required FundCluster fundCluster,
    required String officeId,
    String? responsibilityCenterCode,
    required DateTime date,
    required String productNameId,
    required String productDescriptionId,
    required Unit unit,
    required int quantity,
    required double unitCost,
    required String purpose,
    required String requestingOfficerId,
    required String approvingOfficerId,
  }) async {
    try {
      print('triggered');
      final prId = await _generateUniquePurchaseRequestId();
      print('pr id: $prId');

      await _conn.execute(
        Sql.named(
          '''
        INSERT INTO PurchaseRequests (
          id, entity_id, fund_cluster, office_id, responsibility_center_code,
          date, product_name_id, product_description_id, unit, quantity, 
          unit_cost, total_cost, purpose, requesting_officer_id, 
          approving_officer_id
        ) VALUES (
          @id, @entity_id, @fund_cluster, @office_id, 
          @responsibility_center_code, @date, @product_name_id, 
          @product_description_id, @unit, @quantity, @unit_cost, @total_cost,
          @purpose, @requesting_officer_id, @approving_officer_id
        );
        ''',
        ),
        parameters: {
          'id': prId,
          'entity_id': entityId,
          'fund_cluster': fundCluster.toString().split('.').last,
          'office_id': officeId,
          'responsibility_center_code': responsibilityCenterCode,
          'date': date,
          'product_name_id': productNameId,
          'product_description_id': productDescriptionId,
          'unit': unit.toString().split('.').last,
          'quantity': quantity,
          'unit_cost': unitCost,
          'total_cost': unitCost * quantity,
          'purpose': purpose,
          'requesting_officer_id': requestingOfficerId,
          'approving_officer_id': approvingOfficerId,
        },
      );

      print('success');

      return prId;
    } catch (e) {
      throw Exception('Error registering pr: $e');
    }
  }

  Future<PurchaseRequest?> getPurchaseRequestById({
    required String id,
  }) async {
    // todo: I need to re-check this one because it doesn't return the officers' ids
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT
          pr.*,
          
          -- Entity
          ent.name as entity_name,
          
          -- Purchase Request Office
          ofc.name AS office_name,
      
          -- Product Details
          pn.name AS product_name,
          pd.description AS product_description,
      
          -- Requesting Officer Details
          rofc.user_id AS requesting_officer_user_id,
          rofc.name AS requesting_officer_name,
          req_pos.id AS requesting_officer_position_id,
          req_pos.position_name AS requesting_officer_position_name,
          req_ofc.name AS requesting_officer_office_name,  -- Requesting Officer's Office
          rofc.is_archived AS requesting_officer_is_archived,
      
          -- Approving Officer Details
          aofc.user_id AS approving_officer_user_id,
          aofc.name AS approving_officer_name,
          app_pos.id AS requesting_officer_position_id,
          app_pos.position_name AS approving_officer_position_name,
          app_ofc.name AS approving_officer_office_name,  -- Approving Officer's Office
          aofc.is_archived AS approving_officer_is_archived
    
        FROM
          PurchaseRequests pr
          
        LEFT JOIN
          Entities ent ON pr.entity_id = ent.id
    
        -- Join PurchaseRequest Office
        LEFT JOIN
          Offices ofc ON pr.office_id = ofc.id
    
        -- Join Product Names and Descriptions
        LEFT JOIN
          ProductNames pn ON pr.product_name_id = pn.id
        LEFT JOIN
          ProductDescriptions pd ON pr.product_description_id = pd.id
    
        -- Join Requesting Officer Details
        LEFT JOIN
          Officers rofc ON pr.requesting_officer_id = rofc.id
        -- Join the Position of the Requesting Officer
        LEFT JOIN
          Positions req_pos ON rofc.position_id = req_pos.id
        -- Join the Office of the Requesting Officer's Position
        LEFT JOIN
          Offices req_ofc ON req_pos.office_id = req_ofc.id
    
        -- Join Approving Officer Details
        LEFT JOIN
          Officers aofc ON pr.approving_officer_id = aofc.id
        -- Join the Position of the Approving Officer
        LEFT JOIN
          Positions app_pos ON aofc.position_id = app_pos.id
        -- Join the Office of the Approving Officer's Position
        LEFT JOIN
          Offices app_ofc ON app_pos.office_id = app_ofc.id
        WHERE
          pr.id = @pr_id;
        ''',
      ),
      parameters: {
        'pr_id': id,
      },
    );

    for (final row in result) {
      final purchaseRequestMap = {
        'id': row[0],
        'entity_id': row[1],
        'fund_cluster': row[2],
        'office_id': row[3],
        'responsibility_center_code': row[4],
        'date': row[5],
        'product_name_id': row[6],
        'product_description_id': row[7],
        'unit': row[8],
        'quantity': row[9],
        'remaining_quantity': row[10],
        'unit_cost': row[11],
        'total_cost': row[12],
        'purpose': row[13],
        'requesting_officer_id': row[14],
        'approving_officer_id': row[15],
        'status': row[16],
        'is_archived': row[17],
        'entity_name': row[18],
        'office_name': row[19],
        'product_name': row[20],
        'product_description': row[21],
        'requesting_officer_user_id': row[22],
        'requesting_officer_name': row[23],
        'requesting_officer_position_id': row[24],
        'requesting_officer_position_name': row[25],
        'requesting_officer_office_name': row[26],
        'requesting_officer_is_archived': row[27],
        'approving_officer_user_id': row[28],
        'approving_officer_name': row[29],
        'approving_officer_position_id': row[30],
        'approving_officer_position_name': row[31],
        'approving_officer_office_name': row[32],
        'approving_officer_is_archived': row[33],
      };
      return PurchaseRequest.fromJson(purchaseRequestMap);
    }
    return null;
  }

  Future<int> getPurchaseRequestsFilteredCount({
    String? prId,
    double? unitCost,
    DateTime? date,
    PurchaseRequestStatus? prStatus,
    bool isArchived = false,
  }) async {
    try {
      final params = <String, dynamic>{};
      final whereClause = StringBuffer();

      String baseQuery = '''
        SELECT
          COUNT(pr.id)
        FROM
          PurchaseRequests pr
          
        LEFT JOIN
          Entities ent ON pr.entity_id = ent.id
    
        -- Join PurchaseRequest Office
        LEFT JOIN
          Offices ofc ON pr.office_id = ofc.id
    
        -- Join Product Names and Descriptions
        LEFT JOIN
          ProductNames pn ON pr.product_name_id = pn.id
        LEFT JOIN
          ProductDescriptions pd ON pr.product_description_id = pd.id
    
        -- Join Requesting Officer Details
        LEFT JOIN
          Officers rofc ON pr.requesting_officer_id = rofc.id
        -- Join the Position of the Requesting Officer
        LEFT JOIN
          Positions req_pos ON rofc.position_id = req_pos.id
        -- Join the Office of the Requesting Officer's Position
        LEFT JOIN
          Offices req_ofc ON req_pos.office_id = req_ofc.id
    
        -- Join Approving Officer Details
        LEFT JOIN
          Officers aofc ON pr.approving_officer_id = aofc.id
        -- Join the Position of the Approving Officer
        LEFT JOIN
          Positions app_pos ON aofc.position_id = app_pos.id
        -- Join the Office of the Approving Officer's Position
        LEFT JOIN
          Offices app_ofc ON app_pos.office_id = app_ofc.id
        ''';

      whereClause.write('WHERE pr.is_archived = @is_archived');

      if (prId != null && prId.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('pr.id = @pr_id');
        params['pr_id'] = '%$prId%';
      }

      if (unitCost != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('pr.unit_cost = @unit_cost');
        params['unit_cost'] = unitCost;
      }

      if (date != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('pr.date = @date');
        params['date'] = date;
      }

      if (prStatus != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');

        if (prStatus == PurchaseRequestStatus.cancelled) {
          whereClause.write('pr.status = cancelled');
        }

        if (prStatus == PurchaseRequestStatus.pending) {
          whereClause.write('pr.status = pending');
        }

        if (prStatus == PurchaseRequestStatus.partiallyFulfilled) {
          whereClause.write('pr.status = partiallyFulfilled');
        }

        if (prStatus == PurchaseRequestStatus.fulfilled) {
          whereClause.write('pr.status = fulfilled');
        }
      }

      params['is_archived'] = isArchived;
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
      print('Error fetching prs: $e');
      throw Exception('Failed to fetch prs.');
    }
  }

  Future<List<PurchaseRequest>?> getPurchaseRequests({
    required int page,
    required int pageSize,
    String? prId,
    double? unitCost,
    DateTime? date,
    PurchaseRequestStatus? prStatus,
    bool isArchived = false,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final prList = <PurchaseRequest>[];
      final params = <String, dynamic>{};
      final whereClause = StringBuffer();

      String baseQuery = '''
        SELECT
          pr.*,
          -- Entity
          ent.name as entity_name,
          
          -- Purchase Request Office
          ofc.name AS office_name,
      
          -- Product Details
          pn.name AS product_name,
          pd.description AS product_description,
      
          -- Requesting Officer Details
          rofc.user_id AS requesting_officer_user_id,
          rofc.name AS requesting_officer_name,
          req_pos.id AS requesting_officer_position_id,
          req_pos.position_name AS requesting_officer_position_name,
          req_ofc.name AS requesting_officer_office_name,  -- Requesting Officer's Office
          rofc.is_archived AS requesting_officer_is_archived,
      
          -- Approving Officer Details
          aofc.user_id AS approving_officer_user_id,
          aofc.name AS approving_officer_name,
          app_pos.id AS requesting_officer_position_id,
          app_pos.position_name AS approving_officer_position_name,
          app_ofc.name AS approving_officer_office_name,  -- Approving Officer's Office
          aofc.is_archived AS approving_officer_is_archived
    
        FROM
          PurchaseRequests pr
          
        LEFT JOIN
          Entities ent ON pr.entity_id = ent.id
    
        -- Join PurchaseRequest Office
        LEFT JOIN
          Offices ofc ON pr.office_id = ofc.id
    
        -- Join Product Names and Descriptions
        LEFT JOIN
          ProductNames pn ON pr.product_name_id = pn.id
        LEFT JOIN
          ProductDescriptions pd ON pr.product_description_id = pd.id
    
        -- Join Requesting Officer Details
        LEFT JOIN
          Officers rofc ON pr.requesting_officer_id = rofc.id
        -- Join the Position of the Requesting Officer
        LEFT JOIN
          Positions req_pos ON rofc.position_id = req_pos.id
        -- Join the Office of the Requesting Officer's Position
        LEFT JOIN
          Offices req_ofc ON req_pos.office_id = req_ofc.id
    
        -- Join Approving Officer Details
        LEFT JOIN
          Officers aofc ON pr.approving_officer_id = aofc.id
        -- Join the Position of the Approving Officer
        LEFT JOIN
          Positions app_pos ON aofc.position_id = app_pos.id
        -- Join the Office of the Approving Officer's Position
        LEFT JOIN
          Offices app_ofc ON app_pos.office_id = app_ofc.id
        ''';

      whereClause.write('WHERE pr.is_archived = @is_archived');

      if (prId != null && prId.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('pr.id = @pr_id');
        params['pr_id'] = '%$prId%';
      }

      if (unitCost != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('pr.unit_cost = @unit_cost');
        params['unit_cost'] = unitCost;
      }

      if (date != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('pr.date = @date');
        params['date'] = date;
      }

      if (prStatus != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');

        if (prStatus == PurchaseRequestStatus.cancelled) {
          whereClause.write('pr.status = cancelled');
        }

        if (prStatus == PurchaseRequestStatus.pending) {
          whereClause.write('pr.status = pending');
        }

        if (prStatus == PurchaseRequestStatus.partiallyFulfilled) {
          whereClause.write('pr.status = partiallyFulfilled');
        }

        if (prStatus == PurchaseRequestStatus.fulfilled) {
          whereClause.write('pr.status = fulfilled');
        }
      }

      params['is_archived'] = isArchived;
      params['page_size'] = pageSize;
      params['offset'] = offset;

      final finalQuery = '''
      $baseQuery
      $whereClause
      ORDER BY
        pr.date DESC
      LIMIT @page_size OFFSET @offset
      ''';

      final results = await _conn.execute(
        Sql.named(
          finalQuery,
        ),
        parameters: params,
      );

      for (final row in results) {
        final purchaseRequestMap = {
          'id': row[0],
          'entity_id': row[1],
          'fund_cluster': row[2],
          'office_id': row[3],
          'responsibility_center_code': row[4],
          'date': row[5],
          'product_name_id': row[6],
          'product_description_id': row[7],
          'unit': row[8],
          'quantity': row[9],
          'remaining_quantity': row[10],
          'unit_cost': row[11],
          'total_cost': row[12],
          'purpose': row[13],
          'requesting_officer_id': row[14],
          'approving_officer_id': row[15],
          'status': row[16],
          'is_archived': row[17],
          'entity_name': row[18],
          'office_name': row[19],
          'product_name': row[20],
          'product_description': row[21],
          'requesting_officer_user_id': row[22],
          'requesting_officer_name': row[23],
          'requesting_officer_position_id': row[24],
          'requesting_officer_position_name': row[25],
          'requesting_officer_office_name': row[26],
          'requesting_officer_is_archived': row[27],
          'approving_officer_user_id': row[28],
          'approving_officer_name': row[29],
          'approving_officer_position_id': row[30],
          'approving_officer_position_name': row[31],
          'approving_officer_office_name': row[32],
          'approving_officer_is_archived': row[33],
        };
        print(purchaseRequestMap);
        prList.add(PurchaseRequest.fromJson(purchaseRequestMap));
      }
      return prList;
    } catch (e) {
      print('Error fetching prs: $e');
      throw Exception('Failed to fetch prs.');
    }
  }
}
