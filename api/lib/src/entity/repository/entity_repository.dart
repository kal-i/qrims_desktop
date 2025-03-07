import 'package:postgres/postgres.dart';

import '../../utils/generate_id.dart';
import '../model/entity.dart';

class EntityRepository {
  const EntityRepository(this._conn);

  final Connection _conn;

  Future<String> generateUniqueEntityId() async {
    while (true) {
      final entityId = generatedId('NTTY');

      final result = await _conn.execute(
        Sql.named(
          '''SELECT COUNT(id) FROM Entities WHERE id = @id;''',
        ),
        parameters: {
          'id': entityId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return entityId;
      }
    }
  }

  Future<String> registerEntity({
    required String entityName,
  }) async {
    try {
      final entityId = await generateUniqueEntityId();

      await _conn.execute(
        Sql.named(
          '''
        INSERT INTO Entities
        (id, name)
        VALUES
        (@id, @name)
        ''',
        ),
        parameters: {
          'id': entityId,
          'name': entityName,
        },
      );

      return entityId;
    } catch (e) {
      print('Error registering entity: $e');
      throw Exception('Failed to register entity');
    }
  }

  Future<String> checkEntityIfExist({
    required String entityName,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''SELECT id FROM Entities WHERE name ILIKE @name''',
      ),
      parameters: {
        'name': entityName,
      },
    );

    if (result.isEmpty) {
      print('registered new entity');
      return await registerEntity(
        entityName: entityName,
      );
    } else {
      print('entity id: ${result.first[0]}');
      return result.first[0] as String;
    }
  }

  Future<Entity?> getEntityById({
    required String id,
  }) async {
    try {
      final result = await _conn.execute(
        Sql.named(
          '''SELECT * FROM Entities WHERE id = @id''',
        ),
        parameters: {
          'id': id,
        },
      );

      if (result.isNotEmpty) {
        for (final row in result) {
          final entityMap = {
            'entity_id': row[0],
            'entity_name': row[1],
          };
          return Entity.fromJson(entityMap);
        }
      }

      return null;
    } catch (e) {
      print('Error fetching entity by ID: $e');
      throw Exception('Failed to get entity');
    }
  }

  Future<int> getEntitiesFilteredCount({
    String? entityName,
  }) async {
    try {
      final Map<String, dynamic> params = {};

      String baseQuery = '''
      SELECT COUNT(*)
      FROM Entities
      ''';

      if (entityName != null && entityName.isNotEmpty) {
        baseQuery += 'WHERE name ILIKE @name';
        params['name'] = '%$entityName%';
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
      throw Exception('Failed to get filtered entity count');
    }
  }

  Future<List<String>> getEntities({
    required int page,
    required int pageSize,
    String? entityName,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final officeList = <String>[];
      final Map<String, dynamic> params = {};

      String baseQuery = '''
      SELECT name FROM Entities
      ''';

      if (entityName != null && entityName.isNotEmpty) {
        baseQuery += 'WHERE name ILIKE @name';
        params['name'] = '%$entityName%';
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
      print('Error fetching entities: $e');
      throw Exception('Failed to fetch entities');
    }
  }

  Future<bool?> updateEntity({
    required String id,
    required String name,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        UPDATE Entities
        SET name = @name
        WHERE id = @id;
        ''',
      ),
      parameters: {
        'id': id,
        'name': name,
      },
    );

    return result.affectedRows == 1;
  }
}
