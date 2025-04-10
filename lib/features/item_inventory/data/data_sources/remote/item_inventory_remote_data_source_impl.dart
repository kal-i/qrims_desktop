import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../../core/constants/endpoints.dart';
import '../../../../../core/enums/asset_classification.dart';
import '../../../../../core/enums/asset_sub_class.dart';
import '../../../../../core/enums/fund_cluster.dart';
import '../../../../../core/enums/unit.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/http_service.dart';
import '../../models/base_item.dart';
import '../../models/paginated_item_result.dart';
import 'item_inventory_remote_date_source.dart';

class ItemInventoryRemoteDataSourceImpl
    implements ItemInventoryRemoteDateSource {
  const ItemInventoryRemoteDataSourceImpl({
    required this.httpService,
  });

  final HttpService httpService;

  @override
  Future<PaginatedItemResultModel> getItems({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? filter,
    String? sortBy,
    bool? sortAscending,
    String? manufacturerName,
    String? brandName,
    AssetClassification? classificationFilter,
    AssetSubClass? subClassFilter,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'page_size': pageSize,
        if (searchQuery != null && searchQuery.isNotEmpty)
          'search_query': searchQuery,
        if (filter != null && filter.isNotEmpty) 'filter': filter,
        if (sortBy != null && sortBy.isNotEmpty) 'sort_by': sortBy,
        if (sortAscending != null) 'sort_ascending': sortAscending,
        if (manufacturerName != null && manufacturerName.isNotEmpty)
          'manufacturer_name': manufacturerName,
        if (brandName != null && brandName.isNotEmpty) 'brand_name': brandName,
        if (classificationFilter != null)
          'asset_classification':
              classificationFilter.toString().split('.').last,
        if (subClassFilter != null)
          'asset_sub_class': subClassFilter.toString().split('.').last,
      };

      final response = await httpService.get(
        endpoint: itemsEP,
        queryParams: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedItemResultModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to load items.');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BaseItemModel> registerSupplyItem({
    FundCluster? fundCluster,
    required String itemName,
    required String description,
    String? specification,
    required Unit unit,
    required int quantity,
    required double unitCost,
    DateTime? acquiredDate,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'type': 'supply',
        'product_name': itemName,
        'description': description,
        if (specification != null && specification.isNotEmpty)
          'specification': specification,
        'unit': unit.toString().split('.').last,
        'quantity': quantity,
        'unit_cost': unitCost,
        if (acquiredDate != null)
          'acquired_date': acquiredDate.toIso8601String(),
        if (fundCluster != null)
          'fund_cluster': fundCluster.toString().split('.').last,
      };

      final response = await httpService.post(
        endpoint: itemsEP,
        params: params,
      );

      if (response.statusCode == 200) {
        return BaseItemModel.fromJson(response.data['item']);
      } else {
        throw const ServerException('Item registration failed.');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? e.response?.statusMessage;

        if (e.response?.statusCode == 500 &&
            errorMessage == 'Serial no. already exists.') {
          throw const ServerException('Serial no. already exists.');
        }
        throw ServerException(
          'DioException: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      } else {
        throw ServerException(
          'DioException: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<BaseItemModel>> registerInventoryItem({
    FundCluster? fundCluster,
    required String itemName,
    required String description,
    String? specification,
    required Unit unit,
    required int quantity,
    String? manufacturerName,
    String? brandName,
    String? modelName,
    String? serialNo,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    required double unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'type': 'inventory',
        if (fundCluster != null)
          'fund_cluster': fundCluster.toString().split('.').last,
        'product_name': itemName,
        'description': description,
        if (manufacturerName != null && manufacturerName.isNotEmpty)
          'manufacturer_name': manufacturerName,
        if (brandName != null && brandName.isNotEmpty) 'brand_name': brandName,
        if (modelName != null && modelName.isNotEmpty) 'model_name': modelName,
        if (serialNo != null && serialNo.isNotEmpty) 'serial_no': serialNo,
        if (specification != null && specification.isNotEmpty)
          'specification': specification,
        if (assetClassification != null)
          'asset_classification':
              assetClassification.toString().split('.').last,
        if (assetSubClass != null)
          'asset_sub_class': assetSubClass.toString().split('.').last,
        'unit': unit.toString().split('.').last,
        'quantity': quantity,
        'unit_cost': unitCost,
        if (estimatedUsefulLife != null)
          'estimated_useful_life': estimatedUsefulLife,
        if (acquiredDate != null)
          'acquired_date': acquiredDate.toIso8601String(),
      };

      final response = await httpService.post(
        endpoint: itemsEP,
        params: params,
      );

      if (response.statusCode == 200) {
        print(response.data);
        return (response.data['items'] as List<dynamic>)
            .map((item) => BaseItemModel.fromJson(item))
            .toList();
      } else {
        throw const ServerException('Item registration failed.');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? e.response?.statusMessage;

        if (e.response?.statusCode == 500 &&
            errorMessage == 'Serial no. already exists.') {
          throw const ServerException('Serial no. already exists.');
        }
        throw ServerException(
          'DioException: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      } else {
        throw ServerException(
          'DioException: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BaseItemModel?> getItemById({
    required String id,
  }) async {
    try {
      // final Map<String, dynamic> queryParam = {
      //   'item_id': id,
      // };

      final response = await httpService.get(
        endpoint: '$itemsIdEP/$id', // itemsEP
        //queryParams: queryParam,
      );

      if (response.statusCode != 200) {
        throw ServerException(response.statusMessage.toString());
      }

      print('get item by id ds res: $response');

      // note: carefully check api res when encounter a bad state: no elem found
      return BaseItemModel.fromJson(response.data['item']);
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? e.response?.statusMessage;

        if (e.response?.statusCode == HttpStatus.notFound &&
            errorMessage == 'Item not found.') {
          throw const ServerException('Item not found.');
        }
        throw ServerException(
          'DioException: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      } else {
        throw ServerException(
          'DioException: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateItem({
    required String id,
    String? itemName,
    String? description,
    String? manufacturerName,
    String? brandName,
    String? modelName,
    String? serialNo,
    String? specification,
    AssetClassification? assetClassification,
    AssetSubClass? assetSubClass,
    Unit? unit,
    int? quantity,
    double? unitCost,
    int? estimatedUsefulLife,
    DateTime? acquiredDate,
  }) async {
    try {
      // final Map<String, dynamic> queryParam = {
      //   'item_id': id,
      // };

      final Map<String, dynamic> params = {
        if (itemName != null && itemName.isNotEmpty) 'product_name': itemName,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (manufacturerName != null && manufacturerName.isNotEmpty)
          'manufacturer_name': manufacturerName,
        if (brandName != null && brandName.isNotEmpty) 'brand_name': brandName,
        if (modelName != null && modelName.isNotEmpty) 'model_name': modelName,
        if (serialNo != null && serialNo.isNotEmpty) 'serial_no': serialNo,
        if (specification != null && specification.isNotEmpty)
          'specification': specification,
        if (assetClassification != null)
          'asset_classification':
              assetClassification.toString().split('.').last,
        if (assetSubClass != null)
          'asset_sub_class': assetSubClass.toString().split('.').last,
        if (unit != null) 'unit': unit.toString().split('.').last,
        if (quantity != null) 'quantity': quantity,
        if (unitCost != null) 'unit_cost': unitCost,
        if (estimatedUsefulLife != null)
          'estimated_useful_life': estimatedUsefulLife,
        if (acquiredDate != null)
          'acquired_date': acquiredDate.toIso8601String(),
      };

      print('ds impl: $params');

      final response = await httpService.patch(
        endpoint: '$itemsIdEP/$id',
        params: params,
      );

      print(response.data);

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.data is String) {
          throw ServerException(e.response?.data);
        }

        final errorData = e.response?.data as Map<String, dynamic>;
        final errorMessage = errorData['message'] ?? e.response?.statusMessage;

        if (e.response?.statusCode == 500 &&
            errorMessage == 'Serial no. already exists.') {
          throw const ServerException('Serial no. already exists.');
        }
        throw ServerException(
          'DioException: ${e.response?.statusCode} - ${e.response?.statusMessage}',
        );
      } else {
        throw ServerException(
          'DioException: ${e.message}',
        );
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
