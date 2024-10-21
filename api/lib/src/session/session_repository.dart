import 'package:api/src/user/repository/user_repository.dart';
import 'package:api/src/utils/hash_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:postgres/postgres.dart';

class Session extends Equatable {
  const Session({
    required this.token,
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
  });

  final String token;
  final String userId;
  final DateTime createdAt;
  final DateTime expiresAt;

  factory Session.fromMap(Map<String, dynamic> json) {
    return Session(
      token: json['token'] as String,
      userId: json['user_id'] as String,
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : json['created_at'] as DateTime,
      expiresAt: json['expires_at'] is String
          ? DateTime.parse(json['expires_at'] as String)
          : json['expires_at'] as DateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user_id': userId,
      'created_at': createdAt,
      'expiry_date': expiresAt,
    };
  }

  @override
  List<Object?> get props => [
        token,
        userId,
        createdAt,
        expiresAt,
      ];
}

class SessionRepository {
  const SessionRepository(this._conn);

  final Connection _conn;

  Future<Session> createSession(String userId) async {
    final user = await UserRepository(_conn).getUserInformation(id: userId);

    if (user == null) {
      throw Exception('User with ID $userId does not exist.');
    }

    final existingSession = await _conn.execute(
      Sql.named('''
          SELECT * FROM Sessions
          WHERE user_id = @user_id;
          '''),
      parameters: {
        'user_id': userId,
      },
    );

    if (existingSession.isNotEmpty) {
      await _conn.execute(
        Sql.named('''
            DELETE FROM Sessions
            WHERE user_id = @user_id;
            '''),
        parameters: {
          'user_id': userId,
        },
      );
    }

    final session = Session(
      token: generateToken(userId),
      userId: userId,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
      createdAt: DateTime.now(),
    );

    await _conn.execute(
      Sql.named(
        '''
        INSERT INTO Sessions (token, user_id, created_at, expires_at)
        VALUES
        (@token, @user_id, @created_at, @expires_at);
        ''',
      ),
      parameters: {
        'token': session.token,
        'user_id': session.userId,
        'created_at': session.createdAt.toIso8601String(),
        'expires_at': session.expiresAt.toIso8601String(),
      },
    );

    return session;
  }

  String generateToken(String userId) {
    return '${userId}_${DateTime.now().toIso8601String()}'.hashValue;
  }

  Future<void> deleteSession(String token) async {
    await _conn.execute(
      Sql.named('''
            DELETE FROM Sessions
            WHERE token = @token;
            '''),
      parameters: {
        'token': token,
      },
    );
  }

  /// Search a session of a particular token
  Future<Session?> sessionFromToken(String token) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT * FROM Sessions
        WHERE token = @token;
        ''',
      ),
      parameters: {
        'token': token,
      },
    );

    for (final row in result) {
      final sessionMap = {
        'token': row[0],
        'user_id': row[1],
        'created_at': row[2],
        'expires_at': row[3],
      };

      final session = Session.fromMap(sessionMap);

      if (session.expiresAt.isAfter(DateTime.now())) {
        return session;
      }
    }

    return null;
  }

  Future<int?> extractUserIdFromSessionToken({
    required String token,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
      SELECT user_id FROM Sessions
      WHERE token = @token;
      ''',
      ),
      parameters: {
        'token': token,
      },
    );

    return result.first[0] as int;
  }
}
