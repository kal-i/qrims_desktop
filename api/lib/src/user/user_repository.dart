import 'dart:math';

import 'package:api/src/utils/hash_extension.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:postgres/postgres.dart';

import 'user.dart';

class UserRepository {
  const UserRepository(this._conn);

  final Connection _conn;

  String _generateOtp() {
    final random = Random();
    return String.fromCharCodes(
        List.generate(4, (index) => random.nextInt(10) + 48));
  }

  void _sendEmailOtp(String email, String otp) async {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final senderEmail = env['SENDER_EMAIL'] as String;
    final appPassword = env['APP_PASSWORD'] as String;

    final smtpServer = gmail(senderEmail, appPassword);
    final message = Message()
      ..from = Address(senderEmail, 'qrims')
      ..recipients.add(email)
      ..subject = 'Email Verification'
      ..text = 'Your OTP code is $otp. It will expire in 10 minutes.';

    try {
      await send(message, smtpServer);
    } on MailerException catch (e) {
      print('Message not sent. $e');
    }
  }

  Future<void> sendEmailOtp(String email) async {
    try {
      final otp = _generateOtp();
      final otpExpiry = DateTime.now().add(Duration(minutes: 10));

      print(otp);

      /// Check if email is registered in the db
      /// to avoid sending wasting the daily sending limit of email
      final userExist = await checkUserIfExist(
        email: email,
      );

      if (!userExist) {
        throw Exception('User email is not registered.');
      }

      /// TODO: before sending an otp, check if existing otp is expired
      // final lastOtpCreation = await _conn.execute(
      //   Sql.named(
      //     '''
      //     SELECT otp_creation FROM Users
      //     WHERE email = @email;
      //     ''',
      //   ),
      //   parameters: {
      //     'email': email,
      //   },
      // );
      //
      // if (lastOtpCreation.isNotEmpty && lastOtpCreation[0][0] != null) {
      //   final lastRequest = lastOtpCreation[0][0] as DateTime;
      //   final difference = currentDateTime.difference(lastRequest);
      //   print(difference);
      //   if (difference.inMinutes < 10) {
      //     throw Exception('Please wait for 10 minutes before requesting a new OTP.');
      //   }
      // }
      // print('after diff');

      await _conn.execute(
        Sql.named(
          '''
          UPDATE Users
          SET otp = @otp, otp_expiry = @otp_expiry
          WHERE email = @email;
          ''',
        ),
        parameters: {
          'email': email,
          'otp': otp,
          'otp_expiry': otpExpiry.toIso8601String(),
        },
      );

      _sendEmailOtp(email, otp);
    } catch (e) {
      if (e.toString().contains('User email is not registered.')) {
        throw Exception('User email is not registered.');
      }
      if (e.toString().contains(
          'Please wait for 10 minutes before requesting a new OTP.')) {
        throw Exception(
            'Please wait for 10 minutes before requesting a new OTP.');
      }
      print('Error in sendEmailOtp: $e');
      throw Exception('Failed to send OTP.');
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final result = await _conn.execute(
        Sql.named(
          '''
          SELECT id, otp, otp_expiry
          FROM Users
          WHERE email = @email;
          ''',
        ),
        parameters: {
          'email': email,
        },
      );

      if (result.isEmpty) {
        throw Exception('User email not found.');
      }

      for (final row in result) {
        final userId = row[0] as int;
        final storedOtp = row[1] as String;
        final otpExpiry = row[2] as DateTime;

        print('Stored OTP: $storedOtp');
        print('Provided OTP: $otp');
        print('OTP expiry: $otpExpiry');
        print('Current Time: ${DateTime.now().toUtc()}');

        final nowUtc = DateTime.now().toUtc();
        final isBefore = nowUtc.isBefore(otpExpiry.toUtc());

        print('Is current time before OTP expiry? $isBefore');

        if (storedOtp == otp && isBefore) {
          // DateTime.now().toUtc().isBefore(otpExpiry.toUtc())) {
          await _conn.execute(
            Sql.named(
              '''
              UPDATE Users
              SET auth_status = @auth_status, otp = null, otp_expiry = null
              WHERE id = @id;
              ''',
            ),
            parameters: {
              'id': userId,
              'auth_status':
                  AuthStatus.authenticated.toString().split('.').last,
            },
          );
          print('OTP verified');
          return true;
        } else {
          print('Invalid OTP or OTP expired.');
        }
      }
      return false;
    } catch (e) {
      print('Error verifying OTP for email $email: $e.');
      return false;
    }
  }

  Future<int> getUsersCount() async {
    try {
      final result = await _conn.execute(
        Sql(
          '''
          SELECT COUNT(*) FROM Users;
          ''',
        ),
      );

      return int.parse(result.first[0].toString());
    } catch (e) {
      throw Exception('Failed to fetch user count. ${e.toString()}');
    }
  }

  Future<int> getUsersFilteredCount({
    String? searchQuery,
    String? filter,
  }) async {
    try {
      final int? searchQueryAsInt =
          searchQuery != null ? int.tryParse(searchQuery) : null;

      final baseQuery = '''
        SELECT COUNT(*)
        FROM Users
        LEFT JOIN SupplyDepartmentEmployees ON Users.id = SupplyDepartmentEmployees.user_id
        LEFT JOIN MobileUsers ON Users.id = MobileUsers.user_id
        ''';

      final whereClause = StringBuffer();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
          '''
        WHERE (Users.id = @search_query_as_int OR Users.name ILIKE @search_query)
        ''',
        );
      }

      if (filter != null && filter.isNotEmpty) {
        if (whereClause.isNotEmpty) {
          whereClause.write(' AND ');
        } else {
          whereClause.write('WHERE ');
        }

        if (filter == 'supply') {
          whereClause.write('SupplyDepartmentEmployees.id IS NOT NULL');
        } else if (filter == 'mobile') {
          whereClause.write('MobileUsers.id IS NOT NULL');
        } else if (filter == 'unauthenticated') {
          whereClause.write('Users.auth_status = \'unauthenticated\'');
        } else if (filter == 'authenticated') {
          whereClause.write('Users.auth_status = \'authenticated\'');
        } else if (filter == 'revoked') {
          whereClause.write('Users.auth_status = \'revoked\'');
        } else {
          throw ArgumentError('Invalid user type: $filter.');
        }
      }

      final finalQuery = '''
      $baseQuery
      $whereClause
      ''';

      final params = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['search_query'] = '%$searchQuery%';
        params['search_query_as_int'] = searchQueryAsInt;
      }

      final result = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      if (result.isNotEmpty) {
        final count = result.first[0] as int;
        print('Total no. of filtered users: $count');
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      print('Err counting filtered users: $e');
      throw Exception(e.toString());
    }
  }

  Future<List<User>?> getUsers({
    String? searchQuery,
    required int page,
    required int pageSize,
    String sortBy = 'created_at', // default sort
    bool sortAscending = false, // default sort order
    String? filter, // filter by user type
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final userList = <User>[];
      final int? searchQueryAsInt =
          searchQuery != null ? int.tryParse(searchQuery) : null;

      // to avoid sql injection, we'll check if it is a valid sort col
      final validSortColumns = {'id', 'created_at'};
      if (!validSortColumns.contains(sortBy)) {
        throw ArgumentError('Invalid sort column: $sortBy');
      }

      final sortColumn = sortBy == 'id' ? 'Users.id' : 'Users.created_at';

      final baseQuery = '''
          SELECT 
            Users.id AS user_id,
            Users.name,
            Users.email,
            Users.password,
            to_char(Users.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS created_at,
            to_char(Users.updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS updated_at,
            Users.auth_status,
            Users.otp,
            to_char(Users.otp_expiry, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS otp_expiry,
            Users.profile_image,
            SupplyDepartmentEmployees.id AS supp_dept_emp_id,
            SupplyDepartmentEmployees.role,
            MobileUsers.id as mobile_user_id
          FROM
            Users
          LEFT JOIN
            SupplyDepartmentEmployees ON Users.id = SupplyDepartmentEmployees.user_id
          LEFT JOIN
            MobileUsers ON Users.id = MobileUsers.user_id
          ''';

      // ILIKE is used for case-insensitive matching
      final whereClause = StringBuffer();
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
          '''
          WHERE (Users.id = @search_query_as_int OR Users.name ILIKE @search_query)
          ''',
        );
      }

      if (filter != null && filter.isNotEmpty) {
        if (whereClause.isNotEmpty) {
          whereClause.write(' AND ');
        } else {
          whereClause.write('WHERE ');
        }

        if (filter == 'supply') {
          whereClause.write('SupplyDepartmentEmployees.id IS NOT NULL');
        } else if (filter == 'mobile') {
          whereClause.write('MobileUsers.id IS NOT NULL');
        } else if (filter == 'unauthenticated') {
          whereClause.write('Users.auth_status = \'unauthenticated\'');
        } else if (filter == 'authenticated') {
          whereClause.write('Users.auth_status = \'authenticated\'');
        } else if (filter == 'revoked') {
          whereClause.write('Users.auth_status = \'revoked\'');
        } else {
          throw ArgumentError('Invalid user type: $filter.');
        }
      }

      final sortDirection = sortAscending ? 'ASC' : 'DESC';

      final finalQuery = '''
      $baseQuery
      $whereClause
      ORDER BY
        $sortColumn $sortDirection
      LIMIT @page_size OFFSET @offset;
      ''';

      final params = <String, dynamic>{};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['search_query'] = '%$searchQuery%';
        params['search_query_as_int'] = searchQueryAsInt;
      }
      params['page_size'] = pageSize;
      params['offset'] = offset;

      final results = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      for (final row in results) {
        final userMap = {
          'user_id': row[0],
          'name': row[1],
          'email': row[2],
          'password': row[3],
          'created_at': row[4],
          'updated_at': row[5] != null ? row[5] : null,
          'auth_status': row[6],
          'otp': row[7],
          'otp_expiry': row[8],
          'profile_image': row[9],
          'supp_dept_emp_id': row[10],
          'role': row[11],
          'mobile_user_id': row[12],
        };

        if (row[11] != null) {
          try {
            userList.add(SupplyDepartmentEmployee.fromJson(userMap));
          } catch (e) {
            print('Error parsing SupplyDepartmentEmployee: $e');
          }
        } else {
          userList.add(MobileUser.fromJson(userMap));
        }
      }

      print('Fetched users for page $page: ${userList.length}');
      return userList;
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to fetch users.');
    }
  }

  Future<User?> getUserInformation({
    int? id,
    String? email,
  }) async {
    var baseQuery = '''
        SELECT Users.id AS user_id,
          Users.name,
          Users.email,
          Users.password,
          to_char(Users.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS created_at,
          to_char(Users.updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS updated_at,
          Users.auth_status,
          Users.otp,
          to_char(Users.otp_expiry, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS otp_expiry,
          Users.profile_image,
          SupplyDepartmentEmployees.id AS supp_dept_emp_id,
          SupplyDepartmentEmployees.role,
          MobileUsers.id as mobile_user_id
        FROM
          Users
        LEFT JOIN
          SupplyDepartmentEmployees ON Users.id = SupplyDepartmentEmployees.user_id
        LEFT JOIN
          MobileUsers ON Users.id = MobileUsers.user_id
        WHERE
    ''';

    final Map<String, dynamic> parameters = {};

    if (id != null) {
      baseQuery += 'Users.id = @id';
      parameters['id'] = id;
    }

    if (email != null) {
      baseQuery += 'Users.email = @email';
      parameters['email'] = email;
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: parameters,
    );

    for (final row in result) {
      final userMap = {
        'user_id': row[0],
        'name': row[1],
        'email': row[2],
        'password': row[3],
        'created_at': row[4],
        'updated_at': row[5],
        'auth_status': row[6],
        'otp': row[7],
        'otp_expiry': row[8],
        'profile_image': row[9],
        'supp_dept_emp_id': row[10],
        'role': row[11],
        'mobile_user_id': row[12],
      };

      if (row[11] != null) {
        return SupplyDepartmentEmployee.fromJson(userMap);
      } else {
        return MobileUser.fromJson(userMap);
      }
    }
    return null;
  }

  Future<bool> checkUserIfExist({
    int? userId,
    String? name,
    String? email,
  }) async {
    /// We've converted the parameters to a list
    /// Then we're gonna iterate through each elem on the list to check if an elem is null
    /// Then it will be counted by the length property, in which we will use to check again if it is not equal to one
    if ([userId, name, email].where((element) => element != null).length != 1) {
      throw ArgumentError('Only one parameter must be provided.');
    }

    String query = 'SELECT * FROM Users WHERE ';
    Map<String, dynamic> parameters = {};

    if (userId != null) {
      query += 'user_id = @userId';
      parameters['user_id'] = userId;
    }

    if (name != null) {
      query += 'name = @name';
      parameters['name'] = name;
    }

    if (email != null) {
      query += 'email = @email';
      parameters['email'] = email;
    }

    final result = await _conn.execute(
      Sql.named(
        query,
      ),
      parameters: parameters,
    );

    return result.isNotEmpty;
  }

  Future<User?> createUser({
    required String name,
    required String email,
    required String password,
    required DateTime createdAt,
    Role? role,
  }) async {
    try {
      final hashedPassword = password.hashValue;

      List<List<dynamic>> userResult = await _conn.execute(
        Sql.named(
          '''
          INSERT INTO Users (name, email, password, created_at)
          VALUES 
          (@name, @email, @password, @created_at) RETURNING id;
          ''',
        ),
        parameters: {
          'name': name,
          'email': email,
          'password': hashedPassword,
          'created_at': createdAt,
        },
      );

      if (userResult.isEmpty) {
        throw Exception('Failed to insert a new record to user table.');
      }

      // return the id generated from the query
      final userId = userResult.first[0] as int;

      // if role is equal to null, insert into mobile user table.
      // Otherwise, insert to supply dept. table
      if (role == null) {
        final mobileUserResult = await _conn.execute(
          Sql.named(
            '''
            INSERT INTO MobileUsers (user_id) 
            VALUES 
            (@user_id) RETURNING id;
            ''',
          ),
          parameters: {
            'user_id': userId,
          },
        );

        if (mobileUserResult.isEmpty) {
          throw Exception(
              'Failed to insert a new record to mobile user table.');
        }

        final mobileUserId = mobileUserResult.first[0] as int;

        return MobileUser(
          id: userId,
          name: name,
          email: email,
          password: hashedPassword,
          createdAt: createdAt,
          //updatedAt: updatedAt,
          //isAuthenticated: false,
          //otp: ,
          //otpExpiry: ,
          mobileUserId: mobileUserId,
        );
      } else {
        final supplyDepartmentEmployeeResult = await _conn.execute(
          Sql.named(
            '''
            INSERT INTO SupplyDepartmentEmployees (user_id, role)
            VALUES 
            (@user_id, @role) RETURNING id;
            ''',
          ),
          parameters: {
            'user_id': userId,
            'role': role.toString(),
          },
        );

        if (supplyDepartmentEmployeeResult.isEmpty) {
          throw Exception(
              'Failed to insert a new record to supply department employee table.');
        }

        final supplyDepartmentEmployeeId =
            supplyDepartmentEmployeeResult.first[0] as int;

        return SupplyDepartmentEmployee(
          id: userId,
          name: name,
          email: email,
          password: hashedPassword,
          createdAt: createdAt,
          //updatedAt: updatedAt,
          //isAuthenticated: false,
          //otp: ,
          //otpExpiry: ,
          employeeId: supplyDepartmentEmployeeId,
          role: role,
        );
      }
    } catch (e) {
      if (e
          .toString()
          .contains('duplicate key value violates unique constraint')) {
        throw Exception('Email already exists.');
      }
      print('Error creating user: $e');
      throw Exception('Database connection error.');
    }
  }

  Future<bool?> updateUserInformation({
    required int id,
    String? name,
    String? email,
    String? password,
    Role? role,
  }) async {
    final List<String> setClauses = [];
    final Map<String, dynamic> parameters = {
      'id': id,
    };

    /// Add clauses and parameters if the parameters passed are non-null values
    if (name != null) {
      setClauses.add('name = @name');
      parameters['name'] = name;
    }

    if (email != null) {
      setClauses.add('email = @email');
      parameters['email'] = email;
    }

    if (password != null) {
      setClauses.add('password = @password');
      parameters['password'] = password.hashValue;
    }

    if (role != null) {
      setClauses.add('role = @role');
      parameters['role'] = role;
    }

    /// if no parameters passed, return false
    if (setClauses.isEmpty) {
      return false;
    }

    setClauses.add('updated_at = @updated_at');
    parameters['updated_at'] = DateTime.now();

    final setClause = setClauses.join(', ');
    print(setClause);
    final result = await _conn.execute(
      Sql.named('''
      UPDATE Users
      SET $setClause
      WHERE id = @id;
      '''),
      parameters: parameters,
    );

    return result.affectedRows == 1;
  }

  Future<bool?> updateUserAuthenticationStatus({
    required int id,
    required AuthStatus authStatus,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        UPDATE Users
        SET auth_status = @auth_status
        WHERE id = @id;
        ''',
      ),
      parameters: {
        'id': id,
        'auth_status': authStatus.toString().split('.').last,
      },
    );

    return result.affectedRows == 1;
  }

  Future<bool?> updateUserPassword({
    required String email,
    required String password,
  }) async {
    final hashedPassword = password.hashValue;

    /// check if email exist
    /// we could prolly omit this because we're already checking before sending an otp
    // final result = await _conn.execute(
    //   Sql.named(
    //     '''
    //     SELECT email
    //     FROM Users
    //     WHERE email = @email;
    //     ''',
    //   ),
    //   parameters: {
    //     'email': email,
    //   },
    // );

    // if (result.isEmpty) {
    //   throw Exception('User email not found.');
    // }

    final result = await _conn.execute(
      Sql.named(
        '''
          UPDATE Users
          SET password = @password, updated_at = @updated_at
          WHERE email = @email;
          ''',
      ),
      parameters: {
        'email': email,
        'password': hashedPassword,
        'updated_at': DateTime.now(),
      },
    );

    return result.affectedRows == 1;
  }

  //Future<List<User>?> getAdmins()

  Future<User?> checkUserCredentialFromDatabase({
    required String email,
    required String password,
  }) async {
    /// Convert the parameterized password to hash
    final hashedPassword = password.hashValue;

    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT Users.id AS user_id,
          Users.name,
          Users.email,
          Users.password,
          to_char(Users.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS created_at,
          to_char(Users.updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS updated_at,
          Users.auth_status,
          Users.otp,
          to_char(Users.otp_expiry, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS otp_expiry,
          Users.profile_image,
          SupplyDepartmentEmployees.id AS supp_dept_emp_id,
          SupplyDepartmentEmployees.role,
          MobileUsers.id as mobile_user_id
        FROM
          Users
        LEFT JOIN
          SupplyDepartmentEmployees ON Users.id = SupplyDepartmentEmployees.user_id
        LEFT JOIN
          MobileUsers ON Users.id = MobileUsers.user_id
        WHERE
          Users.email = @email AND Users.password = @password;
      ''',
      ),
      parameters: {
        'email': email,
        'password': hashedPassword,
      },
    );

    /// Return a concrete User if result is not empty
    /// Otherwise, return null
    if (result.isNotEmpty) {
      for (final row in result) {
        final userMap = {
          'user_id': row[0],
          'name': row[1],
          'email': row[2],
          'password': row[3],
          'created_at': row[4],
          'updated_at': row[5],
          'auth_status': row[6],
          'otp': row[7],
          'otp_expiry': row[8],
          'profile_image': row[9],
          'supp_dept_emp_id': row[10],
          'role': row[11],
          'mobile_user_id': row[12],
        };

        if (row[11] != null) {
          return SupplyDepartmentEmployee.fromJson(userMap);
        } else {
          return MobileUser.fromJson(userMap);
        }
      }
    }
    return null;
  }
}
