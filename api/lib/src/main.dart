import 'dart:convert';

import 'package:api/src/notification/model/notification.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

/// We use Web Socket Channel to connect to WS endpoint
/// then we can send msg to server by calling add on WS CH sink
Future<void> main() async  {
  /// Connect to remote WS endpoint
  final uri = Uri.parse('ws://localhost:8080/items/ws');
  final channel = WebSocketChannel.connect(uri);

  /// Subscribe to listen to incoming msg from server
  channel.stream.listen(print);

  Map<String, dynamic> notificationData = {
    'recipient_id': 1,
    'sender_id': 2,
    'message': 'A notification was sent.',
    //'type': NotificationType.itemIssuance,
    'reference_id': 1,
  };

  var payload = {'event': 'create_notification', 'data': notificationData};

  for (int i = 1; i <= 10; i++) {
    await Future.delayed(Duration(seconds: 3));
    channel.sink.add(jsonEncode(payload));
  }

  await channel.sink.close();
}