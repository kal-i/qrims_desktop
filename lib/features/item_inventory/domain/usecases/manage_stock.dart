import 'package:fpdart/src/either.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../repository/item_inventory_repository.dart';

class ManageStock implements UseCase<bool, ManageStockParams> {
  const ManageStock({
    required this.itemInventoryRepository,
  });

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, bool>> call(ManageStockParams params) async {
    return await itemInventoryRepository.manageStock(
      itemName: params.itemName,
      description: params.description,
      stockNo: params.stockNo,
    );
  }
}

class ManageStockParams {
  const ManageStockParams({
    required this.itemName,
    required this.description,
    required this.stockNo,
  });

  final String itemName;
  final String description;
  final int stockNo;
}
