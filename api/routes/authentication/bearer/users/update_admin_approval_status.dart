import 'dart:io';

import 'package:api/src/session/session_repository.dart';
import 'package:api/src/user/models/user.dart';
import 'package:api/src/user_activity/user_activity.dart';
import 'package:api/src/user/repository/user_repository.dart';
import 'package:api/src/user_activity/user_activity_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final userRepository = UserRepository(connection);
  final sessionRepository = SessionRepository(connection);
  final userActivityRepository = UserActivityRepository(connection);

  return switch (context.request.method) {
    HttpMethod.patch => _updateAdminApprovalStatus(
        userRepository, sessionRepository, userActivityRepository, context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _updateAdminApprovalStatus(
    UserRepository userRepository,
    SessionRepository sessionRepository,
    UserActivityRepository userActivityRepository,
    RequestContext context,
    ) async {
  try {
    final headers = context.request.headers;
    final queryParams = context.request.uri.queryParameters;
    final json = await context.request.json() as Map<String, dynamic>;

    // get user (the one performing this ope) through the bearer token passed
    // based on that, then we will check if they are authorized to perform the ope
    // if it is, record as well in act db
    final bearerToken = headers['Authorization']?.substring(7) as String;
    final session = await sessionRepository.sessionFromToken(bearerToken);
    final responsibleUserId = session!.userId;
    final responsibleUser = await userRepository.getUserInformation(
      id: responsibleUserId,
    );


    final targetUserId = queryParams['user_id'] as String;
    final targetUser = await userRepository.getUserInformation(id: targetUserId);

    final adminApprovalStatus = json['admin_approval_status'] != null
        ? AdminApprovalStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['admin_approval_status'])
        : null;

    if (responsibleUser == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {
          'message': 'User not found.',
        },
      );
    }

    /// only admin role is authorized to perform this ope
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

      final result = await userRepository.updateAdminApprovalStatus(
        id: targetUserId,
        adminApprovalStatus: adminApprovalStatus!,
      );

      print(result);

      if (result == true) {
        if (adminApprovalStatus == AdminApprovalStatus.accepted) {
          await userRepository.sendAdminApprovalEmail(targetUser!.email);
        }
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
            'User $targetUserId admin approval status updated to $adminApprovalStatus.',
          },
        );
      } else {
        return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {
            'message': 'Failed to update user\'s admin approval status.',
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
    print('err: $e');
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'An error occurred: ${e.toString()}',
      },
    );
  }
}
