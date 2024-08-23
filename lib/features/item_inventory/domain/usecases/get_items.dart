import '../../../../core/enums/asset_classification.dart';
import '../../../../core/enums/asset_sub_class.dart';
import '../../../../core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_item_result.dart';
import '../repository/item_inventory_repository.dart';

class GetItems implements UseCase<PaginatedItemResultEntity, GetItemsParams> {
  const GetItems({
    required this.itemInventoryRepository,
  });

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, PaginatedItemResultEntity>> call(
      GetItemsParams params) async {
    return await itemInventoryRepository.getItems(
      page: params.page,
      pageSize: params.pageSize,
      searchQuery: params.searchQuery,
      sortBy: params.sortBy,
      sortAscending: params.sortAscending,
      classificationFilter: params.classificationFilter,
      subClassFilter: params.subClassFilter,
    );
  }
}

class GetItemsParams {
  const GetItemsParams({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.sortBy,
    this.sortAscending,
    this.classificationFilter,
    this.subClassFilter,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? sortBy;
  final bool? sortAscending;
  final AssetClassification? classificationFilter;
  final AssetSubClass? subClassFilter;
}
