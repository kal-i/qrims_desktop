import 'dart:convert';

import 'package:api/src/notification/repository/notification_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = context.read<Connection>();
  final notificationRepository = NotificationRepository(connection);
  //final queryParams = context.request.uri.queryParameters;
  //final recipientId = 1; //queryParams['user_id'] as int;

  /// WS handler upgrades HTTP req to WS conn
  /// providing on conn callback that exposes the channel and optional sub proc
  final handler = webSocketHandler(
    /// On conn callback
    (channel, protocol) {
      /// Subscribe the new client to receive notification when state changes
      /// Listen for the messages sent from client
      /// we sub to the msg exposed by the WS CH
      channel.sink.add('server is listening...');

      channel.stream.listen(
        (message) {
          if (message is! String) {
            channel.sink.add('Invalid message');
            return;
          }

          final messageJson = jsonDecode(message) as Map<String, dynamic>;
          final event = messageJson['event'];
          final data = messageJson['data'] as Map<String, dynamic>;

          switch (event) {
            case 'create_notification':
              notificationRepository.sendNotification(params: data).then((message) {
                /// Send msg to CL
                channel.sink.add(
                  jsonEncode({
                    'event': 'create_notification',
                    'data': message.toJson(),
                  }),
                );
              }).catchError((err) {
                print('Something went wrong: $err');
              });

              break;
            default:
          }
        },

        /// Unsubscribe the channel when CL has dc
        //onDone: () => notification.unsubscribe(channel),
      );
    },
  );
  return handler(context);
}
