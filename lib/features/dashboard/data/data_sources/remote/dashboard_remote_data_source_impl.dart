import 'package:dio/dio.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/enums/period.dart';
import '../../../../../core/error/dio_exception_formatter.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/http_service.dart';
import '../../models/inventory_summary.dart';
import '../../models/most_requested_items.dart';
import '../../models/paginated_item_result.dart';
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
  Future<MostRequestedItemsModel> getMostRequestedItems({
    int? limit,
    Period? period,
  }) async {
    final Map<String, dynamic> queryParams = {
      'limit': limit ?? 10,
      'period': period ?? Period.month.toString().split('.').last,
    };

    try {
      final response = await httpService.get(
        endpoint: mostRequestedItemsEP,
        queryParams: queryParams,
      );

      print('dash most req. items impl: $response');
      if (response.statusCode == 200) {
        return MostRequestedItemsModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to load most requested items.');
      }
    } on DioException catch (e) {
      final formattedError = formatDioError(e);
      throw ServerException(formattedError);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaginatedItemResultModel> getLowStockItems({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await httpService.get(
        endpoint: '$inventorySummaryEP/low_stock',
      );

      print('dash low stock impl: $response');
      print('res: ${response.data['items']}');
      if (response.statusCode == 200) {
        return PaginatedItemResultModel(items: response.data);
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
  Future<PaginatedItemResultModel> getOutOfStockItems({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await httpService.get(
        endpoint: '$inventorySummaryEP/out_of_stock',
      );

      print('dash inv sum impl: $response');
      if (response.statusCode == 200) {
        return PaginatedItemResultModel(items: response.data);
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
}
