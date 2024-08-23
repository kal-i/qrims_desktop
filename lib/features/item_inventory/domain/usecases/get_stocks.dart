import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/stock.dart';
import '../repository/item_inventory_repository.dart';

class GetStocks implements UseCase<List<StockEntity>?, NoParams> {
  const GetStocks({required this.itemInventoryRepository,});

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, List<StockEntity>?>> call(NoParams params) async {
    return await itemInventoryRepository.getStocks();
  }
}