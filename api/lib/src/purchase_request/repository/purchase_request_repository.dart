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

    print('Current year-month: $yearMonth');

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

    // pad left adds leading zeros if n has fewer than 3 digits
    final uniqueId = '$yearMonth-${n.toString().padLeft(3, '0')}';

    print('Generated ID: $uniqueId');
    return uniqueId;
  }

  Future<String> _generateUniqueResponsibilityCenterCode() async {
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    print('Current year-month for RCC: $yearMonth');

    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT responsibility_center_code FROM PurchaseRequests
        WHERE responsibility_center_code LIKE 'RCC' || '-' || @year_month || '-%'
        ORDER BY responsibility_center_code DESC
        LIMIT 1
        ''',
      ),
      parameters: {
        'year_month': yearMonth,
      },
    );

    int? n; // represent the no. of record
    if (result.isNotEmpty) {
      //print(int.parse(result.first.toString())); // whole
      //print(int.parse(result.first.toString().split('-').last)); // 21]
      //print('resu: ${int.parse(result.first[0].toString().split(' - ').last)}');
      n = int.parse(result.first[0].toString().split('-').last) + 1;
    } else {
      n = 1;
    }

    final uniqueId = 'RCC-$yearMonth-${n.toString().padLeft(3, '0')}';
    print('Generated RCC: $uniqueId');
    return uniqueId;
  }

  Future<String> registerPurchaseRequest({
    required String entityId,
    required FundCluster fundCluster,
    required String officeId,
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
      final rcc = await _generateUniqueResponsibilityCenterCode();
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
          'responsibility_center_code': rcc,
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
      print('err reg pr: $e');
      throw Exception('Error registering pr: $e');
    }
  }

  Future<int> getPurchaseRequestsCountBasedOnStatus({
    required PurchaseRequestStatus status,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT COUNT(*) FROM PurchaseRequests 
        WHERE status = @status;
        ''',
      ),
      parameters: {
        'status': status.toString().split('.').last,
      },
    );

    return result.first[0] as int;
  }

  Future<int> getReceivingOfficerPurchaseRequestsCountBasedOnStatus({
    required String receivingOfficerId,
    required PurchaseRequestStatus status,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT COUNT(*) FROM PurchaseRequests 
        WHERE requesting_officer_id = @requesting_officer_id
        AND status = @status;
        ''',
      ),
      parameters: {
        'requesting_officer_id': receivingOfficerId,
        'status': status.toString().split('.').last,
      },
    );

    return result.first[0] as int;
  }

  Future<PurchaseRequest?> getPurchaseRequestById({
    required String id,
  }) async {
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
          pr.id LIKE @pr_id;
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
    String? requestingOfficerId,
    double? unitCost,
    DateTime? startDate,
    DateTime? endDate,
    PurchaseRequestStatus? prStatus,
    String? filter,
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
        whereClause.write('pr.id ILIKE @pr_id');
        params['pr_id'] = '%$prId%';
      }

      if (requestingOfficerId != null && requestingOfficerId.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause
            .write('pr.requesting_officer_id LIKE @requesting_officer_id');
        params['requesting_officer_id'] = '$requestingOfficerId';
      }

      if (unitCost != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('pr.unit_cost = @unit_cost');
        params['unit_cost'] = unitCost;
      }

      if (startDate != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('pr.date >= @start_date');
        params['start_date'] = startDate;
      }

      final effectiveEndDate = endDate ?? DateTime.now();
      whereClause.write(' AND pr.date <= @end_date');
      params['end_date'] = effectiveEndDate;

      if (prStatus != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');

        if (prStatus == PurchaseRequestStatus.cancelled) {
          whereClause.write('pr.status = \'cancelled\'');
        }

        if (prStatus == PurchaseRequestStatus.pending) {
          whereClause.write('pr.status = \'pending\'');
        }

        if (prStatus == PurchaseRequestStatus.partiallyFulfilled) {
          whereClause.write('pr.status = \'partiallyFulfilled\'');
        }

        if (prStatus == PurchaseRequestStatus.fulfilled) {
          whereClause.write('pr.status = \'fulfilled\'');
        }
      }

      if (filter != null && filter.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');

        if (filter == 'ongoing') {
          whereClause
              .write('pr.status IN (\'pending\', \'partiallyFulfilled\')');
        }

        if (filter == 'history') {
          whereClause.write('pr.status IN (\'fulfilled\', \'cancelled\')');
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
    String? receivingOfficerId,
    double? unitCost,
    DateTime? startDate,
    DateTime? endDate,
    PurchaseRequestStatus? prStatus,
    String? filter,
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
          app_pos.id AS approving_officer_position_id,
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
        whereClause.write('pr.id ILIKE @pr_id');
        params['pr_id'] = '%$prId%';
      }

      if (receivingOfficerId != null && receivingOfficerId.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause
            .write('pr.requesting_officer_id LIKE @requesting_officer_id');
        params['requesting_officer_id'] = '$receivingOfficerId';
      }

      if (unitCost != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('pr.unit_cost = @unit_cost');
        params['unit_cost'] = unitCost;
      }

      if (startDate != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('pr.date >= @start_date');
        params['start_date'] = startDate;
      }

      final effectiveEndDate = endDate ?? DateTime.now();
      whereClause.write(' AND pr.date <= @end_date');
      params['end_date'] = effectiveEndDate;


      if (prStatus != null) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');

        if (prStatus == PurchaseRequestStatus.cancelled) {
          whereClause.write('pr.status = \'cancelled\'');
        }

        if (prStatus == PurchaseRequestStatus.pending) {
          whereClause.write('pr.status = \'pending\'');
        }

        if (prStatus == PurchaseRequestStatus.partiallyFulfilled) {
          whereClause.write('pr.status = \'partiallyFulfilled\'');
        }

        if (prStatus == PurchaseRequestStatus.fulfilled) {
          whereClause.write('pr.status = \'fulfilled\'');
        }
      }

      if (filter != null && filter.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');

        if (filter == 'ongoing') {
          whereClause
              .write('pr.status IN (\'pending\', \'partiallyFulfilled\')');
        }

        if (filter == 'history') {
          whereClause.write('pr.status IN (\'fulfilled\', \'cancelled\')');
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

      print(finalQuery);

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

  Future<int> getPurchaseRequestIdsFilteredCount({
    String? prId,
    String? type,
    // bool isConsumable - prolly for ris
  }) async {
    try {
      final Map<String, dynamic> params = {};

      String baseQuery = '''
      SELECT COUNT(id) FROM PurchaseRequests
      ''';

      final whereClause = StringBuffer('WHERE status != \'fulfilled\' AND status != \'cancelled\'');
      if (prId != null && prId.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('id LIKE @id');
        params['id'] = '%$prId%';
      }

      if (type != null && type.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');

        if (type == 'ics') {
          whereClause.write('unit_cost <= 50000');
        }

        if (type == 'par') {
          whereClause.write('unit_cost > 50000');
        }
      }

      final finalQuery = '''
      $baseQuery
      $whereClause;
      ''';

      final result = await _conn.execute(
        Sql.named(
          finalQuery,
        ),
        parameters: params,
      );

      return result.first[0] as int;
    } catch (e) {
      print('Error fetching filtered pr ids count: $e');
      throw Exception('Failed to fetch pr id count');
    }
  }

  Future<List<String>> getPurchaseRequestIds({
    required int page,
    required int pageSize,
    String? prId,
    String? type,
    // bool isConsumable - prolly for ris
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final prIdList = <String>[];
      final Map<String, dynamic> params = {};

      String baseQuery = '''
      SELECT id FROM PurchaseRequests
      ''';

      final whereClause = StringBuffer('WHERE status != \'fulfilled\' AND status != \'cancelled\'');
      if (prId != null && prId.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('id LIKE @id');
        params['id'] = '%$prId%';
      }

      if (type != null && type.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');

        if (type == 'ics') {
          whereClause.write('unit_cost <= 50000');
        }

        if (type == 'par') {
          whereClause.write('unit_cost > 50000');
        }
      }

      final finalQuery = '''
      $baseQuery
      $whereClause
      ORDER BY date ASC
      LIMIT @page_size OFFSET @offset;
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

      for (final row in results) {
        prIdList.add(row[0] as String);
      }
      return prIdList;
    } catch (e) {
      print('Error fetching pr ids: $e');
      throw Exception('Failed to fetch pr id');
    }
  }

  Future<List<Map<String, dynamic>>> getTopRequestedItemsByPeriod(
    int limit,
    String period, // 'day', 'week', 'month', or 'year'
  ) async {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    // Calculate startDate based on the period
    switch (period) {
      case 'day':
        startDate = DateTime(now.year, now.month, now.day); // Start of the day
        break;
      case 'week':
        startDate = now.subtract(Duration(
            days: now.weekday - 1)); // Start of the current week (Monday)
        break;
      case 'month':
        startDate =
            DateTime(now.year, now.month, 1); // Start of the current month
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1); // Start of the current year
        break;
      default:
        throw ArgumentError(
            'Invalid period parameter. Use "week", "month", or "year".');
    }

    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT 
          pn.name AS product_name, 
          DATE_TRUNC(@period, pr.date) AS request_date,
          SUM(pr.quantity) AS total_requested_quantity
        FROM 
          PurchaseRequests pr
        JOIN 
          ProductNames pn ON pr.product_name_id = pn.id
        WHERE 
          pr.status IN ('pending', 'partiallyFulfilled', 'fulfilled') 
          AND pr.is_archived = FALSE
          AND pr.date >= @startDate AND pr.date <= @endDate
        GROUP BY 
          pn.name, DATE_TRUNC(@period, pr.date)
        ORDER BY 
          total_requested_quantity DESC
        LIMIT @limit;
      ''',
      ),
      parameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'limit': limit,
        'period': period,
      },
    );

    // Map the results into a format suitable for a line graph
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (final row in result) {
      final productName = row[0] as String;
      final requestDate = row[1] as DateTime;
      final totalRequestedQuantity = row[2] as int;

      groupedData.putIfAbsent(productName, () => []);

      groupedData[productName]!.add({
        'date': requestDate.toIso8601String(),
        'quantity': totalRequestedQuantity,
      });
    }

    return groupedData.entries.map((entry) {
      return {
        'product_name': entry.key,
        'data': entry.value,
      };
    }).toList();
  }

  Future<Map<String, int>> fetchPRCounts(
      DateTime startDate, DateTime endDate) async {
    final result = await _conn.execute(
      Sql.named(
        '''
      SELECT 
        status, 
        COUNT(*) AS count
      FROM 
        PurchaseRequests
      WHERE 
        date >= @startDate AND date < @endDate
        AND is_archived = FALSE
      GROUP BY 
        status;
      ''',
      ),
      parameters: {
        'startDate': startDate,
        'endDate': endDate,
      },
    );

    // Convert result to a Map<String, int> for easy processing
    final counts = <String, int>{};
    for (final row in result) {
      counts[row[0] as String] = row[1] as int;
    }
    return counts;
  }

  // Function to generate feedback based on counts
  Map<String, dynamic> generateFeedback(
      String prType, int currentCount, int previousCount) {
    if (previousCount == 0) {
      if (currentCount > 0) {
        return {
          'feedback':
              'There has been a significant rise in $prType purchase requests this month, up from none last month.',
          'is_increase': true,
          'percentage': 100.0,
        };
      } else {
        return {
          'feedback':
              'There were no $prType purchase requests this month or last month.',
          'is_increase': null, // No increase or decrease
          'percentage': 0.0,
        };
      }
    }

    final difference = currentCount - previousCount;
    final percentageChange = (difference / previousCount) * 100;

    if (difference > 0) {
      return {
        'feedback':
            'There has been a ${percentageChange.toStringAsFixed(1)}% increase in $prType purchase requests this month.',
        'is_increase': true,
        'percentage': percentageChange.abs(),
      };
    } else if (difference < 0) {
      return {
        'feedback':
            'There has been a ${percentageChange.abs().toStringAsFixed(1)}% decrease in $prType purchase requests this month.',
        'is_increase': false,
        'percentage': percentageChange.abs(),
      };
    } else {
      return {
        'feedback':
            'There has been no change in $prType purchase requests compared to last month.',
        'is_increase': null, // No increase or decrease
        'percentage': percentageChange,
      };
    }
  }

// Function to generate feedback for all statuses
  Future<Map<String, Map<String, dynamic>>>
      generateFeedbackForAllStatuses() async {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    final currentMonthEnd = DateTime(now.year, now.month + 1, 1);
    final previousMonthEnd = currentMonthStart;

    // Fetch counts for current and previous months
    final currentCounts =
        await fetchPRCounts(currentMonthStart, currentMonthEnd);
    final previousCounts =
        await fetchPRCounts(previousMonthStart, previousMonthEnd);

    // Generate feedback for each status
    final feedbacks = <String, Map<String, dynamic>>{};
    final statuses = {
      'pending',
      'partiallyFulfilled',
      'fulfilled',
      'cancelled'
    };

    for (final status in statuses) {
      final currentCount = currentCounts[status] ?? 0;
      final previousCount = previousCounts[status] ?? 0;
      feedbacks[status] = generateFeedback(status, currentCount, previousCount);
    }

    return feedbacks;
  }

  /// toggle between cancelled and pending status
  /// can only set pending status to cancelled and non others
  Future<bool> updatePurchaseRequestStatus({
    required String id,
    required PurchaseRequestStatus status,
  }) async {
    print(id);
    print(status);
    final result = await _conn.execute(
      Sql.named(
        '''
    UPDATE PurchaseRequests
    SET status = @status
    WHERE id = @id;
    ''',
      ),
      parameters: {
        'id': id,
        'status': status.toString().split('.').last,
      },
    );

    print(result);

    return result.affectedRows == 1;
  }
}
