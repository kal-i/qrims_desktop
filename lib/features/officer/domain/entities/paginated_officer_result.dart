import 'officer.dart';

class PaginatedOfficerResultEntity {
  const PaginatedOfficerResultEntity({
    required this.officers,
    required this.totalItemsCount,
  });

  final List<OfficerEntity> officers;
  final int totalItemsCount;
}
