import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

// A set to keep track of connected WebSocket clients
final _clients = <WebSocketChannel>{};

// handle incoming http req. and upgrades them to ws conn.
Future<Response> onRequest(RequestContext context) async {
  // create ws handler
  final handler = webSocketHandler((channel, protocol) {
    // add new ch to the set of clients
    _clients.add(channel);

    // listen for incoming msg from client
    channel.stream.listen(
      (message) {
        // handle incoming client msg (print fn)
        print(message);
      },
      onDone: () {
        // remove ch from set of clients when conn is closed
        _clients.remove(channel);
      }
    );

    // send a msg to client
    channel.sink.add('Connected to WS server.');
  });

  // return handler to handle req.
  return handler(context);
}

void broadcast(String message) {
  for (var client in _clients) {
    client.sink.add(message);
  }
}
