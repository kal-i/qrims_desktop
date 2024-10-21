import 'package:dio/dio.dart';

import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/services/http_service.dart';
import 'item_suggestion_remote_data_source.dart';

class ItemSuggestionRemoteDataSourceImpl
    implements ItemSuggestionRemoteDataSource {
  const ItemSuggestionRemoteDataSourceImpl({
    required this.httpService,
  });

  final HttpService httpService;

  @override
  Future<List<String>> getItemNames({
    String? productName,
  }) async {
    try {
      final Map<String, dynamic> queryParam = {
        if (productName != null && productName.isNotEmpty)
          'product_name': productName,
      };

      final response = await httpService.get(
        endpoint: itemNamesEP,
        queryParams: queryParam,
      );

      return (response.data['product_names'] as List<dynamic>?)
              ?.map((itemName) => itemName.toString().toLowerCase())
              .toList() ??
          [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> getItemDescriptions({
    required String productName,
    String? productDescription,
  }) async {
    try {
      final Map<String, dynamic> queryParam = {
        'product_name': productName,
        if (productDescription != null && productDescription.isNotEmpty)
          'product_description': productDescription,
      };

      final response = await httpService.get(
        endpoint: itemDescriptionsEP,
        queryParams: queryParam,
      );

      return (response.data['descriptions'] as List<dynamic>?)
              ?.map((itemDescription) => itemDescription as String)
              .toList() ??
          [];
    } catch (e) {
        throw ServerException(e.toString());
    }
  }
}
