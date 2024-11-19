import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/item_with_stock.dart';
import '../repository/item_inventory_repository.dart';

class GetItemById implements UseCase<ItemWithStockEntity?, String> {
  const GetItemById({
    required this.itemInventoryRepository,
  });

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, ItemWithStockEntity?>> call(String param) async {
    return await itemInventoryRepository.getItemById(
      id: param,
    );
  }
}
