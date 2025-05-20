import 'package:dio/dio.dart';

import '../../../../../core/constants/endpoints.dart';
import '../../../../../core/error/dio_exception_formatter.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/http_service.dart';
import '../../models/inventory_summary.dart';
import '../../models/paginated_reusable_item_information.dart';
import '../../models/requests_summary.dart';
import 'dashboard_remote_data_source.dart';

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  const DashboardRemoteDataSourceImpl({
    required this.httpService,
  });

  final HttpService httpService;

  @override
  Future<InventorySummaryModel> getInventorySummary() async {
    try {
      final response = await httpService.get(
        endpoint: inventorySummaryEP,
      );

      print('dash inv sum impl: $response');
      if (response.statusCode == 200) {
        return InventorySummaryModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to load inventory summary.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<RequestsSummaryModel> getRequestsSummary() async {
    try {
      final response = await httpService.get(
        endpoint: requestsSummaryEP,
      );

      print('dash req sum impl: $response');
      if (response.statusCode == 200) {
        return RequestsSummaryModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to load request summary.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaginatedReusableItemInformationModel> getLowStockItems({
    required int page,
    required int pageSize,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      final response = await httpService.get(
        endpoint: lowStockEP,
        queryParams: queryParams,
      );

      print('dash low stock impl: $response');
      print('res: ${response.data['items']}');
      if (response.statusCode == 200) {
        return PaginatedReusableItemInformationModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to load low stock items.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaginatedReusableItemInformationModel> getOutOfStockItems({
    required int page,
    required int pageSize,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
      };

      final response = await httpService.get(
        endpoint: outOfStockEP,
        queryParams: queryParams,
      );

      print('dash inv sum impl: $response');
      if (response.statusCode == 200) {
        return PaginatedReusableItemInformationModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to load out of stock items.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
