// import 'package:dart_frog/dart_frog.dart';
// import 'package:postgres/postgres.dart';
// import 'package:dotenv/dotenv.dart';
//
// // basically, here we are injecting a connection before and after a request using a middleware
// Handler middleware(Handler handler) {
//   return (RequestContext context) async {
//     final env= DotEnv(includePlatformEnvironment: true)..load();
//
//     final connection = await Connection.open(
//       Endpoint(
//         host: env['HOST']!,
//         database: env['DATABASE_NAME']!,
//         username: env['USERNAME'],
//         password: env['PASSWORD'],
//       ),
//       settings: ConnectionSettings(sslMode: SslMode.disable,),
//     );
//
//     print('Connection established.');
//
//     // inject the connection before a request
//     final response = await handler.use(requestLogger())
//         .use(provider<Connection>((_) => connection))
//         .call(context);
//
//     // close the connection after a request
//     await connection.close();
//
//     return response;
//   };
// }

import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';
import 'dart:io';

Handler middleware(Handler handler) {
  return (RequestContext context) async {
    final env = DotEnv(includePlatformEnvironment: true)..load();

    Connection? connection;

    try {
      connection = await Connection.open(
        Endpoint(
          host: env['HOST']!,
          database: env['DATABASE_NAME']!,
          username: env['USERNAME'],
          password: env['PASSWORD'],
        ),
        settings: ConnectionSettings(
          sslMode: SslMode.disable,
        ),
      );

      print('Database connection established.');

      // Inject the connection into the request context
      final response = await handler
          .use(requestLogger())
          .use(provider<Connection>((_) => connection!))
          .call(context);

      return response;
    } on SocketException catch (e) {
      print('Failed to connect to the database: $e');
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: 'Database connection failed. Please try again later.',
      );
    } catch (e) {
      print('An unexpected error occurred: $e');
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: 'An unexpected error occurred. Please try again later.',
      );
    } finally {
      // Ensure the connection is closed even if an error occurs
      if (connection != null) {
        await connection.close();
        print('Database connection closed.');
      }
    }
  };
}
