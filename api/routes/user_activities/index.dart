import 'dart:io';

import 'package:api/src/user_activity/user_activity_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final userActivityRepository = UserActivityRepository(connection);

  return switch (context.request.method) {
    HttpMethod.get => _getUserActivities(context, userActivityRepository),
    _ => Future.value(Response.json(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _getUserActivities(
  RequestContext context,
  UserActivityRepository userActivityRepository,
) async {
  final queryParams = await context.request.uri.queryParameters;
  final userId = queryParams['user_id'];
  final page = int.tryParse(queryParams['page'] ?? '1') ?? 1;
  final pageSize = int.tryParse(queryParams['page_size'] ?? '10') ?? 10;

  if (userId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {
        'message': 'User ID is required.',
      },
    );
  }

  try {
    final parsedUserId = int.parse(userId);

    final userActivities = await userActivityRepository.getUserActivities(
      id: parsedUserId,
      page: page,
      pageSize: pageSize,
    );

    final userActivitiesJsonList =
    userActivities.map((userActivity) => userActivity.toJson()).toList();

    print('total count: ${userActivitiesJsonList.length}');
    return Response.json(
      statusCode: 200,
      body: {
        'user_activities': userActivitiesJsonList,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Failed to fetch user activities: ${e.toString()}',
      },
    );
  }
}
