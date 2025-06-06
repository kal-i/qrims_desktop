import 'dart:io';

import 'package:api/src/organization_management/repositories/office_repository.dart';
import 'package:api/src/organization_management/repositories/officer_repository.dart';
import 'package:api/src/organization_management/repositories/position_repository.dart';
import 'package:api/src/session/session_repository.dart';
import 'package:api/src/user/models/user.dart';
import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final officeRepository = OfficeRepository(connection);
  final positionRepository = PositionRepository(connection);
  final officerRepository = OfficerRepository(connection);
  final userRepository = UserRepository(connection);
  final sessionRepository = SessionRepository(connection);

  return switch (context.request.method) {
    HttpMethod.post => _createUser(
        context,
        officeRepository,
        positionRepository,
        officerRepository,
        userRepository,
      ),
    HttpMethod.get =>
      _authenticateUser(context, userRepository, sessionRepository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _createUser(
  RequestContext context,
  OfficeRepository officeRepository,
  PositionRepository positionRepository,
  OfficerRepository officerRepository,
  UserRepository userRepository,
) async {
  try {
    /// Extract whatever is passed on the body and convert it to map
    final json = await context.request.json() as Map<String, dynamic>;

    print(json);

    /// Extract each value from the map
    final name = json['name'] as String;
    final email = json['email'] as String;
    final password = json['password'] as String;
    final createdAt = DateTime.now();
    final role = json['role'] != null
        ? Role.values.firstWhere((e) => e.toString() == 'Role.${json['role']}')
        : null;
    final officeName = json['office_name'] as String?;
    final positionName = json['position_name'] as String?;

    String? concreteUserId;

    final baseEntityUserId = await userRepository.createBaseEntityUser(
      name: name,
      email: email,
      password: password,
      createdAt: createdAt,
    );

    if (role != null) {
      print('desktop user is being created');
      concreteUserId = await userRepository.createDesktopUser(
        baseUserEntityId: baseEntityUserId!,
        role: role,
      );

      print('desktop user id: $concreteUserId');
    }

    if ((officeName != null && officeName.isNotEmpty) &&
        (positionName != null && positionName.isNotEmpty)) {
      print('mobile user is being created');
      final officeId = await officeRepository.checkOfficeIfExist(
        officeName: officeName,
      );
      print('ofc id: $officeId');

      final positionId = await positionRepository.checkIfPositionExist(
        officeId: officeId,
        positionName: positionName,
      );
      print('pos id: $positionId');

      // reg user 1st b4 the officer to avoid data inconsistency or redundancy
      concreteUserId = await userRepository.createMobileUser(
        baseUserEntityId: baseEntityUserId!,
      );
      print('mobile user id: $concreteUserId');

      // the problem is from the logic I've put that if the name exist, it will bind that to that specific officer
      final officerId =
          // await officerRepository.checkOfficerIfExist(
          // name: name,
          // positionId: positionId,
          // ) ??
          await officerRepository.registerOfficer(
        userId: baseEntityUserId,
        name: name,
        positionId: positionId,
      );
      print('registered officer: $officerId'); // reached
    }

    if ((baseEntityUserId == null && baseEntityUserId!.isEmpty) &&
        (concreteUserId == null && concreteUserId!.isEmpty)) {
      return Response.json(
        statusCode: 500,
        body: {
          'message': 'Error creating user.',
        },
      );
    }

    final user = await userRepository.getUserInformation(
      id: baseEntityUserId,
    );

    Map<String, dynamic> userJson;
    if (user is SupplyDepartmentEmployee) {
      userJson = user.toJson();
    } else if (user is MobileUser) {
      userJson = user.toJson();
    } else {
      throw Exception('Unsupported user type.');
    }

    return Response.json(
      body: {
        'message': 'A user was added.',
        'user': userJson,
      },
    );
  } catch (e) {
    print('triggered res: $e');

    return Response.json(
      statusCode: 500,
      body: {
        'message': e.toString().contains('Email already exists.')
            ? 'Email already exists.'
            : 'Error processing the create user request. $e',
      },
    );
  }
}

/// Equivalent to logging in in the client side
/// we're getting a token by passing a user cred
Future<Response> _authenticateUser(
  RequestContext context,
  UserRepository userRepository,
  SessionRepository sessionRepository,
) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;
    final email = json['email'] as String;
    final password = json['password'] as String;

    final user = await userRepository.checkUserCredentialFromDatabase(
      email: email,
      password: password,
    );

    if (user == null) {
      return Response.json(statusCode: HttpStatus.unauthorized);
    } else {
      final userId = user is SupplyDepartmentEmployee
          ? user.id
          : user is MobileUser
              ? user.id
              : null;

      final session = await sessionRepository.createSession(userId!);
      return Response.json(
        body: {
          'token': session.token,
        },
      );
    }
  } catch (e) {
    return Response.json(
      body: {
        'message': e,
      },
    );
  }
}
