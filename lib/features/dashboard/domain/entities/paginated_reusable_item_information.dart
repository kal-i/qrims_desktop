import 'reusable_item_information.dart';

class PaginatedReusableItemInformationEntity {
  const PaginatedReusableItemInformationEntity({
    required this.reusableItemInformationEntities,
    required this.totalItemCount,
  });

  final List<ReusableItemInformationEntity> reusableItemInformationEntities;
  final int totalItemCount;
}
