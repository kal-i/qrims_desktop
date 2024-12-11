import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/purchase_order/model/purchase_order.dart';
import 'package:api/src/purchase_request/repository/purchase_request_repository.dart';
import 'package:postgres/postgres.dart';

import '../../utils/generate_id.dart';

class PurchaseOrderRepository {
  const PurchaseOrderRepository(this._conn);

  final Connection _conn;

  Future<String> _generateUniquePurchaseOrderId() async {
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    print('Current year-month: $yearMonth');

    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT id FROM PurchaseOrders
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

  Future<String> registerPurchaseOrder({
    required String supplierId,
    required DateTime date,
    required String procurementMode,
    required String gentleman,
    required String deliveryPlace,
    required DateTime deliveryDate,
    required int deliveryTerm,
    required int paymentTerm,
    required String description,
    required String prId,
    String? conformeOfficerId,
    DateTime? conformeDate,
    required String superintendentOfficerId,
    required String fundsHolderOfficerId,
    String? alobsNo,
  }) async {
    try {
      final poId = await _generateUniquePurchaseOrderId();

      await _conn.execute(
        Sql.named(
          '''
          INSERT INTO PurchaseOrders (
            id, supplier_id, date, procurement_mode, gentleman, delivery_place,
            delivery_date, delivery_term, payment_term, description,
            purchase_request_id, conforme_officer_id, conforme_date, 
            superintendent_officer_id,funds_holder_officer_id, alobs_no
          ) VALUES (
            @id, @supplier_id, @date, @procurement_mode, @gentleman, 
            @delivery_place, @delivery_date, @delivery_term, @payment_term,
            @description, @purchase_request_id, @conforme_officer_id,
            @conforme_date, @superintendent_officer_id, 
            @funds_holder_officer_id, @alobs_no
          );
          ''',
        ),
        parameters: {
          'id': poId,
          'supplier_id': supplierId,
          'date': date,
          'procurement_mode': procurementMode,
          'gentleman': gentleman,
          'delivery_place': deliveryPlace,
          'delivery_date': deliveryDate,
          'delivery_term': deliveryTerm,
          'payment_term': paymentTerm,
          'description': description,
          'purchase_request_id': prId,
          'conforme_officer_id': conformeOfficerId,
          'conforme_date': conformeDate,
          'superintendent_officer_id': superintendentOfficerId,
          'funds_holder_officer_id': fundsHolderOfficerId,
          'alobs_no': alobsNo,
        },
      );

      return poId;
    } catch (e) {
      print('err reg po: $e');
      throw Exception('Error registering po: $e');
    }
  }

  Future<String> _generateUniqueSupplierId() async {
    while (true) {
      final officerId = generatedId('SPPLR');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM Suppliers WHERE id = @id;
        '''),
        parameters: {
          'id': officerId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return officerId;
      }
    }
  }

  Future<String?> checkIfSupplierExist({
    required String name,
    required String address,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT id FROM Suppliers
        WHERE name ILIKE @name AND address ILIKE @address;
        ''',
      ),
      parameters: {
        'name': name,
        'address': address,
      },
    );

    if (result.isEmpty) {
      print('supplier does not exist.');
      return null;
    } else {
      return result.first[0] as String;
    }
  }

  Future<String> registerSupplier({
    required String name,
    required String address,
  }) async {
    try {
      final id = await _generateUniqueSupplierId();

      await _conn.execute(
        Sql.named(
          '''
          INSERT INTO Suppliers (id, name, address)
          VALUES (@id, @name, @address);
          ''',
        ),
        parameters: {
          'id': id,
          'name': name,
          'address': address,
        },
      );

      return id;
    } catch (e) {
      print('Error registering supplier: $e');
      throw Exception('Failed to register supplier.');
    }
  }

  Future<Supplier?> getSupplierById({
    required String id,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT * FROM Suppliers
        WHERE id LIKE @id;
        ''',
      ),
      parameters: {
        'id': id,
      },
    );

    if (result.isNotEmpty) {
      final row = result.first;

      return Supplier.fromJson({
        'id': row[0],
        'name': row[1],
        'address': row[2],
      });
    }

    return null;
  }

  Future<PurchaseOrder?> getPurchaseOrderById({
    required String id,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT * FROM PurchaseOrders;
        ''',
      ),
      parameters: {
        'id': id,
      },
    );

    if (result.isNotEmpty) {
      final row = result.first;
      final supplier = await getSupplierById(
        id: row[1] as String,
      );
      final purchaseRequest =
          await PurchaseRequestRepository(_conn).getPurchaseRequestById(
        id: row[10] as String,
      );
      final conformeOfficer = await OfficerRepository(_conn).getOfficerById(
        officerId: row[11] as String,
      );
      final superintendentOfficer =
          await OfficerRepository(_conn).getOfficerById(
        officerId: row[13] as String,
      );
      final fundsHolderOfficer = await OfficerRepository(_conn).getOfficerById(
        officerId: row[14] as String,
      );

      return PurchaseOrder.fromJson({
        'id': row[0],
        'supplier': supplier,
        'date': row[2],
        'procurement_mode': row[3],
        'gentleman': row[4],
        'delivery_place': row[5],
        'delivery_date': row[6],
        'delivery_term': row[7],
        'payment_term': row[8],
        'description': row[9],
        'purchase_request': purchaseRequest,
        'conforme_officer': conformeOfficer,
        'conforme_date': row[12],
        'superintendent_officer': superintendentOfficer,
        'funds_holder_officer': fundsHolderOfficer,
        'alobs_no': row[15],
      });
    }

    return null;
  }

  Future<List<PurchaseOrder>?> getPurchaseOrders({
    required int page,
    required int pageSize,
    String? poId,
    bool isArchived = false,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final poList = <PurchaseOrder>[];
      final params = <String, dynamic>{};

      final baseQuery = '''
      SELECT * FROM PurchaseOrders
      ''';

      final whereClause = StringBuffer('WHERE is_archived = @is_archived');
      params['is_archived'] = isArchived;

      if (poId != null && poId.isNotEmpty) {
        whereClause.write(' AND id ILIKE @id');
        params['id'] = '%$poId%';
      }

      final finalQuery = '''
      $baseQuery
      ${whereClause.toString()}
      ORDER BY date DESC
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

      for (final row in results) {
        final po = await getPurchaseOrderById(
          id: row[0] as String,
        );
        poList.add(po!);
      }

      return poList;
    } catch (e) {
      print('Error fetching pos: $e');
      throw Exception('Failed to fetch Purchase Orders.');
    }
  }

  Future<int> getPurchaseOrdersCount({
    String? poId,
    bool isArchived = false,
  }) async {
    try {
      final params = <String, dynamic>{};

      final baseQuery = '''
      SELECT COUNT(*) FROM PurchaseOrders
      ''';

      final whereClause = StringBuffer('WHERE is_archived = @is_archived');
      params['is_archived'] = isArchived;

      if (poId != null && poId.isNotEmpty) {
        whereClause.write(' AND id ILIKE @id');
        params['id'] = '%$poId%';
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
        print('Total no. of filtered issuances: $count');
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error counting filtered purchase order: $e');
      throw Exception('Failed to count filtered po.');
    }
  }
}
