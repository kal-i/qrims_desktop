import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';

// the main purpose of use case is to expose high lvl function like login
abstract interface class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}