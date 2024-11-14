import 'package:fpdart/src/either.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/issuance.dart';
import '../repository/issuance_repository.dart';

class GetIssuanceById implements UseCase<IssuanceEntity?, String> {
  const GetIssuanceById({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, IssuanceEntity?>> call(String param) async {
    return await issuanceRepository.getIssuanceById(
      id: param,
    );
  }
}
