import 'dart:math';

import 'package:api/src/organization_management/models/officer.dart';
import 'package:api/src/services/email_service.dart';
import 'package:api/src/utils/hash_extension.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:postgres/postgres.dart';

import '../models/user.dart';

class UserRepository {
  UserRepository(this._conn) : _emailService = EmailService();

  final Connection _conn;
  final EmailService _emailService;

  String _generateOtp() {
    final random = Random();
    return String.fromCharCodes(
        List.generate(4, (index) => random.nextInt(10) + 48));
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

      await _emailService.sendOtpEmail(email, otp);
    } catch (e) {
      if (e.toString().contains('User email is not registered.')) {
        throw Exception('User email is not registered.');
      }

      print('Error in sendEmailOtp: $e');
      throw Exception('Failed to send OTP.');
    }
  }

  Future<void> sendAdminApprovalEmail(String email) async {
    try {
      /// Check if email is registered in the db
      /// to avoid sending wasting the daily sending limit of email
      final userExist = await checkUserIfExist(
        email: email,
      );

      if (!userExist) {
        throw Exception('User email is not registered.');
      }

      await _emailService.sendAdminApprovalEmail(email);
    } catch (e) {
      if (e.toString().contains('User email is not registered.')) {
        throw Exception('User email is not registered.');
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

      final row = result.first;
      final userId = row[0] as String;
      final storedOtp = row[1] as String?;
      final otpExpiry = row[2] as DateTime?;

      if (storedOtp != null && otpExpiry != null) {
        print('otp and expiry not null: $otp - $otpExpiry');
        if (storedOtp == otp && DateTime.now().isBefore(otpExpiry)) {
          //DateTime.now().isBefore(otpExpiry)) {
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

  Future<bool?> updateAdminApprovalStatus({
    required String id,
    required AdminApprovalStatus adminApprovalStatus,
  }) async {
    final result = await _conn.execute(
      Sql.named(
        '''
        UPDATE MobileUsers
        SET admin_approval_status = @admin_approval_status
        WHERE user_id = @user_id;
        ''',
      ),
      parameters: {
        'user_id': id,
        'admin_approval_status': adminApprovalStatus.toString().split('.').last,
      },
    );

    if (adminApprovalStatus == AdminApprovalStatus.rejected) {
      final deleteResult = await _conn.execute(
        Sql.named(
          '''
          DELETE FROM Users
          WHERE id = @id;
          ''',
        ),
        parameters: {
          'id': id,
        },
      );

      return result.affectedRows == 1 && deleteResult.affectedRows == 1;
    }

    return result.affectedRows == 1;
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
    String? role,
    AuthStatus? status,
    AdminApprovalStatus? adminApprovalStatus,
    bool isArchived = false,
  }) async {
    try {
      final baseQuery = '''
      SELECT COUNT(*)
      FROM Users u
      LEFT JOIN SupplyDepartmentEmployees s ON u.id = s.user_id
      LEFT JOIN MobileUsers m ON u.id = m.user_id
      ''';

      final params = <String, dynamic>{
        'is_archived': isArchived,
      };

      final whereClause = StringBuffer();
      whereClause.write('WHERE u.is_archived = @is_archived');
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
          ' AND (CAST(u.id AS TEXT) ILIKE @search_query OR u.name ILIKE @search_query)',
        );
        params['search_query'] = '%$searchQuery%';
      }

      if (status != null) {
        whereClause.write(' AND u.auth_status = @status');
        params['status'] = status.toString().split('.').last;
      }

      if (role != null && role.isNotEmpty) {
        if (role == 'supply') {
          whereClause.write(' AND s.id IS NOT NULL');
          params.remove('admin_approval_status');
        } else if (role == 'mobile') {
          whereClause.write(' AND m.id IS NOT NULL');

          if (adminApprovalStatus != null) {
            whereClause
                .write(' AND m.admin_approval_status = @admin_approval_status');
            params['admin_approval_status'] =
                adminApprovalStatus.toString().split('.').last;
          }
        } else {
          throw ArgumentError('Invalid role: $role.');
        }
      } else {
        whereClause.write(''' AND (
          (m.id IS NOT NULL AND m.admin_approval_status = @admin_approval_status)
          OR
          m.id IS NULL
          )''');
        params['admin_approval_status'] =
            adminApprovalStatus.toString().split('.').last;
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
        print('Total no. of filtered users: $count');
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error counting filtered users: $e');
      throw Exception('Failed to count filtered users.');
    }
  }

  Future<List<User>?> getUsers({
    String? searchQuery,
    required int page,
    required int pageSize,
    String sortBy = 'created_at',
    bool sortAscending = false,
    String? role,
    AuthStatus? status,
    AdminApprovalStatus? adminApprovalStatus,
    bool isArchived = false,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final userList = <User>[];
      final params = <String, dynamic>{
        'is_archived': isArchived,
        'page_size': pageSize,
        'offset': offset,
      };

      final validSortColumns = {'id', 'created_at'};
      if (!validSortColumns.contains(sortBy)) {
        throw ArgumentError('Invalid sort column: $sortBy');
      }
      final sortColumn = sortBy == 'id' ? 'u.id' : 'u.created_at';

      final baseQuery = '''
      SELECT 
        u.id AS user_id,
        u.name,
        u.email,
        u.password,
        to_char(u.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS created_at,
        to_char(u.updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS updated_at,
        u.auth_status,
        u.is_archived,
        u.otp,
        to_char(u.otp_expiry, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS otp_expiry,
        u.profile_image,
        s.id AS supp_dept_emp_id,
        s.role,
        m.id AS mobile_user_id,
        ofc.id AS officer_id,
        ofr.user_id AS officer_user_id,
        ofr.name AS officer_name,
        pos.id AS position_id,
        pos.position_name AS position_name,
        ofc.name AS office_name,
        ofr.is_archived AS officer_is_archived,
        m.admin_approval_status 
      FROM
        Users u
      LEFT JOIN
        SupplyDepartmentEmployees s ON u.id = s.user_id
      LEFT JOIN
        MobileUsers m ON u.id = m.user_id
      LEFT JOIN
        Officers ofr ON u.id = ofr.user_id
      LEFT JOIN
        Positions pos ON ofr.position_id = pos.id
      LEFT JOIN
        Offices ofc ON pos.office_id = ofc.id
    ''';

      final whereClause = StringBuffer('WHERE u.is_archived = @is_archived');
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause.write(
            ' AND (u.id ILIKE @search_query OR u.name ILIKE @search_query)');
        params['search_query'] = '%$searchQuery%';
      }

      if (status != null) {
        whereClause.write(' AND u.auth_status = @status');
        params['status'] = status.toString().split('.').last;
      }

      if (role != null && role.isNotEmpty) {
        if (role == 'supply') {
          whereClause.write(' AND s.id IS NOT NULL');
          params.remove('admin_approval_status');
        } else if (role == 'mobile') {
          whereClause.write(' AND m.id IS NOT NULL');

          if (adminApprovalStatus != null) {
            whereClause
                .write(' AND m.admin_approval_status = @admin_approval_status');
            params['admin_approval_status'] =
                adminApprovalStatus.toString().split('.').last;
          }
        } else {
          throw ArgumentError('Invalid role: $role.');
        }
      } else {
        whereClause.write(''' AND (
          (m.id IS NOT NULL AND m.admin_approval_status = @admin_approval_status)
          OR
          m.id IS NULL
          )''');
        params['admin_approval_status'] =
            adminApprovalStatus.toString().split('.').last;
      }

      final sortDirection = sortAscending ? 'ASC' : 'DESC';

      final finalQuery = '''
      $baseQuery
      ${whereClause.toString()}
      ORDER BY $sortColumn $sortDirection
      LIMIT @page_size OFFSET @offset;
    ''';

      // Debugging: Print final query and params to validate SQL construction
      print('Executing Query: $finalQuery');
      print('Parameters: $params');

      final results = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      for (final row in results) {
        final isSupplyDepartmentEmployee = row[11] != null;
        final isMobileUser = row[13] != null;

        if (isSupplyDepartmentEmployee) {
          userList.add(SupplyDepartmentEmployee.fromJson({
            'user_id': row[0],
            'name': row[1],
            'email': row[2],
            'password': row[3],
            'created_at': row[4].toString(),
            'updated_at': row[5]?.toString(),
            'auth_status': row[6],
            'is_archived': row[7],
            'otp': row[8],
            'otp_expiry': row[9]?.toString(),
            'profile_image': row[10],
            'supp_dept_emp_id': row[11],
            'role': row[12],
          }));
        }

        if (isMobileUser) {
          userList.add(MobileUser.fromJson({
            'user_id': row[0],
            'name': row[1],
            'email': row[2],
            'password': row[3],
            'created_at': row[4].toString(),
            'updated_at': row[5]?.toString(),
            'auth_status': row[6],
            'is_archived': row[7],
            'otp': row[8],
            'otp_expiry': row[9]?.toString(),
            'profile_image': row[10],
            'mobile_user_id': row[13],
            'officer_id': row[14],
            'officer_user_id': row[15],
            'officer_name': row[16],
            'position_id': row[17],
            'position_name': row[18],
            'office_name': row[19],
            'officer_is_archived': row[20],
            'admin_approval_status': row[21],
          }));
        }
      }
      print('Fetched users for page $page: ${userList.length}');
      return userList;
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to fetch users.');
    }
  }

  Future<int> getPendingUsersFilteredCount() async {
    try {
      final baseQuery = '''
      SELECT 
        COUNT(*)
      FROM 
        Users u
      LEFT JOIN 
        MobileUsers m ON u.id = m.user_id
      WHERE 
        u.is_archived  = @is_archived
      AND
        u.auth_status = @auth_status
      AND
        m.admin_approval_status = @admin_approval_status;
      ''';

      final params = <String, dynamic>{
        'is_archived': false,
        'auth_status': 'authenticated',
        'admin_approval_status': 'pending',
      };

      final result = await _conn.execute(
        Sql.named(baseQuery),
        parameters: params,
      );

      if (result.isNotEmpty) {
        final count = result.first[0] as int;
        print('Total no. of filtered pending users: $count');
        return count;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error counting filtered pending users: $e');
      throw Exception('Failed to count filtered pending users.');
    }
  }

  Future<List<MobileUser>?> getPendingUsers({
    required int page,
    required int pageSize,
  }) async {
    try {
      final offset = (page - 1) * pageSize;
      final userList = <MobileUser>[];
      final params = <String, dynamic>{
        'page_size': pageSize,
        'offset': offset,
        'is_archived': false,
        'auth_status': 'authenticated',
        'admin_approval_status': 'pending',
      };

      final baseQuery = '''
      SELECT 
        u.id AS user_id,
        u.name,
        u.email,
        u.password,
        to_char(u.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS created_at,
        to_char(u.updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS updated_at,
        u.auth_status,
        u.is_archived,
        u.otp,
        to_char(u.otp_expiry, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS otp_expiry,
        u.profile_image,
        m.id AS mobile_user_id,
        ofc.id AS officer_id,
        ofr.user_id AS officer_user_id,
        ofr.name AS officer_name,
        pos.id AS position_id,
        pos.position_name AS position_name,
        ofc.name AS office_name,
        ofr.is_archived AS officer_is_archived,
        m.admin_approval_status 
      FROM
        Users u
      LEFT JOIN
        MobileUsers m ON u.id = m.user_id
      LEFT JOIN
        Officers ofr ON u.id = ofr.user_id
      LEFT JOIN
        Positions pos ON ofr.position_id = pos.id
      LEFT JOIN
        Offices ofc ON pos.office_id = ofc.id
      WHERE 
        u.is_archived = @is_archived
      AND
        u.auth_status = @auth_status
      AND
        m.admin_approval_status = @admin_approval_status
    ''';

      final finalQuery = '''
      $baseQuery
      ORDER BY u.created_at DESC
      LIMIT @page_size OFFSET @offset;
    ''';

      final results = await _conn.execute(
        Sql.named(finalQuery),
        parameters: params,
      );

      for (final row in results) {
        userList.add(MobileUser.fromJson({
          'user_id': row[0],
          'name': row[1],
          'email': row[2],
          'password': row[3],
          'created_at': row[4].toString(),
          'updated_at': row[5]?.toString(),
          'auth_status': row[6],
          'is_archived': row[7],
          'otp': row[8],
          'otp_expiry': row[9]?.toString(),
          'profile_image': row[10],
          'mobile_user_id': row[11],
          'officer_id': row[12],
          'officer_user_id': row[13],
          'officer_name': row[14],
          'position_id': row[15],
          'position_name': row[16],
          'office_name': row[17],
          'officer_is_archived': row[18],
          'admin_approval_status': row[19],
        }));
      }
      print('Fetched pending users for page $page: ${userList.length}');
      return userList;
    } catch (e) {
      print('Error fetching pending users: $e');
      throw Exception('Failed to fetch pending users.');
    }
  }

  Future<User?> getUserInformation({
    String? id,
  }) async {
    var baseQuery = '''
          SELECT 
            u.id AS user_id,
            u.name,
            u.email,
            u.password,
            to_char(u.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS created_at,
            to_char(u.updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS updated_at,
            u.auth_status,
            u.is_archived,
            u.otp,
            to_char(u.otp_expiry, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS otp_expiry,
            u.profile_image,
            s.id AS supp_dept_emp_id,
            s.role,
            m.id AS mobile_user_id,
            ofc.id AS officer_id,
            ofr.user_id AS officer_user_id,
            ofr.name AS officer_name,
            pos.id AS position_id,
            pos.position_name AS position_name,
            ofc.name AS office_name,
            ofr.is_archived AS officer_is_archived,
            m.admin_approval_status 
          FROM
            Users u
          LEFT JOIN
            SupplyDepartmentEmployees s ON u.id = s.user_id
          LEFT JOIN
            MobileUsers m ON u.id = m.user_id
          LEFT JOIN
            Officers ofr ON u.id = ofr.user_id
          LEFT JOIN
            Positions pos ON ofr.position_id = pos.id
          LEFT JOIN
            Offices ofc ON pos.office_id = ofc.id
          WHERE
          ''';

    final Map<String, dynamic> parameters = {};

    if (id != null) {
      baseQuery += 'u.id = @id';
      parameters['id'] = id;
    }

    final result = await _conn.execute(
      Sql.named(
        baseQuery,
      ),
      parameters: parameters,
    );

    final row = result.first;
    final isSupplyDepartmentEmployee = row[11] != null;
    final isMobileUser = row[13] != null;

    if (isSupplyDepartmentEmployee) {
      //print('returning supp emp');
      return SupplyDepartmentEmployee.fromJson({
        'user_id': row[0],
        'name': row[1],
        'email': row[2],
        'password': row[3],
        'created_at': row[4].toString(),
        'updated_at': row[5]?.toString(),
        'auth_status': row[6],
        'is_archived': row[7],
        'otp': row[8],
        'otp_expiry': row[9]?.toString(),
        'profile_image': row[10],
        'supp_dept_emp_id': row[11],
        'role': row[12],
      });
    }

    if (isMobileUser) {
      //print('returning mobile user: ${row[13]}');
      //if (row[21] == AdminApprovalStatus.accepted)
      final mobileUserMap = {
        'user_id': row[0],
        'name': row[1],
        'email': row[2],
        'password': row[3],
        'created_at': row[4].toString(),
        'updated_at': row[5]?.toString(),
        'auth_status': row[6],
        'is_archived': row[7],
        'otp': row[8],
        'otp_expiry': row[9]?.toString(),
        'profile_image': row[10],
        'mobile_user_id': row[13],
        'officer_id': row[14],
        'officer_user_id': row[15],
        'officer_name': row[16],
        'position_id': row[17],
        'position_name': row[18],
        'office_name': row[19],
        'officer_is_archived': row[20],
        'admin_approval_status': row[21],
      };

      print('mu: $mobileUserMap');
      return MobileUser.fromJson({
        'user_id': row[0],
        'name': row[1],
        'email': row[2],
        'password': row[3],
        'created_at': row[4].toString(),
        'updated_at': row[5]?.toString(),
        'auth_status': row[6],
        'is_archived': row[7],
        'otp': row[8],
        'otp_expiry': row[9]?.toString(),
        'profile_image': row[10],
        'mobile_user_id': row[13],
        'officer_id': row[14],
        'officer_user_id': row[15],
        'officer_name': row[16],
        'position_id': row[17],
        'position_name': row[18],
        'office_name': row[19],
        'officer_is_archived': row[20],
        'admin_approval_status': row[21],
      });
    }
    return null;
  }

  Future<bool> checkUserIfExist({
    String? userId,
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

  Future<String> _generateUniqueBaseUserId() async {
    const length = 12;
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    while (true) {
      /// Generate random alphanumeric id of the specified length
      final userId = String.fromCharCodes(
        Iterable.generate(length,
            (_) => characters.codeUnitAt(random.nextInt(characters.length))),
      );

      /// Check if the gen id already exists in users table
      final result = await _conn.execute(
        Sql.named(
          '''
          SELECT COUNT(id) FROM Users WHERE id = @id;
          ''',
        ),
        parameters: {
          'id': userId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return userId;
      }
    }
  }

  Future<String> _generateUniqueDesktopUserId() async {
    const length = 12;
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    while (true) {
      /// Generate random alphanumeric id of the specified length
      final supplyDeptId = String.fromCharCodes(
        Iterable.generate(length,
            (_) => characters.codeUnitAt(random.nextInt(characters.length))),
      );

      /// Check if the gen id already exists in users table
      final result = await _conn.execute(
        Sql.named(
          '''
          SELECT COUNT(id) FROM SupplyDepartmentEmployees WHERE id = @id;
          ''',
        ),
        parameters: {
          'id': supplyDeptId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return supplyDeptId;
      }
    }
  }

  Future<String> _generateUniqueMobileUserId() async {
    const length = 12;
    const characters =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    while (true) {
      /// Generate random alphanumeric id of the specified length
      final mobileUserId = String.fromCharCodes(
        Iterable.generate(length,
            (_) => characters.codeUnitAt(random.nextInt(characters.length))),
      );

      /// Check if the gen id already exists in users table
      final result = await _conn.execute(
        Sql.named(
          '''
          SELECT COUNT(id) FROM MobileUsers WHERE id = @id;
          ''',
        ),
        parameters: {
          'id': mobileUserId,
        },
      );

      final count = result.first[0] as int;

      if (count == 0) {
        return mobileUserId;
      }
    }
  }

  // Future<User?> createDesktopUser({
  //   required String name,
  //   required String email,
  //   required String password,
  //   required DateTime createdAt,
  //   Role? role,
  // }) async {
  //   try {
  //     final hashedPassword = password.hashValue;
  //
  //     /// Invoke method _generateUniqueUserId and assign its return value to userId
  //     final userId = await _generateUniqueUserId();
  //
  //     final userResult = await _conn.execute(
  //       Sql.named(
  //         '''
  //         INSERT INTO Users (id, name, email, password, created_at)
  //         VALUES
  //         (@id, @name, @email, @password, @created_at);
  //         ''',
  //       ),
  //       parameters: {
  //         'id': userId,
  //         'name': name,
  //         'email': email,
  //         'password': hashedPassword,
  //         'created_at': createdAt,
  //       },
  //     );
  //
  //     final concreteUserId = await _generateUniqueUserId();
  //
  //     // if role is equal to null, insert into mobile user table.
  //     // Otherwise, insert to supply dept. table
  //     if (role == null) {
  //       final mobileUserResult = await _conn.execute(
  //         Sql.named(
  //           '''
  //           INSERT INTO MobileUsers (id, user_id) VALUES (@id, @user_id);
  //           ''',
  //         ),
  //         parameters: {
  //           'id': concreteUserId,
  //           'user_id': userId,
  //         },
  //       );
  //
  //       // if (mobileUserResult.isEmpty) {
  //       //   throw Exception(
  //       //       'Failed to insert a new record to mobile user table.');
  //       // }
  //
  //       return MobileUser(
  //         id: userId,
  //         name: name,
  //         email: email,
  //         password: hashedPassword,
  //         createdAt: createdAt,
  //         mobileUserId: concreteUserId,
  //         officer: null,
  //       );
  //     } else {
  //       final supplyDepartmentEmployeeResult = await _conn.execute(
  //         Sql.named(
  //           '''
  //           INSERT INTO SupplyDepartmentEmployees (id, user_id, role)
  //           VALUES
  //           (@id, @user_id, @role);
  //           ''',
  //         ),
  //         parameters: {
  //           'id': concreteUserId,
  //           'user_id': userId,
  //           'role': role.toString(),
  //         },
  //       );
  //
  //       // if (supplyDepartmentEmployeeResult.isEmpty) {
  //       //   throw Exception(
  //       //       'Failed to insert a new record to supply department employee table.');
  //       // }
  //
  //       return SupplyDepartmentEmployee(
  //         id: userId,
  //         name: name,
  //         email: email,
  //         password: hashedPassword,
  //         createdAt: createdAt,
  //         employeeId: concreteUserId,
  //         role: role,
  //       );
  //     }
  //   } catch (e) {
  //     if (e
  //         .toString()
  //         .contains('duplicate key value violates unique constraint')) {
  //       throw Exception('Email already exists.');
  //     }
  //     print('Error creating user: $e');
  //     throw Exception('Database connection error.');
  //   }
  // }

  Future<String?> createBaseEntityUser({
    required String name,
    required String email,
    required String password,
    required DateTime createdAt,
  }) async {
    try {
      final hashedPassword = password.hashValue;

      /// Invoke method _generateUniqueUserId and assign its return value to userId
      final userId = await _generateUniqueBaseUserId();

      await _conn.execute(
        Sql.named(
          '''
          INSERT INTO Users (id, name, email, password, created_at)
          VALUES 
          (@id, @name, @email, @password, @created_at);
          ''',
        ),
        parameters: {
          'id': userId,
          'name': name,
          'email': email,
          'password': hashedPassword,
          'created_at': createdAt,
        },
      );

      return userId;
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

  Future<String?> createDesktopUser({
    required String baseUserEntityId,
    Role? role,
  }) async {
    try {
      final concreteUserId = await _generateUniqueDesktopUserId();

      await _conn.execute(
        Sql.named(
          '''
            INSERT INTO SupplyDepartmentEmployees (id, user_id, role)
            VALUES 
            (@id, @user_id, @role);
            ''',
        ),
        parameters: {
          'id': concreteUserId,
          'user_id': baseUserEntityId,
          'role': role.toString(),
        },
      );

      return baseUserEntityId;
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Database connection error.');
    }
  }

  Future<String?> createMobileUser({
    required String baseUserEntityId,
  }) async {
    try {
      final concreteUserId = await _generateUniqueMobileUserId();

      await _conn.execute(
        Sql.named(
          '''
            INSERT INTO MobileUsers (id, user_id) VALUES (@id, @user_id);
            ''',
        ),
        parameters: {
          'id': concreteUserId,
          'user_id': baseUserEntityId,
        },
      );

      return baseUserEntityId;
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Database connection error.');
    }
  }

  Future<bool> updateUserInformation({
    required String id,
    String? name,
    String? email,
    String? password,
    Role? role,
    String? profileImage,
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

    if (profileImage != null) {
      setClauses.add('profile_image = @profile_image');
      parameters['profile_image'] = profileImage;
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
    required String id,
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

  Future<bool?> updateUserArchiveStatus({
    required String id,
    required bool isArchived,
  }) async {
    try {
      // Check if the user is associated with an officer
      final checkIfOfficerExist = await _conn.execute(
        Sql.named('''
      SELECT id FROM Officers
      WHERE user_id = @id;
      '''),
        parameters: {
          'id': id,
        },
      );

      await _conn.execute(
        Sql.named(
          '''
        UPDATE Users
        SET is_archived = @is_archived
        WHERE id = @id;
        ''',
        ),
        parameters: {
          'id': id,
          'is_archived': isArchived,
        },
      );

      if (checkIfOfficerExist.isNotEmpty) {
        final officerId = checkIfOfficerExist.first[0] as String;

        await _conn.execute(
          Sql.named('''
        UPDATE Officers
        SET is_archived = @is_archived
        WHERE id = @id;
       '''),
          parameters: {
            'id': officerId,
            'is_archived': isArchived,
          },
        );
      }

      return true;
    } catch (e) {
      print('Error updating officer archive status: $e');
      return false;
    }
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
    try {
      /// Convert the parameterized password to hash
      final hashedPassword = password.hashValue;

      final result = await _conn.execute(
        Sql.named(
          '''
          SELECT 
            u.id AS user_id,
            u.name,
            u.email,
            u.password,
            to_char(u.created_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS created_at,
            to_char(u.updated_at, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS updated_at,
            u.auth_status,
            u.is_archived,
            u.otp,
            to_char(u.otp_expiry, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS otp_expiry,
            u.profile_image,
            s.id AS supp_dept_emp_id,
            s.role,
            m.id AS mobile_user_id,
            ofc.id AS officer_id,
            ofr.user_id AS officer_user_id,
            ofr.name AS officer_name,
            pos.id AS position_id,
            pos.position_name AS position_name,
            ofc.name AS office_name,
            ofr.is_archived AS officer_is_archived,
            m.admin_approval_status 
          FROM
            Users u
          LEFT JOIN
            SupplyDepartmentEmployees s ON u.id = s.user_id
          LEFT JOIN
            MobileUsers m ON u.id = m.user_id
          LEFT JOIN
            Officers ofr ON u.id = ofr.user_id
          LEFT JOIN
            Positions pos ON ofr.position_id = pos.id
          LEFT JOIN
            Offices ofc ON pos.office_id = ofc.id
          WHERE
            u.email = @email AND u.password = @password;
          ''',
        ),
        parameters: {
          'email': email,
          'password': hashedPassword,
        },
      );

      if (result.isEmpty) {
        return null;
      }

      final row = result.first;
      final isSupplyDepartmentEmployee = row[11] != null;
      final isMobileUser = row[13] != null;

      if (isSupplyDepartmentEmployee) {
        print('returning supp emp');
        return SupplyDepartmentEmployee.fromJson({
          'user_id': row[0],
          'name': row[1],
          'email': row[2],
          'password': row[3],
          'created_at': row[4].toString(),
          'updated_at': row[5]?.toString(),
          'auth_status': row[6],
          'is_archived': row[7],
          'otp': row[8],
          'otp_expiry': row[9]?.toString(),
          'profile_image': row[10],
          'supp_dept_emp_id': row[11],
          'role': row[12],
        });
      }

      if (isMobileUser) {
        print('returning mobile user: ${row[13]}');
        final mobileUserMap = {
          'user_id': row[0],
          'name': row[1],
          'email': row[2],
          'password': row[3],
          'created_at': row[4].toString(),
          'updated_at': row[5]?.toString(),
          'auth_status': row[6],
          'is_archived': row[7],
          'otp': row[8],
          'otp_expiry': row[9]?.toString(),
          'profile_image': row[10],
          'mobile_user_id': row[13],
          'officer_id': row[14],
          'officer_user_id': row[15],
          'officer_name': row[16],
          'position_id': row[17],
          'position_name': row[18],
          'office_name': row[19],
          'officer_is_archived': row[20],
          'admin_approval_status': row[21],
        };

        print('mu: $mobileUserMap');
        return MobileUser.fromJson({
          'user_id': row[0],
          'name': row[1],
          'email': row[2],
          'password': row[3],
          'created_at': row[4].toString(),
          'updated_at': row[5]?.toString(),
          'auth_status': row[6],
          'is_archived': row[7],
          'otp': row[8],
          'otp_expiry': row[9]?.toString(),
          'profile_image': row[10],
          'mobile_user_id': row[13],
          'officer_id': row[14],
          'officer_user_id': row[15],
          'officer_name': row[16],
          'position_id': row[17],
          'position_name': row[18],
          'office_name': row[19],
          'officer_is_archived': row[20],
          'admin_approval_status': row[21],
        });
      }
      return null;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<SupplyDepartmentEmployee?> getCurrentSupplyCustodian() async {
    final result = await _conn.execute(
      Sql.named(
        '''
        SELECT
          u.*,
          supp_dept_emp.id,
          supp_dept_emp.role
        FROM
          Users u
        JOIN
          SupplyDepartmentEmployees supp_dept_emp
        ON
          u.id = supp_dept_emp.user_id
        WHERE
          role = @role
        LIMIT 1;
        ''',
      ),
      parameters: {
        'role': Role.supplyCustodian.toString(),
      },
    );

    if (result.isNotEmpty) {
      final row = result.first;
      return SupplyDepartmentEmployee.fromJson({
        'user_id': row[0],
        'name': row[1],
        'email': row[2],
        'password': row[3],
        'created_at': row[4].toString(),
        'updated_at': row[5]?.toString(),
        'auth_status': row[6],
        'is_archived': row[7],
        'otp': row[8],
        'otp_expiry': row[9]?.toString(),
        'profile_image': row[10],
        'supp_dept_emp_id': row[11],
        'role': row[12],
      });
    }

    return null;
  }
}
