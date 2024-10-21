import '../constants/app_constants.dart';
import 'http_service.dart';

class ItemSuggestionsService {
  const ItemSuggestionsService({
    required this.httpService,
  });

  final HttpService httpService;

  Future<List<String>?> fetchItemNames({
    String? productName,
  }) async {
    final Map<String, dynamic> queryParams = {
      if (productName != null && productName.isNotEmpty)
        'product_name': productName,
    };
    final response = await httpService.get(
      endpoint: itemNamesEP,
      queryParams: queryParams,
    );

    final itemNames = (response.data['product_names'] as List<dynamic>?)
        ?.map((itemName) => itemName.toString().toLowerCase())
        .toList();

    return itemNames;
  }

  Future<List<String>?> fetchItemDescriptions({
    required String productName,
    String? productDescription,
  }) async {
    final Map<String, dynamic> queryParams = {
      'product_name': productName,
      if (productDescription != null && productDescription.isNotEmpty)
        'product_description': productDescription,
    };

    final response = await httpService.get(
      endpoint: itemDescriptionsEP,
      queryParams: queryParams,
    );

    final descriptions = (response.data['descriptions'] as List<dynamic>?)
        ?.map((itemDescription) => itemDescription as String)
        .toList();

    return descriptions;
  }

  Future<List<String>?> fetchManufacturers({
    String? manufacturerName,
  }) async {
    final Map<String, dynamic> queryParams = {
      if (manufacturerName != null && manufacturerName.isNotEmpty)
        'manufacturer_name': manufacturerName
    };

    final response = await httpService.get(
      endpoint: itemManufacturersEP,
      queryParams: queryParams,
    );

    final manufacturers = (response.data['manufacturers'] as List<dynamic>?)
        ?.map((manufacturer) => manufacturer as String)
        .toList();

    return manufacturers;
  }

  Future<List<String>?> fetchBrands({
    required String manufacturerName,
    String? brandName
  }) async {
    final Map<String, dynamic> queryParams = {
      'manufacturer_name': manufacturerName,
      if (brandName != null && brandName.isNotEmpty)
        'brand_name': brandName
    };

    final response = await httpService.get(
      endpoint: itemBrandsEP,
      queryParams: queryParams,
    );

    final brands = (response.data['brands'] as List<dynamic>?)
        ?.map((manufacturer) => manufacturer as String)
        .toList();

    return brands;
  }

  Future<List<String>?> fetchModels({
    required String productName,
    required String brandName,
    String? modelName,
  }) async {
    final Map<String, dynamic> queryParams = {
      'product_name': productName,
      'brand_name': brandName,
      if (modelName != null && modelName.isNotEmpty)
        'model_name': modelName
    };

    final response = await httpService.get(
      endpoint: itemModelsEP,
      queryParams: queryParams,
    );

    final models = (response.data['models'] as List<dynamic>?)
        ?.map((manufacturer) => manufacturer as String)
        .toList();

    return models;
  }
}
