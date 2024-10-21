import 'package:api/src/user/models/user.dart';
import 'package:api/src/user/repository/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:postgres/postgres.dart';

/// Basically, this will authenticate the user before proceeding with the request
/// With an exception on post method
Handler middleware(Handler handler) {
  return handler.use(
    basicAuthentication<User>(
      authenticator: (context, email, password) {
        final connection = context.read<Connection>();
        final repository = UserRepository(connection);

        return repository.checkUserCredentialFromDatabase(
          email: email,
          password: password,
        );
      },
      /// when we use post method, in that case, we don't do authentication at the post of creating a user
      /// other method will be passed through the authenticator before it is process
      /// basically, it will validate first if the username and password is correct before proceeding with the request
      applies: (RequestContext context) async =>
          context.request.method != HttpMethod.post,
    ),
  );
}
