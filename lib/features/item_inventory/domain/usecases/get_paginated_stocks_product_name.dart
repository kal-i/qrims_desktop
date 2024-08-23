import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_item_name.dart';
import '../repository/item_inventory_repository.dart';

class GetPaginatedStocksProductName implements UseCase<PaginatedItemNameEntity, GetPaginatedStocksProductNameParams> {
  const GetPaginatedStocksProductName({required this.itemInventoryRepository,});

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, PaginatedItemNameEntity>> call(GetPaginatedStocksProductNameParams params) async {
    return await itemInventoryRepository.getPaginatedProductNames(
      page: params.page,
      pageSize: params.pageSize,
      productName: params.productName,
    );
  }
}

class GetPaginatedStocksProductNameParams {
  const GetPaginatedStocksProductNameParams({
    this.page,
    this.pageSize,
    this.productName,
  });

  final int? page;
  final int? pageSize;
  final String? productName;
}