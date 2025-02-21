import '../../domain/entities/paginated_reusable_item_information.dart';
import 'reusable_item_information.dart';

class PaginatedReusableItemInformationModel
    extends PaginatedReusableItemInformationEntity {
  const PaginatedReusableItemInformationModel({
    required super.reusableItemInformationEntities,
    required super.totalItemCount,
  });

  factory PaginatedReusableItemInformationModel.fromJson(
      Map<String, dynamic> json) {
    print('received raw json by paginated reusable info: $json');
    return PaginatedReusableItemInformationModel(
      reusableItemInformationEntities: (json['items'] as List<dynamic>)
          .map(
            (item) => ReusableItemInformationModel.fromJson(item),
          )
          .toList(),
      totalItemCount: json['total_item_count'],
    );
  }
}
