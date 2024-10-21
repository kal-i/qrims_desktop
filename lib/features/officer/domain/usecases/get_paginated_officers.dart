import '../../../../core/error/failure.dart';
import 'package:fpdart/src/either.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/paginated_officer_result.dart';
import '../repository/officer_repository.dart';

class GetPaginatedOfficers
    implements
        UseCase<PaginatedOfficerResultEntity, GetPaginatedOfficersParams> {
  const GetPaginatedOfficers({
    required this.officerRepository,
  });

  final OfficerRepository officerRepository;

  @override
  Future<Either<Failure, PaginatedOfficerResultEntity>> call(
    GetPaginatedOfficersParams params,
  ) async {
    return await officerRepository.getOfficers(
      page: params.page,
      pageSize: params.pageSize,
      searchQuery: params.searchQuery,
      sortBy: params.sortBy,
      sortAscending: params.sortAscending,
      isArchived: params.isArchived,
    );
  }
}

class GetPaginatedOfficersParams {
  const GetPaginatedOfficersParams({
    required this.page,
    required this.pageSize,
    this.searchQuery,
    this.sortBy,
    this.sortAscending,
    this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? sortBy;
  final bool? sortAscending;
  final bool? isArchived;
}
