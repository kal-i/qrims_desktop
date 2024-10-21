import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/http_service.dart';
import 'user_remote_data_source.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  const UserRemoteDataSourceImpl({required this.httpService,});

  final HttpService httpService;

  @override
  Future<bool> updateUserInfo({
    required int id,
    required String? profileImage,
  }) async {
    try {
      Map<String, dynamic> queryParam = {
        'id': id,
      };

      Map<String, dynamic> param = {
        'profile_image': profileImage,
      };

      final response = await httpService.patch(endpoint: updateUserInfoEP, queryParams: queryParam, params: param,);

      if (response.statusCode != 200) {
        return false;
      }

      return true;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
