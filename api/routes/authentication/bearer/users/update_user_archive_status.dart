import 'dart:io';

import 'package:api/src/session/session_repository.dart';
import 'package:api/src/user/models/user.dart';
import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final userRepository = UserRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.patch => _updateUserArchiveStatus(context, userRepository, sessionRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _updateUserArchiveStatus(
  RequestContext context,
  UserRepository userRepository,
    SessionRepository sessionRepository,
) async {
  try {
    final headers = context.request.headers;
    final queryParams = context.request.uri.queryParameters;
    final json = await context.request.json() as Map<String, dynamic>;

    // get user (the one performing this ope) through the bearer token passed
    // based on that, then we will check if they are authorized to perform the ope
    // if it is, record as well in act db
    final bearerToken = headers['Authorization']?.substring(7) as String;
    final targetUserId = queryParams['user_id'] as String;
    final isArchived = json['is_archived'] as bool;

    final session = await sessionRepository.sessionFromToken(bearerToken);
    final responsibleUserId = session!.userId;

    print('bearer token: $bearerToken');
    print(isArchived);

    /// only admin role is authorized to perform this ope
    final responsibleUser = await userRepository.getUserInformation(
      id: responsibleUserId,
    );

    if (responsibleUser == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {
          'message': 'User not found.',
        },
      );
    }

    print('user data: $responsibleUser');

    if (responsibleUser is SupplyDepartmentEmployee) {
      print('user role: ${responsibleUser.role}');
      if (responsibleUser.role != Role.admin) {
        return Response.json(
          statusCode: HttpStatus.forbidden,
          body: {
            'message':
            'Only admin role is authorized to perform this operation.',
          },
        );
      }

      final result = await userRepository.updateUserArchiveStatus(
        id: targetUserId,
        isArchived: isArchived,
      );

      if (result == true) {
        // log user activity
        // await userActivityRepository.logUserActivity(
        //   userId: responsibleUser.id,
        //   description: 'Authentication status of user $targetUserId updated to ${authStatus.toString().split('.').last}.',
        //   actionType: Action.update,
        //   targetUserId: targetUserId,
        // );

        return Response.json(
          statusCode: 200,
          body: {
            'message':
            'User $targetUserId archive status updated to $isArchived.',
          },
        );
      } else {
        return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {
            'message': 'Failed to update user authentication status.',
          },
        );
      }
    } else {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: {
          'message':
          'Only a supply department employee with an admin role can perform this operation.'
        },
      );
    }
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'An error occurred: ${e.toString()}',
      },
    );
  }
}
