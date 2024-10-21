abstract interface class UserRemoteDataSource {

  Future<bool> updateUserInfo({
    required int id,
    required String? profileImage,
  });
}
