import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/item_inventory_repository.dart';

class GetStocksProductName implements UseCase<List<String>?, String?> {
  const GetStocksProductName({
    required this.itemInventoryRepository,
  });

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, List<String>?>> call(String? params) async {
    return await itemInventoryRepository.getStocksProductName(
      productName: params,
    );
  }
}
