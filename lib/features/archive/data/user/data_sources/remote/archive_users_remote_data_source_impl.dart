import 'package:dio/dio.dart';

import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/enums/auth_status.dart';
import '../../../../../../core/error/dio_exception_formatter.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/models/paginated_user_result.dart';
import '../../../../../../core/services/http_service.dart';
import 'archive_users_remote_data_source.dart';

class ArchiveUsersRemoteDataSourceImpl implements ArchiveUsersRemoteDataSource {
  const ArchiveUsersRemoteDataSourceImpl({required this.httpService,});
  
  final HttpService httpService;
  
  @override
  Future<PaginatedUserResultModel> getArchivedUsers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? role,
    AuthStatus? authStatus,
    required bool isArchived,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null && searchQuery.isNotEmpty) 'search_query': searchQuery,
        if (role != null && role.isNotEmpty) 'role': role,
        if (authStatus != null) 'auth_status': authStatus.toString().split('.').last,
        'is_archived': isArchived,
      };

      final response = await httpService.get(
        endpoint: bearerUsersEP,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        print(response.data);
        return PaginatedUserResultModel.fromJson(response.data);
        // print('200');
        // print(response.data.runtimeType);
        // print(response.data);
        // final List<dynamic> json = response.data;
        // print('umrds: $json');
        // return json.map((user) => UserModel.fromJson(user)).toList();
      } else {
        throw const ServerException('Failed to load users.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateUserArchiveStatus({
    required String id,
    required bool isArchived,
  }) async {
    try {
      final Map<String, dynamic> queryParam = {
        'user_id': id,
      };

      final Map<String, dynamic> param = {
        'is_archived': isArchived,
      };

      print('Making patch request with params: $param');

      // don't forget that only admin can do this
      final response = await httpService.patch(
        endpoint: bearerUsersUpdateArchiveStatusEP,
        queryParams: queryParam,
        params: param,
      );

      print('Response from patch request: $response');
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
