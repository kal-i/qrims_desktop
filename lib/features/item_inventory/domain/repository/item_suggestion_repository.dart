import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';

abstract interface class ItemSuggestionRepository {

  Future<Either<Failure, List<String>>> getItemNames({
    String? productName,
  });

  Future<Either<Failure, List<String>>> getItemDescriptions({
    required String productName,
    String? productDescription,
  });
}
