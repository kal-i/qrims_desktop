import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_issuance_result.dart';
import '../repository/issuance_repository.dart';

class GetPaginatedIssuances
    implements
        UseCase<PaginatedIssuanceResultEntity, GetPaginatedIssuancesParams> {
  const GetPaginatedIssuances({
    required this.issuanceRepository,
  });

  final IssuanceRepository issuanceRepository;

  @override
  Future<Either<Failure, PaginatedIssuanceResultEntity>> call(
      GetPaginatedIssuancesParams params) async {
    return await issuanceRepository.getIssuances(
      page: params.page,
      pageSize: params.pageSize,
      searchQuery: params.searchQuery,
      issueDateStart: params.issueDateStart,
      issueDateEnd: params.issueDateEnd,
      type: params.type,
      isArchived: params.isArchived,
    );
  }
}

class GetPaginatedIssuancesParams {
  const GetPaginatedIssuancesParams({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.issueDateStart,
    this.issueDateEnd,
    this.type,
    this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final DateTime? issueDateStart;
  final DateTime? issueDateEnd;
  final String? type;
  final bool? isArchived;
}
