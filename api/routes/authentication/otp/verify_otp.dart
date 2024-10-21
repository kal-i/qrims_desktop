import 'dart:io';

import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

// TODO: work on verifying otp - done
Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final repository = UserRepository(connection);

  return switch (context.request.method) {
    HttpMethod.post => _verifyOtp(context, repository),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _verifyOtp(RequestContext context, UserRepository repository) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;
    final email = json['email'] as String;
    final otp = json['otp'] as String;

    String message = '';

    if (email.isEmpty && otp.isEmpty) {
      message = 'Email and OTP are required.';
    } else if (email.isEmpty) {
      message = 'Email is required.';
    } else if (otp.isEmpty) {
      message = 'OTP is required.';
    }

    if (message.isNotEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'message': message,
        },
      );
    }

    final isVerified = await repository.verifyOtp(email, otp);

    if (isVerified) {
      return Response.json(
        statusCode: 200,
        body: {
          'message': 'OTP verified successfully.',
        },
      );
    } else {
      return Response.json(
        statusCode: 400,
        body: {
          'message': 'Invalid OTP or OTP expired.',
        },
      );
    }
  } catch (e) {
    print(e);
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'message': 'Failed to verify the OTP.',
      }
    );
  }
}