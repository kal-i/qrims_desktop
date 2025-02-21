import '../../../../core/enums/officer_status.dart';
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
      office: params.office,
      sortBy: params.sortBy,
      status: params.status,
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
    this.office,
    this.sortBy,
    this.status,
    this.sortAscending,
    this.isArchived,
  });

  final int page;
  final int pageSize;
  final String? searchQuery;
  final String? office;
  final String? sortBy;
  final OfficerStatus? status;

  final bool? sortAscending;
  final bool? isArchived;
}
