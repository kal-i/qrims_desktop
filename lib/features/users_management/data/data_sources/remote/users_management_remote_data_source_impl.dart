import 'package:dio/dio.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/enums/admin_approval_status.dart';
import '../../../../../core/enums/auth_status.dart';
import '../../../../../core/error/dio_exception_formatter.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/http_service.dart';
import '../../../../../core/models/paginated_user_result.dart';
import '../../models/paginated_mobile_user_result_model.dart';
import 'users_management_remote_data_source.dart';

class UsersManagementRemoteDataSourceImpl
    implements UsersManagementRemoteDataSource {
  const UsersManagementRemoteDataSourceImpl({
    required this.httpService,
  });

  final HttpService httpService;

  @override
  Future<PaginatedUserResultModel> getAllUsers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    String? role,
    AuthStatus? status,
    AdminApprovalStatus? adminApprovalStatus,
    bool? isArchived,
  }) async {
    try {
      final sortValueParam = sortBy == 'User Id'
          ? 'id'
          : sortBy == 'Account Creation'
              ? 'created_at'
              : null;
      print('ds impl: $sortAscending');
      print('ds impl: $role');

      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search_query': searchQuery,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortValueParam,
        if (sortAscending != null) 'sort_ascending': sortAscending,
        if (role != null && role.isNotEmpty) 'role': role,
        if (status != null) 'status': status.toString().split('.').last,
        if (adminApprovalStatus != null) 'admin_approval_status': adminApprovalStatus.toString().split('.').last,
        if (isArchived != null) 'is_archived': isArchived,
      };

      print(bearerUsersEP);
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
  Future<PaginatedMobileUserResultModel> getPendingUsers({
    required int page,
    required int pageSize,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      final response = await httpService.get(
        endpoint: bearerPendingUsersEP,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedMobileUserResultModel.fromJson(response.data);
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
  Future<bool> updateUserAuthenticationStatus({
    required String id,
    required AuthStatus authStatus,
  }) async {
    try {
      final Map<String, dynamic> queryParam = {
        'user_id': id,
      };

      final Map<String, dynamic> param = {
        'auth_status': authStatus.toString().split('.').last,
      };

      print('Making patch request with params: $param');

      // don't forget that only admin can do this
      final response = await httpService.patch(
        endpoint: bearerUsersUpdateAuthStatusEP,
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

  @override
  Future<bool> updateAdminApprovalStatus({
    required String id,
    required AdminApprovalStatus adminApprovalStatus,
  }) async {
    try {
      final Map<String, dynamic> queryParam = {
        'user_id': id,
      };

      final Map<String, dynamic> param = {
        'admin_approval_status': adminApprovalStatus.toString().split('.').last,
      };

      print('Making patch request with params: $param');

      // don't forget that only admin can do this
      final response = await httpService.patch(
        endpoint: '$bearerPendingUsersEP/$id',
        //queryParams: queryParam,
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
