import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/item_suggestion_repository.dart';

class GetItemSuggestionNames implements UseCase<List<String>, String?> {
  const GetItemSuggestionNames({
    required this.itemSuggestionRepository,
  });

  final ItemSuggestionRepository itemSuggestionRepository;

  @override
  Future<Either<Failure, List<String>>> call(String? param) async {
    return await itemSuggestionRepository.getItemNames(
      productName: param,
    );
  }
}
