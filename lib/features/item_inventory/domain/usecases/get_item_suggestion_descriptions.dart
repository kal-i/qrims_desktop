import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../repository/item_suggestion_repository.dart';

class GetItemSuggestionDescriptions
    implements UseCase<List<String>, GetItemSuggestionDescriptionsParams> {
  const GetItemSuggestionDescriptions({
    required this.itemSuggestionRepository,
  });

  final ItemSuggestionRepository itemSuggestionRepository;

  @override
  Future<Either<Failure, List<String>>> call(params) async {
    return await itemSuggestionRepository.getItemDescriptions(
      productName: params.productName,
      productDescription: params.productDescription,
    );
  }
}

class GetItemSuggestionDescriptionsParams {
  const GetItemSuggestionDescriptionsParams({
    required this.productName,
    this.productDescription,
  });

  final String productName;
  final String? productDescription;
}
