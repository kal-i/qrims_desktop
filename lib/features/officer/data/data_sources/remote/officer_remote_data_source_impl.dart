import 'package:dio/dio.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/error/dio_exception_formatter.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/models/paginated_user_result.dart';
import '../../../../../core/services/http_service.dart';
import '../../models/officer.dart';
import '../../models/paginated_officer_result.dart';
import 'officer_remote_data_source.dart';

class OfficerRemoteDataSourceImpl implements OfficerRemoteDataSource {
  const OfficerRemoteDataSourceImpl({
    required this.httpService,
  });

  final HttpService httpService;

  @override
  Future<PaginatedOfficerResultModel> getOfficers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? office,
    String? sortBy,
    bool? sortAscending,
    bool? isArchived,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search_query': searchQuery,
        if (office != null && office.isNotEmpty)
          'office': office,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
        if (sortAscending != null) 'sort_ascending': sortAscending,
        if (isArchived != null) 'is_archived': isArchived,
      };

      final response = await httpService.get(
        endpoint: officersEP,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedOfficerResultModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to load officers.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<OfficerModel> registerOfficer({
    required String name,
    required String officeName,
    required String positionName,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'name': name,
        'office_name': officeName,
        'position_name': positionName,
      };

      final response = await httpService.post(
        endpoint: officersEP,
        params: params,
      );

      if (response.statusCode == 200) {
        return OfficerModel.fromJson(response.data['officer']);
      } else {
        throw const ServerException('Officer registration failed.');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateOfficerArchiveStatus({
    required String id,
    required bool isArchived,
  }) async {
    try {
      final Map<String, dynamic> param = {
        'is_archived': isArchived,
      };

      final response = await httpService.patch(
        endpoint: '$updateOfficerArchiveStatusEP/$id',
        params: param,
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
