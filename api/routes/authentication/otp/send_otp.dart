import 'dart:io';

import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = UserRepository(connection);

  return switch (context.request.method) {
    HttpMethod.post => _sendEmailOtp(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

/// mostly used to re-send OTP
Future<Response> _sendEmailOtp(
    RequestContext context, UserRepository repository) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;
    final email = json['email'] as String;

    if (email.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'error': 'Email is required.',
        },
      );
    }

    await repository.sendEmailOtp(email);

    return Response.json(
      body: {
        'message': 'An OTP was sent in your email: $email',
      },
    );
  } catch (e) {
    print(e);
    return Response.json(
      statusCode: 500,
      body: {
        'message': e.toString().contains('User email is not registered.')
            ? 'User email is not registered.'
            : e.toString().contains(
                    'Please wait for 10 minutes before requesting a new OTP.')
                ? 'Please wait for 10 minutes before requesting a new OTP.'
                : 'Failed to send OTP. Please try again later.'
      },
    );
  }
}
