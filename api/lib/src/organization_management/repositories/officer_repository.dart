import 'package:api/src/utils/generate_id.dart';
import 'package:postgres/postgres.dart';

import '../models/officer.dart';
import '../models/position_history.dart';

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

      await _conn.runTx((ctx) async {
        await ctx.execute(
          Sql.named(
            '''
              INSERT INTO Officers (id, user_id, name, position_id)
              VALUES (@id, @user_id, @name, @position_id)
              ''',
          ),
          parameters: {
            'id': officerId,
            'user_id': userId,
            'name': name,
            'position_id': positionId,
          },
        );

        await ctx.execute(
          Sql.named(
            '''
              INSERT INTO PositionHistory (officer_id, position_id, created_at)
              VALUES (@officer_id, @position_id, @created_at);
              ''',
          ),
          parameters: {
            'officer_id': officerId,
            'position_id': positionId,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
      });

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
      Offices.name AS office_name,
      Positions.position_name AS position_name,
      Officers.officer_status AS officer_status,
      Officers.is_archived AS is_archived,
      PositionHistory.id AS history_id,
      PositionHistory.position_id AS history_position_id,
      PositionHistory.created_at AS history_created_at,
      HistoricalPositions.position_name AS history_position_name,
      HistoricalOffices.name AS history_office_name
    FROM 
      Officers
    JOIN 
      Positions ON Officers.position_id = Positions.id
    JOIN 
      Offices ON Positions.office_id = Offices.id
    LEFT JOIN
      PositionHistory AS PositionHistory ON Officers.id = PositionHistory.officer_id
    LEFT JOIN
      Positions AS HistoricalPositions ON PositionHistory.position_id = HistoricalPositions.id
    LEFT JOIN
      Offices AS HistoricalOffices ON HistoricalPositions.office_id = HistoricalOffices.id
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

        print(row);

        final positionHistoryList = result.map((row) {
          return PositionHistory.fromJson({
            'id': row[8],
            'officer_id': row[0],
            'position_id': row[9],
            'created_at': row[10],
            'position_name': row[11],
            'office_name': row[12],
          }).toJson();
        }).toList();

        return Officer.fromJson({
          'id': row[0],
          'user_id': row[1],
          'name': row[2],
          'position_id': row[3],
          'office_name': row[4],
          'position_name': row[5],
          'status': row[6],
          'is_archived': row[7],
          'position_history': positionHistoryList,
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
    String? newPositionId,
    OfficerStatus? status,
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

        if (newPositionId != null) {
          final latestPositionResult = await ctx.execute(
            Sql.named(
              '''
              SELECT
                position_id
              FROM
                Officers
              WHERE
                id = @id;
              ''',
            ),
            parameters: {
              'id': id,
            },
          );

          String? latestPositionId;
          if (latestPositionResult.isNotEmpty) {
            latestPositionId = latestPositionResult.first[0] as String?;
          }

          if (latestPositionId != newPositionId) {
            setClauses.add('position_id = @position_id');
            parameters['position_id'] = newPositionId;

            await ctx.execute(
              Sql.named(
                '''
              INSERT INTO PositionHistory (officer_id, position_id, created_at)
              VALUES (@officer_id, @position_id, @created_at);
              ''',
              ),
              parameters: {
                'officer_id': id,
                'position_id': newPositionId,
                'created_at': DateTime.now().toIso8601String(),
              },
            );
          }
        }

        if (status != null) {
          setClauses.add('officer_status = @status');
          parameters['status'] = status.toString().split('.').last;
        }

        // Update the Officers table
        if (setClauses.isNotEmpty) {
          await ctx.execute(
            Sql.named(
              '''
              UPDATE Officers
              SET ${setClauses.join(', ')}
              WHERE id = @id;
              ''',
            ),
            parameters: parameters,
          );
        }

        // If the officer is associated with a user, update the Users table
        if (parameters.containsKey('user_id')) {
          final userId = parameters['user_id'] as int;
          if (name != null && name.isNotEmpty) {
            await ctx.execute(
              Sql.named(
                '''
            UPDATE Users
            SET name = @name
            WHERE id = @user_id;
            ''',
              ),
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
    String? office,
    OfficerStatus status = OfficerStatus.active,
    bool isArchived = false,
  }) async {
    try {
      final params = <String, dynamic>{};

      final baseQuery = '''
    SELECT COUNT(*) 
    FROM Officers
    JOIN Positions ON Officers.position_id = Positions.id
    JOIN Offices ON Positions.office_id = Offices.id
    ''';

      final whereClause = StringBuffer();
      whereClause.write('WHERE Officers.is_archived = @is_archived');
      params['is_archived'] = isArchived;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(' AND Officers.name ILIKE @search_query');
        params['search_query'] = '%$searchQuery%';
      }

      if (office != null && office.isNotEmpty) {
        whereClause.write(' AND Offices.name ILIKE @office');
        params['office'] = '%$office%';
      }

      // Add status filter if needed
      whereClause.write(' AND Officers.officer_status = @status');
      params['status'] = status.toString().split('.').last;

      final finalQuery = '''
    $baseQuery
    $whereClause
    ''';

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
    String? office,
    String sortBy = 'Officers.name',
    OfficerStatus status = OfficerStatus.active,
    bool sortAscending = false,
    bool isArchived = false,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final officerList = <Officer>[];
      final params = <String, dynamic>{};

      /// Used JSON_AGG function wich collects a list of row to convert into an a JSON array
      final baseQuery = '''
      SELECT 
        Officers.id AS officer_id,
        Officers.user_id AS user_id,
        Officers.name AS officer_name,
        Positions.id AS position_id,
        Offices.name AS office_name,
        Positions.position_name AS position_name,
        Officers.officer_status AS officer_status,
        Officers.is_archived AS is_archived,
        JSON_AGG(
          JSON_BUILD_OBJECT(
            'id', PositionHistory.id,
            'officer_id', PositionHistory.officer_id,
            'position_id', PositionHistory.position_id,
            'created_at', PositionHistory.created_at,
            'position_name', HistoricalPositions.position_name,
            'office_name', HistoricalOffices.name
          )
        ) AS position_history
      FROM 
        Officers
      JOIN 
        Positions ON Officers.position_id = Positions.id
      JOIN 
        Offices ON Positions.office_id = Offices.id
      LEFT JOIN
        PositionHistory ON Officers.id = PositionHistory.officer_id
      LEFT JOIN
        Positions AS HistoricalPositions ON PositionHistory.position_id = HistoricalPositions.id
      LEFT JOIN
        Offices AS HistoricalOffices ON HistoricalPositions.office_id = HistoricalOffices.id
    ''';

      final whereClause = StringBuffer();
      whereClause.write('WHERE Officers.is_archived = @is_archived');
      params['is_archived'] = isArchived;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(' AND Officers.name ILIKE @search_query');
        params['search_query'] = '%$searchQuery%';
      }

      if (office != null && office.isNotEmpty) {
        whereClause.write(' AND Offices.name ILIKE @office');
        params['office'] = '%$office%';
      }

      // Add status filter if needed
      whereClause.write(' AND Officers.officer_status = @status');
      params['status'] = status.toString().split('.').last;

      final sortDirection = sortAscending ? 'ASC' : 'DESC';

      final finalQuery = '''
    $baseQuery
    $whereClause
    GROUP BY 
      Officers.id, Officers.user_id, Officers.name, Positions.id, Offices.name, Positions.position_name, Officers.officer_status, Officers.is_archived
    ORDER BY
      $sortBy $sortDirection
    LIMIT
      @page_size OFFSET @offset;
    ''';

      params['page_size'] = pageSize;
      params['offset'] = offset;

      final results = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      for (final row in results) {
        final positionHistory = row[8] != null
            ? List<Map<String, dynamic>>.from((row[8] as List<dynamic>)
                .map((e) => Map<String, dynamic>.from(e as Map)))
            : [];

        print('pos his res from repo: $positionHistory');

        final officerMap = {
          'id': row[0],
          'user_id': row[1],
          'name': row[2],
          'position_id': row[3],
          'office_name': row[4],
          'position_name': row[5],
          'status': row[6],
          'is_archived': row[7],
          'position_history': positionHistory,
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
    String? positionId,
    String? officerName,
  }) async {
    try {
      final Map<String, dynamic> params = {};
      final whereConditions = <String>[];

      String baseQuery = '''
      SELECT COUNT(*)
      FROM Officers
      ''';

      whereConditions.add('officer_status = @status');
      params['status'] = OfficerStatus.active.toString().split('.').last;

      if (positionId != null && positionId.isNotEmpty) {
        whereConditions.add('position_id = @position_id');
        params['position_id'] = positionId;
      }

      if (officerName != null && officerName.isNotEmpty) {
        whereConditions.add('name ILIKE @name');
        params['name'] = '%$officerName%';
      }

      if (whereConditions.isNotEmpty) {
        baseQuery += ' WHERE ${whereConditions.join(' AND ')}';
      }

      final result = await _conn.execute(
        Sql.named(baseQuery),
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
    String? positionId,
    String? officerName,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final officeList = <String>[];
      final Map<String, dynamic> params = {
        'page_size': pageSize,
        'offset': offset,
      };
      final whereConditions = <String>[];

      String baseQuery = '''
      SELECT name FROM Officers
      ''';

      whereConditions.add('officer_status = @status');
      params['status'] = OfficerStatus.active.toString().split('.').last;

      if (positionId != null && positionId.isNotEmpty) {
        whereConditions.add('position_id = @position_id');
        params['position_id'] = positionId;
      }

      if (officerName != null && officerName.isNotEmpty) {
        whereConditions.add('name ILIKE @name');
        params['name'] = '%$officerName%';
      }

      if (whereConditions.isNotEmpty) {
        baseQuery += ' WHERE ${whereConditions.join(' AND ')}';
      }

      final finalQuery = '''
      $baseQuery
      ORDER BY name ASC
      LIMIT @page_size OFFSET @offset;
      ''';

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

  Future<bool> checkIfAccountableOfficerExist({
    required String name,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT * FROM Officers WHERE name ILIKE @name;
        ''',
      ),
      parameters: {
        'name': name,
      },
    );

    return result.isNotEmpty;
  }

  Future<String?> getOfficerId({
    required String positionId,
    required String name,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT id FROM Officers
        WHERE 
          position_id = @position_id
        AND
          name ILIKE @name;
        ''',
      ),
      parameters: {
        'position_id': positionId,
        'name': name,
      },
    );

    if (result.isNotEmpty) {
      return result.first[0] as String;
    }

    return null;
  }
}
