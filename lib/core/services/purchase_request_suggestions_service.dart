import '../constants/endpoints.dart';
import 'http_service.dart';

class PurchaseRequestSuggestionsService {
  const PurchaseRequestSuggestionsService({
    required this.httpService,
  });

  final HttpService httpService;

  Future<List<String>?> fetchPurchaseRequestIds({
    String? prId,
    String? type,
  }) async {
    final Map<String, dynamic> queryParam = {
      if (prId != null && prId.isNotEmpty) 'pr_id': prId,
      if (type != null && type.isNotEmpty) 'type': type,
    };

    final response = await httpService.get(
      endpoint: purchaseRequestIdsEP,
      queryParams: queryParam,
    );

    final prIds = (response.data['purchase_request_ids'] as List<dynamic>?)
        ?.map((officeName) => officeName.toString().toLowerCase())
        .toList();

    return prIds;
  }
}
