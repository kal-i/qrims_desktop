import 'dart:io';

import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:api/src/user/models/user.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await context.read<Connection>();
  final repository = UserRepository(connection);

  return switch (context.request.method) {
    //HttpMethod.get => _getUsers(context, repository),
    //HttpMethod.post => _createUser(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

// Future<Response> _getUsers(
//   RequestContext context,
//   UserRepository repository,
// ) async {
//   try {
//     final queryParams = context.request.uri.queryParameters;
//     final page = int.tryParse(queryParams['page'] ?? '1');
//     final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;
//     final searchQuery = queryParams['search_query']?.toLowerCase();
//
//     final userList = await repository.getUsers(
//       searchQuery: searchQuery,
//       page: page!,
//       pageSize: pageSize,
//     );
//
//     if (userList == null) {
//       return Response.json(
//         body: [],
//       );
//     }
//
//     final userJsonList = userList
//         .map((user) => user is SupplyDepartmentEmployee
//             ? user.toJson()
//             : user is MobileUser
//                 ? user.toJson()
//                 : null)
//         .where((userJson) => userJson != null)
//         .toList();
//
//     return Response.json(
//       body: userJsonList,
//     );
//   } catch (e) {
//     return Response.json(
//       statusCode: HttpStatus.internalServerError,
//       body: {'message': 'Error processing the get users request.'},
//     );
//   }
// }

// Future<Response> _createUser(
//   RequestContext context,
//   UserRepository repository,
// ) async {
//   try {
//     /// Extract whatever is passed on the body and convert it to map
//     final json = await context.request.json() as Map<String, dynamic>;
//     /// Extract each value from the map
//     final name = json['name'] as String;
//     final email = json['email'] as String;
//     final password = json['password'] as String;
//     final createdAt = DateTime.now();
//     final role = json['role'] != null
//         ? Role.values.firstWhere((e) => e.toString() == 'Role.${json['role']}')
//         : null;
//
//     final user = await repository.createDesktopUser(
//       name: name,
//       email: email,
//       password: password,
//       createdAt: createdAt,
//       role: role,
//     );
//
//     if (user == null) {
//       return Response.json(
//         statusCode: 500,
//         body: {
//           'message': 'Error creating user',
//         },
//       );
//     }
//
//     Map<String, dynamic> userJson;
//     if (user is SupplyDepartmentEmployee) {
//       userJson = user.toJson();
//     } else if (user is MobileUser) {
//       userJson = user.toJson();
//     } else {
//       throw Exception('Unsupported user type.');
//     }
//
//     return Response.json(
//       body: {
//         'message': 'A user was added.',
//         'user': userJson,
//       },
//     );
//   } catch (e) {
//     print('Error in _createUser: $e');
//     return Response.json(
//       statusCode: 500,
//       body: {
//         'message': 'Error processing the create user request',
//       },
//     );
//   }
// }
