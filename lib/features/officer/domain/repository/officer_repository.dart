import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/officer.dart';
import '../entities/paginated_officer_result.dart';

abstract interface class OfficerRepository {
  Future<Either<Failure, PaginatedOfficerResultEntity>> getOfficers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
    bool? isArchived,
  });

  Future<Either<Failure, OfficerEntity>> registerOfficer({
    required String name,
    required String officeName,
    required String positionName,
  });

  Future<Either<Failure, bool>> updateOfficerArchiveStatus({
    required String id,
    required bool isArchived,
  });
}