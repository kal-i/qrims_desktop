import '../constants/endpoints.dart';
import 'http_service.dart';

class EntitySuggestionService {
  const EntitySuggestionService({
    required this.httpService,
  });

  final HttpService httpService;

  Future<List<String>?> fetchEntities({
    String? entityName,
  }) async {
    final Map<String, dynamic> queryParam = {
      if (entityName != null && entityName.isNotEmpty)
        'entity_name': entityName,
    };

    final response = await httpService.get(
      endpoint: entitiesEP,
      queryParams: queryParam,
    );

    final entityNames = (response.data['entities'] as List<dynamic>?)
        ?.map((entityName) => entityName.toString().toLowerCase())
        .toList();

    return entityNames;
  }
}
