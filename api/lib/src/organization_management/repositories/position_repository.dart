import 'package:postgres/postgres.dart';

import '../../utils/generate_id.dart';
import '../models/position.dart';

class PositionRepository {
  const PositionRepository(this._conn);

  final Connection _conn;

  Future<String> _generateUniquePositionId() async {
    while (true) {
      final positionId = generatedId('POS');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM Positions WHERE id = @id;
        '''),
        parameters: {
          'id': positionId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return positionId;
      }
    }
  }

  Future<String> registerPosition({
    required String officeId,
    required String positionName,
  }) async {
    try {
      final positionId = await _generateUniquePositionId();

      await _conn.execute(
        Sql.named(
          '''
        INSERT INTO Positions
        (id, office_id, position_name)
        VALUES
        (@id, @office_id, @position_name)
        ''',
        ),
        parameters: {
          'id': positionId,
          'office_id': officeId,
          'position_name': positionName,
        },
      );

      return positionId;
    } catch (e) {
      print('Error registering position: $e');
      throw Exception('Failed to register position');
    }
  }

  Future<String> checkIfPositionExist({
    required String officeId,
    required String positionName,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''SELECT id FROM Positions WHERE office_id = @office_id AND position_name ILIKE @position_name''',
      ),
      parameters: {
        'office_id': officeId,
        'position_name': positionName,
      },
    );

    if (result.isEmpty) {
      return await registerPosition(
        officeId: officeId,
        positionName: positionName,
      );
    } else {
      return result.first[0] as String;
    }
  }

  Future<Position?> getPositionById({
    required String id,
  }) async {
    try {
      final result = await _conn.execute(
        Sql.named(
          '''SELECT * FROM Positions WHERE id = @id''',
        ),
        parameters: {
          'id': id,
        },
      );

      if (result.isNotEmpty) {
        for (final row in result) {
          final positionMap = {
            'id': row[0],
            'office_id': row[1],
            'position_name': row[2],
          };
          return Position.fromJson(positionMap);
        }
      }

      return null;
    } catch (e) {
      print('Error fetching position by ID: $e');
      throw Exception('Failed to get position');
    }
  }

  Future<bool> updatePositionInformation({
    required String id,
    String? positionName,
  }) async {
    try {
      final List<String> setClauses = [];
      final Map<String, dynamic> parameters = {
        'id': id,
      };

      if (positionName != null && positionName.isNotEmpty) {
        setClauses.add('position_name = @position_name');
        parameters['position_name'] = positionName;
      }

      // To resolve this err:
      //Error updating positions: Severity.error 42601: syntax error at or near "["
      final setClause = setClauses.join(', ');
      final result = await _conn.execute(
        Sql.named(
          '''
      UPDATE Positions
      SET $setClause
      WHERE id = @id;
      ''',
        ),
        parameters: parameters,
      );

      return result.affectedRows == 1;
    } catch (e) {
      print('Error updating positions: $e');
      throw Exception('Failed to update positions information');
    }
  }

  Future<int> getPositionFilteredCount({
    required String officeId,
    String? positionName,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      String baseQuery = 'SELECT COUNT(*) FROM Positions';

      if (officeId.isNotEmpty) {
        baseQuery += ' WHERE office_id = @office_id';
        params['office_id'] = officeId;
      }

      if (positionName != null && positionName.isNotEmpty) {
        baseQuery += ' AND position_name ILIKE @position_name';
        params['position_name'] = '%$positionName%';
      }

      final result = await _conn.execute(
        Sql.named(
          baseQuery,
        ),
        parameters: params,
      );

      print(baseQuery);
      print(params);
      print(result);

      return result.first[0] as int;
    } catch (e) {
      print('Error getting filtered count: $e');
      throw Exception('Failed to get filtered position count');
    }
  }

  Future<List<String>> getPositions({
    required int page,
    required int pageSize,
    required String officeId,
    String? positionName,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final positionList = <String>[];
      final Map<String, dynamic> params = {};

      String baseQuery = '''
      SELECT position_name FROM Positions
      ''';

      if (officeId.isNotEmpty) {
        baseQuery += 'WHERE office_id = @office_id';
        params['office_id'] = officeId;
      }

      if (positionName != null && positionName.isNotEmpty) {
        baseQuery += ' AND position_name ILIKE @position_name';
        params['position_name'] = '%$positionName%';
      }

      final finalQuery = '''
      $baseQuery
      ORDER BY position_name ASC
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

      print(results);

      for (final row in results) {
        // this corresponds to the fromJson map keys
        // final positionMap = {
        //   'id': row[0],
        //   'office_id': row[1],
        //   'position_name': row[2],
        // };
        positionList.add(row[0] as String);
      }
      return positionList;
    } catch (e) {
      print('Error fetching positions: $e');
      throw Exception('Failed to fetch positions');
    }
  }
}
