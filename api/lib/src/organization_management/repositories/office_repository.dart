import 'package:postgres/postgres.dart';

import '../../utils/generate_id.dart';
import '../models/office.dart';

class OfficeRepository {
  const OfficeRepository(this._conn);

  final Connection _conn;

  Future<String> generateUniqueOfficeId() async {
    while (true) {
      final officeId = generatedId('OFF');

      final result = await _conn.execute(
        Sql.named(
          '''SELECT COUNT(id) FROM Offices WHERE id = @id;''',
        ),
        parameters: {
          'id': officeId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return officeId;
      }
    }
  }

  Future<String> registerOfficer({
    required String officeName,
  }) async {
    try {
      final officeId = await generateUniqueOfficeId();

      await _conn.execute(
        Sql.named(
          '''
        INSERT INTO Offices
        (id, name)
        VALUES
        (@id, @name)
        ''',
        ),
        parameters: {
          'id': officeId,
          'name': officeName,
        },
      );

      return officeId;
    } catch (e) {
      print('Error registering office: $e');
      throw Exception('Failed to register office');
    }
  }

  Future<String> checkOfficeIfExist({
    required String officeName,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''SELECT id FROM Offices WHERE name ILIKE @name''',
      ),
      parameters: {
        'name': officeName,
      },
    );

    if (result.isEmpty) {
      return await registerOfficer(officeName: officeName);
    } else {
      return result.first[0] as String;
    }
  }

  Future<Office?> getOfficeById({
    required String id,
  }) async {
    try {
      final result = await _conn.execute(
        Sql.named(
          '''SELECT * FROM Offices WHERE id = @id''',
        ),
        parameters: {
          'id': id,
        },
      );

      if (result.isNotEmpty) {
        for (final row in result) {
          final officeMap = {
            'id': row[0],
            'name': row[1],
          };
          return Office.fromJson(officeMap);
        }
      }

      return null;
    } catch (e) {
      print('Error fetching office by ID: $e');
      throw Exception('Failed to get office');
    }
  }

  Future<bool?> updateOfficeInformation({
    required String id,
    String? officeName,
  }) async {
    try {
      final List<String> setClauses = [];
      final Map<String, dynamic> parameters = {
        'id': id,
      };

      if (officeName != null && officeName.isNotEmpty) {
        setClauses.add('name = @name');
        parameters['name'] = officeName;
      }

      final setClause = setClauses.join(', ');
      final result = await _conn.execute(
        Sql.named(
          '''
          UPDATE Offices SET $setClause WHERE id = @id;
      ''',
        ),
        parameters: parameters,
      );

      return result.affectedRows == 1;
    } catch (e) {
      print('Error updating office: $e');
      throw Exception('Failed to update office information');
    }
  }

  Future<int> getOfficeFilteredCount({
    String? officeName,
  }) async {
    try {
      final Map<String, dynamic> params = {};

      String baseQuery = '''
      SELECT COUNT(*)
      FROM Offices
      ''';

      if (officeName != null && officeName.isNotEmpty) {
        baseQuery += 'WHERE name ILIKE @name';
        params['name'] = '%$officeName%';
      }

      final result = await _conn.execute(
        Sql.named(
          baseQuery,
        ),
        parameters: params,
      );

      return result.first[0] as int;
    } catch (e) {
      print('Error getting filtered count: $e');
      throw Exception('Failed to get filtered office count');
    }
  }

  Future<List<String>> getOffices({
    required int page,
    required int pageSize,
    String? officeName,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final officeList = <String>[];
      final Map<String, dynamic> params = {};

      String baseQuery = '''
      SELECT name FROM Offices
      ''';

      if (officeName != null && officeName.isNotEmpty) {
        baseQuery += 'WHERE name ILIKE @name';
        params['name'] = '%$officeName%';
      }

      final finalQuery = '''
      $baseQuery
      ORDER BY name ASC
      LIMIT @page_size OFFSET @offset;
      ''';

      params['page_size'] = pageSize;
      params['offset'] = offset;

      final results = await _conn.execute(
        Sql.named(
          finalQuery,
        ),
        parameters: params,
      );

      for (final row in results) {
        officeList.add(row[0] as String);
      }
      return officeList;
    } catch (e) {
      print('Error fetching offices: $e');
      throw Exception('Failed to fetch offices');
    }
  }
}
