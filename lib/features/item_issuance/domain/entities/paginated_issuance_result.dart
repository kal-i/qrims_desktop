import 'issuance.dart';

class PaginatedIssuanceResultEntity {
  const PaginatedIssuanceResultEntity({
    required this.issuances,
    required this.totalIssuanceCount,
  });

  final List<IssuanceEntity> issuances;
  final int totalIssuanceCount;
}
