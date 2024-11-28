import '../../domain/entities/paginated_item_result.dart';
import 'item.dart';

class PaginatedItemResultModel extends PaginatedItemResultEntity {
  const PaginatedItemResultModel({
    required super.items,
  });

  factory PaginatedItemResultModel.fromJson(Map<String, dynamic> json) {
    print('pag item res: $json');
    return PaginatedItemResultModel(
        items: (json['items'] as List<dynamic>)
            .map((e) => ItemModel.fromJson(e))
            .toList());
  }
}
