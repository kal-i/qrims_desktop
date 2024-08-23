import 'package:api/src/session/session_repository.dart';
import 'package:api/src/user/user.dart';
import 'package:api/src/user/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:postgres/postgres.dart';

Handler middleware(Handler handler) {
  return handler.use(
    bearerAuthentication<User>(
      /// the authenticator parameter will use both user and session repository
      /// the session repository will get the session of a specific token
      /// once we have it, we're going to get the user id from there and
      /// validate with the user repository function
      authenticator: (context, token) async {
        final connection = context.read<Connection>();
        final userRepository = UserRepository(connection);
        final sessionRepository = SessionRepository(connection);
        final session = await sessionRepository.sessionFromToken(token);

        return session != null
            ? userRepository.getUserInformation(id: session.userId)
            : null;
      },

      /// at user creation, we won't be creating a session yet
      /// we want it at the point of logging in
      /// meaning, this authenticator won't be apply to post and get HTTP methods
      applies: (RequestContext context) async =>
          context.request.method != HttpMethod.post &&
          context.request.method != HttpMethod.get,
    ),
  );
}
