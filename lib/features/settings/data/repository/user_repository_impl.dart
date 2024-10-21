import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../domain/repository/user_repository.dart';
import '../data_sources/remote/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({
    required this.userRemoteDataSource,
  });

  final UserRemoteDataSource userRemoteDataSource;

  @override
  Future<Either<Failure, bool>> updateUserInfo({
    required int id,
    String? profileImage,
  }) async {
    try {
      final response = await userRemoteDataSource.updateUserInfo(
        id: id,
        profileImage: profileImage,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
