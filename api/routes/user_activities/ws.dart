import 'dart:io';

import 'package:api/src/user_activity/user_activity_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final userActivityRepository =
      UserActivityRepository(connection);
  final request = await context.request;


  // check if req. is for ws conn.
  if (request.headers[HttpHeaders.upgradeHeader]?.contains('websocket') ?? false) {
    final webSocket =
        await WebSocketTransformer.upgrade(request as HttpRequest); // upgrade to ws

    _webSocketClients.add(webSocket); // add new client to the set

    webSocket.listen(
      (message) {
        print('Received message: $message');
      },
      onDone: () {
        _webSocketClients.remove(webSocket); // remove client when conn. closed
      },
      onError: (err) {
        print('WS err: $err');
        _webSocketClients.remove(webSocket); // remove client on err
      },
    );

    return Response(
      body: 'WS connected',
      headers: {
        HttpHeaders.contentTypeHeader: 'text/plain',
      },
    );
  }

  return Response.json(
    statusCode: HttpStatus.methodNotAllowed,
    body: {
      'message': 'WS conn. required.',
    },
  );
}

final _webSocketClients = <WebSocket>{}; // set to keep track of conn. ws client
