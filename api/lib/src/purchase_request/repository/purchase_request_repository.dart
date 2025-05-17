import 'package:api/src/purchase_request/model/purchase_request.dart';
import 'package:postgres/postgres.dart';

import '../../issuance/models/issuance.dart';
import '../../item/models/item.dart';
import '../../organization_management/repositories/officer_repository.dart';

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

  Future<bool> registerRequestedItems({
    required String prId,
    required List<Map<String, dynamic>> requestedItems,
  }) async {
    if (requestedItems.isEmpty) return false;

    try {
      for (int i = 0; i < requestedItems.length; i++) {
        final requestedItem = requestedItems[i];
        final productNameId = requestedItem['product_name_id'] as int;
        final productDescriptionId =
            requestedItem['product_description_id'] as int;
        final productSpecification = requestedItem['specification'] as String?;
        final unit = requestedItem['unit'] as Unit;
        final quantity = requestedItem['quantity'] as int;
        final unitCost = requestedItem['unit_cost'] as double;
        final totalCost = unitCost * quantity;

        print('requested item: $requestedItem');

        await _conn.execute(
          Sql.named(
            '''
          INSERT INTO RequestedItems (
            pr_id, product_name_id, product_description_id, specification, unit, quantity, 
            unit_cost, total_cost
          ) VALUES (
            @pr_id, @product_name_id, @product_description_id, @specification, @unit, @quantity,
            @unit_cost, @total_cost
          );
          ''',
          ),
          parameters: {
            'pr_id': prId,
            'product_name_id': productNameId,
            'product_description_id': productDescriptionId,
            'specification': productSpecification,
            'unit': unit.toString().split('.').last,
            'quantity': quantity,
            'unit_cost': unitCost,
            'total_cost': totalCost,
          },
        );
      }

      return true;
    } catch (e) {
      print('Error inserting requested items: $e');
      return false;
    }
  }

  Future<String> registerPurchaseRequest({
    required String entityId,
    required FundCluster fundCluster,
    required String officeId,
    required DateTime date,
    //required String productNameId,
    //required String productDescriptionId,
    //required Unit unit,
    //required int quantity,
    //required double unitCost,
    required String purpose,
    required String requestingOfficerId,
    required String approvingOfficerId,
  }) async {
    try {
      print('triggered');
      final prId = await _generateUniquePurchaseRequestId();
      // final rcc = await _generateUniqueResponsibilityCenterCode();
      print('pr id: $prId');

      await _conn.execute(
        Sql.named(
          '''
        INSERT INTO PurchaseRequests (
          id, entity_id, fund_cluster, office_id, date, 
          purpose, requesting_officer_id, approving_officer_id
        ) VALUES (
          @id, @entity_id, @fund_cluster, @office_id, @date,
          @purpose, @requesting_officer_id, @approving_officer_id
        );
        ''',
        ),
        parameters: {
          'id': prId,
          'entity_id': entityId,
          'fund_cluster': fundCluster.toString().split('.').last,
          'office_id': officeId,
          'date': date,
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
          ofc.name AS office_name
    
        FROM
          PurchaseRequests pr
          
        LEFT JOIN
          Entities ent ON pr.entity_id = ent.id
    
        -- Join PurchaseRequest Office
        LEFT JOIN
          Offices ofc ON pr.office_id = ofc.id
    
        WHERE
          pr.id = @pr_id;
        ''',
      ),
      parameters: {
        'pr_id': id,
      },
    );

    if (result.isEmpty) return null;

    final row = result.first;

    final requestedItems = await _getRequestedItems(
      prId: id,
    );

    final officerRepository = OfficerRepository(_conn);

    final requestingOfficer = await officerRepository.getOfficerById(
      officerId: row[7] as String,
    );

    final approvingOfficer = await officerRepository.getOfficerById(
      officerId: row[8] as String,
    );

    final purchaseRequestMap = {
      'id': row[0],
      'entity_id': row[1],
      'fund_cluster': row[2],
      'office_id': row[3],
      'responsibility_center_code': row[4],
      'date': row[5],
      'requested_items': requestedItems.map((e) => e.toJson()).toList(),
      'purpose': row[6],
      'requesting_officer_id': row[7],
      'approving_officer_id': row[8],
      'status': row[9],
      'is_archived': row[10],
      'entity_name': row[11],
      'office_name': row[12],
      'requesting_officer': requestingOfficer?.toJson(),
      'approving_officer': approvingOfficer?.toJson(),
    };

    return PurchaseRequest.fromJson(purchaseRequestMap);
  }

  Future<List<RequestedItem>> _getRequestedItems({
    required String prId,
  }) async {
    try {
      final result = await _conn.execute(
        Sql.named(
          '''
          SELECT 
            ri.*,
            pn.name AS product_name,
            pd.description AS product_description
          FROM 
            RequestedItems ri
          LEFT JOIN
            ProductNames pn ON ri.product_name_id = pn.id
          LEFT JOIN
            ProductDescriptions pd ON ri.product_description_id = pd.id
          WHERE 
            pr_id = @pr_id
          ''',
        ),
        parameters: {
          'pr_id': prId,
        },
      );

      return result
          .map((row) => RequestedItem.fromJson({
                'id': row[0],
                'pr_id': row[1],
                'product_name_id': row[2],
                'product_description_id': row[3],
                'specification': row[4],
                'unit': row[5],
                'quantity': row[6],
                'remaining_quantity': row[7],
                'unit_cost': row[8],
                'total_cost': row[9],
                'status': row[10],
                'product_name': row[11],
                'product_description': row[12],
              }))
          .toList();
    } catch (e, stackTrace) {
      print('Error fetching requested items: $e\n$stackTrace');
      return [];
    }
  }

  Future<int> getPurchaseRequestsFilteredCount({
    String? prId,
    String? requestingOfficerId,
    String? search,
    String? requestingOfficerName,
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

      if (requestingOfficerName != null && requestingOfficerName.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('rofc.name ILIKE @requesting_officer_name');
        params['requesting_officer_name'] = '%$requestingOfficerName%';
      }

      if (search != null && search.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write(
            '(pr.id ILIKE @search_query OR rofc.name ILIKE @search_query)');
        params['search_query'] = '%$search%';
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
    String? searchQuery,
    String? requestingOfficerName,
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

      if (requestingOfficerName != null && requestingOfficerName.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('rofc.name ILIKE @requesting_officer_name');
        params['requesting_officer_name'] = '%$requestingOfficerName%';
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write(
            '(pr.id ILIKE @search_query OR rofc.name ILIKE @search_query)');
        params['search_query'] = '%$searchQuery%';
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
        final requestedItems = await _getRequestedItems(
          prId: row[0] as String,
        );

        final officerRepository = OfficerRepository(_conn);

        final requestingOfficer = await officerRepository.getOfficerById(
          officerId: row[7] as String,
        );

        final approvingOfficer = await officerRepository.getOfficerById(
          officerId: row[8] as String,
        );

        final purchaseRequestMap = {
          'id': row[0],
          'entity_id': row[1],
          'fund_cluster': row[2],
          'office_id': row[3],
          'responsibility_center_code': row[4],
          'date': row[5],
          'requested_items': requestedItems.map((e) => e.toJson()).toList(),
          'purpose': row[6],
          'requesting_officer_id': row[7],
          'approving_officer_id': row[8],
          'status': row[9],
          'is_archived': row[10],
          'entity_name': row[11],
          'office_name': row[12],
          'requesting_officer': requestingOfficer?.toJson(),
          'approving_officer': approvingOfficer?.toJson(),
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
    // bool isConsumable - prolly for ris
  }) async {
    try {
      final Map<String, dynamic> params = {};

      String baseQuery = '''
      SELECT COUNT(id) FROM PurchaseRequests
      ''';

      final whereClause = StringBuffer(
          'WHERE status != \'fulfilled\' AND status != \'cancelled\'');
      if (prId != null && prId.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('id LIKE @id');
        params['id'] = '%$prId%';
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
    // bool isConsumable - prolly for ris
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final prIdList = <String>[];
      final Map<String, dynamic> params = {};

      String baseQuery = '''
      SELECT id FROM PurchaseRequests
      ''';

      final whereClause = StringBuffer(
          'WHERE status != \'fulfilled\' AND status != \'cancelled\'');
      if (prId != null && prId.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('id LIKE @id');
        params['id'] = '%$prId%';
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

  Future<Map<String, dynamic>> getPurchaseRequestWeeklyTrends() async {
    final result = await _conn.execute(
      Sql.named(
        '''
      WITH weekly_purchase_trends AS (
          SELECT
              DATE_TRUNC('week', pr.date) AS week_start,
              CASE
                  WHEN pr.status IN ('pending', 'partiallyFulfilled') THEN 'Ongoing'
                  WHEN pr.status = 'fulfilled' THEN 'Fulfilled'
                  ELSE 'Other'
              END AS status,
              COUNT(pr.id) AS request_count
          FROM
              PurchaseRequests pr
          WHERE
              pr.date >= NOW() - INTERVAL '6 weeks'
              AND pr.status != 'cancelled'
          GROUP BY
              week_start, status
          ORDER BY
              week_start ASC
      )
      SELECT
          week_start,
          status,
          request_count
      FROM
          weekly_purchase_trends;
      ''',
      ),
    );

    if (result.isEmpty || result.length < 2) {
      return {
        'trends': [],
        'percentage_change': null,
      };
    }

    // Extract trends for Ongoing and Fulfilled requests
    var ongoingTrends = <Map<String, dynamic>>[];
    var fulfilledTrends = <Map<String, dynamic>>[];

    for (var row in result) {
      final trend = {
        'week_start': (row[0] as DateTime).toIso8601String(),
        'status': row[1],
        'request_count': row[2],
      };
      if (row[1] == 'Ongoing') {
        ongoingTrends.add(trend);
      } else if (row[1] == 'Fulfilled') {
        fulfilledTrends.add(trend);
      }
    }

    // Calculate percentage change for Ongoing and Fulfilled requests
    double ongoingPercentageChange = 0;
    double fulfilledPercentageChange = 0;

    if (ongoingTrends.length > 1) {
      final currentWeekOngoing =
          (ongoingTrends[0]['request_count'] as int?) ?? 0;
      final previousWeekOngoing =
          (ongoingTrends[1]['request_count'] as int?) ?? 0;
      ongoingPercentageChange = previousWeekOngoing == 0
          ? 0
          : ((currentWeekOngoing - previousWeekOngoing) / previousWeekOngoing) *
              100;
      ongoingPercentageChange =
          double.parse(ongoingPercentageChange.toStringAsFixed(2));
    }

    if (fulfilledTrends.length > 1) {
      final currentWeekFulfilled =
          (fulfilledTrends[0]['request_count'] as int?) ?? 0;
      final previousWeekFulfilled =
          (fulfilledTrends[1]['request_count'] as int?) ?? 0;
      fulfilledPercentageChange = previousWeekFulfilled == 0
          ? 0
          : ((currentWeekFulfilled - previousWeekFulfilled) /
                  previousWeekFulfilled) *
              100;
      fulfilledPercentageChange =
          double.parse(fulfilledPercentageChange.toStringAsFixed(2));
    }

    return {
      'ongoing_trends': ongoingTrends,
      'fulfilled_trends': fulfilledTrends,
      'ongoing_percentage_change': ongoingPercentageChange,
      'fulfilled_percentage_change': fulfilledPercentageChange,
    };
  }

  Future<List<Map<String, dynamic>>> getMostRequestedItems() async {
    final result = await _conn.execute(
      Sql.named(
        '''
      SELECT
          pn.name AS product_name,
          COUNT(ri.product_name_id) AS request_count
      FROM
          RequestedItems ri
      JOIN
          ProductNames pn ON ri.product_name_id = pn.id
      GROUP BY
          pn.name
      ORDER BY
          request_count DESC
      LIMIT 10;
      ''',
      ),
    );

    final List<Map<String, dynamic>> mostRequestedItems = [];
    for (var row in result) {
      mostRequestedItems.add(
        {
          'product_name': row[0] as String, // Product name
          'request_count': row[1] as int, // Request count
        },
      );
    }

    return mostRequestedItems;
  }

  Future<List<Map<String, dynamic>>> getFulfilledRequestsOverTime() async {
    // String timePeriod = 'daily';

    // String query;
    // switch (timePeriod) {
    //   case 'daily':
    //     query = '''
    //     SELECT DATE(date) as request_date, COUNT(*) as fulfilled_count
    //     FROM purchaserequests
    //     WHERE status = 'fulfilled'
    //     GROUP BY request_date
    //     ORDER BY request_date;
    //   ''';
    //     break;
    //   case 'weekly':
    //     query = '''
    //     SELECT DATE_TRUNC('week', date) as request_week, COUNT(*) as fulfilled_count
    //     FROM purchaserequests
    //     WHERE status = 'fulfilled'
    //     GROUP BY request_week
    //     ORDER BY request_week;
    //   ''';
    //     break;
    //   case 'monthly':
    //     query = '''
    //     SELECT DATE_TRUNC('month', date) as request_month, COUNT(*) as fulfilled_count
    //     FROM purchaserequests
    //     WHERE status = 'fulfilled'
    //     GROUP BY request_month
    //     ORDER BY request_month;
    //   ''';
    //     break;
    //   default:
    //     throw ArgumentError(
    //         'Invalid time period. Use "daily", "weekly", or "monthly".');
    // }

    // Execute the query
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT DATE(date) as request_date, COUNT(*) as fulfilled_count
        FROM PurchaseRequests
        WHERE status = 'fulfilled'
        GROUP BY request_date
        ORDER BY request_date;
        ''',
      ),
    );

    // Format the result as a list of maps
    final data = result.map((row) {
      return {
        'date': (row[0] as DateTime).toIso8601String(), // The date/week/month
        'count': row[1], // The count of fulfilled requests
      };
    }).toList();
    return data;
  }
}
