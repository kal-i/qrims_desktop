import 'dart:io';

import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:api/src/user/models/user.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await context.read<Connection>();
  final repository = UserRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getUsers(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getUsers(
  RequestContext context,
  UserRepository repository,
) async {
  try {
    final queryParams = context.request.uri.queryParameters;
    final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
    final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
    final searchQuery = queryParams['search_query']?.trim() ?? '';
    final sortBy = queryParams['sort_by']?.trim() ?? 'created_at';
    final sortAscending =
        bool.tryParse(queryParams['sort_ascending'] ?? 'false') ?? false;
    final role = queryParams['role']?.trim() ?? '';
    final statusString = queryParams['status'];

    final status = statusString != null
        ? AuthStatus.values.firstWhere(
            (authStatus) =>
                authStatus.toString().split('.').last == statusString,
          )
        : null;
    final isArchived = bool.tryParse(queryParams['is_archived'] ?? 'false') ?? false;

    // if search query is not empty or user type, use the userJson.lenght otherwise, totalusercount
    // done for search but I'll need a way to count of the thing that matches the query without the intervention of limit
    // for that I can create a separate method for filtering - searchQuery, sortBy, filter

    final userList = await repository.getUsers(
      page: page,
      pageSize: pageSize,
      searchQuery: searchQuery,
      sortBy: sortBy,
      sortAscending: sortAscending,
      role: role,
      status: status,
      isArchived: isArchived,
    );

    final filteredUserCount = await repository.getUsersFilteredCount(
      searchQuery: searchQuery,
      role: role,
      status: status,
      isArchived: isArchived,
    );

    if (userList == null) {
      print('no users');
      return Response.json(
        body: [],
      );
    }

    final userJsonList = userList
        .map((user) => user is SupplyDepartmentEmployee
            ? user.toJson()
            : user is MobileUser
                ? user.toJson()
                : null)
        .where((userJson) => userJson != null)
        .toList();

    print('fetch users: $userJsonList');

    return Response.json(
      body: {
        'totalUserCount': filteredUserCount,
        'users': userJsonList,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Error processing the get users request.',
      },
    );
  }
}

// TODO: create specific routes for each
// import 'dart:io';
//
// import 'package:api/src/user/user.dart';
// import 'package:api/src/user/archive_user_repository.dart';
// import 'package:dart_frog/dart_frog.dart';
// import 'package:postgres/postgres.dart';
//
// Future<Response> onRequest(
//     RequestContext context,
//     String id,
//     ) async {
//   final connection = await context.read<Connection>();
//   final repository = UserRepository(connection);
//
//   return switch (context.request.method) {
//     HttpMethod.get => _getUserInformation(id, repository),
//   //HttpMethod.put => _updateUserAuthenticationStatus(id, repository, context), // put for major update
//     HttpMethod.patch => _updateUserAuthenticationStatus(
//         id, repository, context), // patch for partial update
//     _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
//   };
// }
//
// Future<Response> _getUserInformation(
//     String id,
//     UserRepository repository,
//     ) async {
//   final user = await repository.getUserInformation(id: int.parse(id));
//
//   if (user != null) {
//     return Response.json(
//       body: {
//         'user': user is SupplyDepartmentEmployee
//             ? user.toJson()
//             : user is MobileUser
//             ? user.toJson()
//             : null,
//       },
//     );
//   }
//
//   return Response.json(
//     statusCode: 400,
//     body: {'message': 'User not found.'},
//   );
// }
//
// Future<Response> _updateUserAuthenticationStatus(
//     String id,
//     UserRepository repository,
//     RequestContext context,
//     ) async {
//   final queryParams = context.request.uri.queryParameters;
//   final json = await context.request.json() as Map<String, dynamic>;
//
//   //final id = queryParams['user_id'] as int;
//   final authStatus = json['auth_status'] != null
//       ? AuthStatus.values.firstWhere(
//           (e) => e.toString() == 'AuthStatus.${json['auth_status']}')
//       : null;
//
//   print(authStatus);
//
//   final result = await repository.updateUserAuthenticationStatus(
//     id: int.parse(id),
//     authStatus: authStatus!,
//   );
//
//   if (result == true) {
//     return Response.json(statusCode: 200, body: {
//       'message': '$id: $authStatus',
//     });
//   }
//
//   return Response.json(
//     statusCode: HttpStatus.internalServerError,
//     body: {
//       'message': 'Something went wrong while updating user\'s auth status'
//     },
//   );
// }
