import '../../../../../core/enums/officer_status.dart';
import '../../models/officer.dart';
import '../../models/paginated_officer_result.dart';

abstract interface class OfficerRemoteDataSource {
  Future<PaginatedOfficerResultModel> getOfficers({
    required int page,
    required int pageSize,
    String? searchQuery,
    String? office,
    String? sortBy,
    OfficerStatus? status,
    bool? sortAscending,
    bool? isArchived,
  });

  Future<OfficerModel> registerOfficer({
    required String name,
    required String officeName,
    required String positionName,
  });

  Future<bool> updateOfficer({
    required String id,
    String? office,
    String? position,
    String? name,
    OfficerStatus? status,
  });

  Future<bool> updateOfficerArchiveStatus({
    required String id,
    required bool isArchived,
  });
}
