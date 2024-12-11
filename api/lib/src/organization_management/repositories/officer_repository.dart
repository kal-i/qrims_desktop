import 'package:api/src/utils/generate_id.dart';
import 'package:postgres/postgres.dart';

import '../models/officer.dart';

class OfficerRepository {
  const OfficerRepository(this._conn);

  final Connection _conn;

  Future<String> _generateUniqueOfficerId() async {
    while (true) {
      final officerId = generatedId('OFFCR');

      final result = await _conn.execute(
        Sql.named('''
        SELECT COUNT(id) FROM Officers WHERE id = @id;
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

  Future<String> registerOfficer({
    String? userId,
    required String name,
    required String positionId,
  }) async {
    try {
      final officerId = await _generateUniqueOfficerId();

      await _conn.execute(
        Sql.named('''
        INSERT INTO Officers (id, user_id, name, position_id)
        VALUES (@id, @user_id, @name, @position_id)
        '''),
        parameters: {
          'id': officerId,
          'user_id': userId,
          'name': name,
          'position_id': positionId,
        },
      );

      return officerId;
    } catch (e) {
      print('Error registering officer: $e');
      throw Exception('Failed to register officer');
    }
  }

  Future<String?> checkOfficerIfExist({
    required String name,
    required String positionId,
  }) async {
    final checkIfExists = await _conn.execute(
      Sql.named('''
      SELECT id FROM Officers WHERE name ILIKE @name AND position_id = @position_id;
    '''),
      parameters: {
        'name': name,
        'position_id': positionId,
      },
    );

    if (checkIfExists.isEmpty) {
      print('officer result is empty');
      return null;
      //return await registerBrand(brandName: brandName);
    } else {
      print('officer result is not empty: $checkIfExists');
      return checkIfExists.first[0] as String;
    }
  }

  Future<Officer?> getOfficerById({
    String? officerId,
    String? userId,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      final whereClause = StringBuffer();

      final baseQuery = '''
      SELECT 
        Officers.id AS officer_id,
        Officers.user_id AS user_id,
        Officers.name AS officer_name,
        Positions.id AS position_id,
        -- Positions.office_id AS office_id,
        Offices.name AS office_name,
        Positions.position_name AS position_name,
        Officers.is_archived AS is_archived
      FROM 
        Officers
      JOIN 
        Positions ON Officers.position_id = Positions.id
      JOIN 
        Offices ON Positions.office_id = Offices.id
      ''';

      if (officerId != null && officerId.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('Officers.id = @officer_id');
        params['officer_id'] = officerId;
      }

      if (userId != null && userId.isNotEmpty) {
        whereClause.write(whereClause.isNotEmpty ? ' AND ' : ' WHERE ');
        whereClause.write('Officers.user_id = @user_id');
        params['user_id'] = userId;
      }

      final finalQuery = '''
      $baseQuery
      $whereClause
      ''';

      final result = await _conn.execute(
        Sql.named(
          finalQuery,
        ),
        parameters: params,
      );

      if (result.isNotEmpty) {
        final row = result.first;
        return Officer.fromJson({
          'id': row[0],
          'user_id': row[1],
          'name': row[2],
          'position_id': row[3],
          'office_name': row[4],
          'position_name': row[5],
          'is_archived': row[6],
        });
      }

      return null;
    } catch (e) {
      print('Error fetching officer by ID: $e');
      throw Exception('Failed to get officer');
    }
  }

  Future<bool?> updateOfficerInformation({
    required String id,
    String? name,
    String? positionId,
  }) async {
    try {
      // Start a transaction
      await _conn.runTx((ctx) async {
        final List<String> setClauses = [];
        final Map<String, dynamic> parameters = {
          'id': id,
        };

        if (name != null && name.isNotEmpty) {
          setClauses.add('name = @name');
          parameters['name'] = name;
        }

        if (positionId != null) {
          setClauses.add('position_id = @position_id');
          parameters['position_id'] = positionId;
        }

        // Update the Officers table
        await ctx.execute(
          Sql.named('''
        UPDATE Officers
        SET ${setClauses.join(', ')}
        WHERE id = @id;
        '''),
          parameters: parameters,
        );

        // If the officer is associated with a user, update the Users table
        if (parameters.containsKey('user_id')) {
          final userId = parameters['user_id'] as int;
          if (name != null && name.isNotEmpty) {
            await ctx.execute(
              Sql.named('''
            UPDATE Users
            SET name = @name
            WHERE id = @user_id;
            '''),
              parameters: {
                'name': name,
                'user_id': userId,
              },
            );
          }
        }
      });

      return true;
    } catch (e) {
      print('Error updating officer: $e');
      throw Exception('Failed to update officer information');
    }
  }

  Future<int> getOfficersFilteredCount({
    String? searchQuery,
    bool isArchived = false,
  }) async {
    try {
      final baseQuery = '''
      SELECT COUNT(*) FROM Officers
      ''';

      final whereClause = StringBuffer();
      whereClause.write('WHERE is_archived = @is_archived');
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
          '''
        AND
         Officers.name ILIKE @search_query
        ''',
        );
      }

      final finalQuery = '''
      $baseQuery
      $whereClause
      ''';

      final params = <String, dynamic>{
        'is_archived': isArchived,
      };
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['search_query'] = '%$searchQuery%';
      }

      final result = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      return result.first[0] as int;
    } catch (e) {
      print('Error getting filtered count: $e');
      throw Exception('Failed to get filtered officer count');
    }
  }

  Future<List<Officer>> getOfficers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String sortBy = 'Officers.name',
    bool sortAscending = false,
    bool isArchived = false,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final officerList = <Officer>[];

      final baseQuery = '''
      SELECT 
        Officers.id AS officer_id,
        Officers.user_id AS user_id,
        Officers.name AS officer_name,
        Positions.id AS position_id,
        --Positions.office_id AS office_id,
        Offices.name AS office_name,
        Positions.position_name AS position_name,
        Officers.is_archived AS is_archived
      FROM 
        Officers
      JOIN 
        Positions ON Officers.position_id = Positions.id
      JOIN 
        Offices ON Positions.office_id = Offices.id
      ''';

      final whereClause = StringBuffer();
      whereClause.write('WHERE Officers.is_archived = @is_archived');
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
          '''
        AND
         Officers.name ILIKE @search_query
        ''',
        );
      }

      final sortDirection = sortAscending ? 'ASC' : 'DESC';

      final finalQuery = '''
      $baseQuery
      $whereClause
      ORDER BY
        $sortBy $sortDirection
      LIMIT
        @page_size OFFSET @offset;
      ''';

      final params = <String, dynamic>{
        'is_archived': isArchived,
      };
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['search_query'] = '%$searchQuery%';
      }

      params['page_size'] = pageSize;
      params['offset'] = offset;

      final results = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      for (final row in results) {
        final officerMap = {
          'id': row[0],
          'user_id': row[1],
          'name': row[2],
          'position_id': row[3],
          'office_name': row[4],
          'position_name': row[5],
          'is_archived': row[6],
        };
        officerList.add(Officer.fromJson(officerMap));
      }
      return officerList;
    } catch (e) {
      print('Error fetching officers: $e');
      throw Exception('Failed to fetch officers');
    }
  }

  Future<bool?> updateOfficerArchiveStatus({
    required String id,
    required bool isArchived,
  }) async {
    try {
      // Check if officer is associated with a user
      final checkIfUserExist = await _conn.execute(
        Sql.named('''
        SELECT user_id FROM Officers
        WHERE id LIKE @id;
        '''),
        parameters: {
          'id': id,
        },
      );

      await _conn.execute(
        Sql.named('''
        UPDATE Officers
        SET is_archived = @is_archived
        WHERE id LIKE @id;
       '''),
        parameters: {
          'id': id,
          'is_archived': isArchived,
        },
      );

      if (checkIfUserExist.isNotEmpty) {
        final userId = checkIfUserExist.first[0] as String?;
        if (userId != null) {
          await _conn.execute(
            Sql.named('''
          UPDATE Users
          SET is_archived = @is_archived
          WHERE id LIKE @user_id;
          '''),
            parameters: {
              'user_id': userId,
              'is_archived': isArchived,
            },
          );
        } else {
          print('No associated user_id found for officer id: $id');
        }
      }

      return true;
    } catch (e) {
      print('Error updating officer archive status: $e');
      return false;
    }
  }

  Future<int> getOfficerNamesFilteredCount({
    required String positionId,
    String? officerName,
  }) async {
    try {
      final Map<String, dynamic> params = {};

      String baseQuery = '''
      SELECT COUNT(*)
      FROM Officers
      ''';

      if (positionId.isNotEmpty) {
        baseQuery += 'WHERE position_id = @position_id';
        params['position_id'] = positionId;
      }

      if (officerName != null && officerName.isNotEmpty) {
        baseQuery += ' AND name ILIKE @name';
        params['name'] = '%$officerName%';
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
      throw Exception('Failed to get filtered officer name count');
    }
  }

  Future<List<String>> getOfficerNames({
    required int page,
    required int pageSize,
    required String positionId,
    String? officerName,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final officeList = <String>[];
      final Map<String, dynamic> params = {};

      String baseQuery = '''
      SELECT name FROM Officers
      ''';

      if (positionId.isNotEmpty) {
        baseQuery += 'WHERE position_id = @position_id';
        params['position_id'] = positionId;
      }

      if (officerName != null && officerName.isNotEmpty) {
        baseQuery += ' AND name ILIKE @name';
        params['name'] = '%$officerName%';
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
      print('Error fetching officer names: $e');
      throw Exception('Failed to fetch officer names');
    }
  }

  Future<String?> getCurrentSchoolDivisionSuperintendent() async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT 
          off.id 
        FROM 
          Officers off
        JOIN
          Positions pos ON off.position_id = pos.id
        WHERE 
          pos.position_name ILIKE @name AND is_archived = @is_archived
        LIMIT 1;
        ''',
      ),
      parameters: {
        'name': 'superintendent',
        'is_archived': false,
      },
    );

    if (result.isNotEmpty) {
      return result.first[0] as String;
    }
    return null;
  }
}
