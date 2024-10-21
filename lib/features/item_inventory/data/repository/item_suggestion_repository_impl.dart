import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../domain/repository/item_suggestion_repository.dart';
import '../data_sources/remote/item_suggestion_data_source/item_suggestion_remote_data_source.dart';

class ItemSuggestionRepositoryImpl implements ItemSuggestionRepository {
  const ItemSuggestionRepositoryImpl({
    required this.itemSuggestionRemoteDataSource,
  });

  final ItemSuggestionRemoteDataSource itemSuggestionRemoteDataSource;

  @override
  Future<Either<Failure, List<String>>> getItemNames({
    String? productName,
  }) async {
    try {
      final response = await itemSuggestionRemoteDataSource.getItemNames(
        productName: productName,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getItemDescriptions({
    required String productName,
    String? productDescription,
  }) async {
    try {
      final response = await itemSuggestionRemoteDataSource.getItemDescriptions(
        productName: productName,
        productDescription: productDescription,
      );

      return right(response);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
