import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/item_inventory_repository.dart';

class GetStocksProductDescription implements UseCase<List<String>?, String> {
  const GetStocksProductDescription({
    required this.itemInventoryRepository,
  });

  final ItemInventoryRepository itemInventoryRepository;

  @override
  Future<Either<Failure, List<String>?>> call(String params) async {
    return await itemInventoryRepository.getStocksDescription(
      productName: params,
    );
  }
}
