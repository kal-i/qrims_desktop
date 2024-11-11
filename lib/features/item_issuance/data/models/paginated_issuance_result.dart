import '../../domain/entities/paginated_issuance_result.dart';
import 'issuance.dart';

class PaginatedIssuanceResultModel extends PaginatedIssuanceResultEntity {
  const PaginatedIssuanceResultModel({
    required super.issuances,
    required super.totalIssuanceCount,
  });

  factory PaginatedIssuanceResultModel.fromJson(Map<String, dynamic> json) {
    print('paginated issuance res mod: ${json['issuances']}');
    print('paginated res mod: ${json['totalItemCount']}');
    return PaginatedIssuanceResultModel(
      issuances: (json['issuances'] as List<dynamic>)
          .map((issuance) {
            print('paginated issuance res mod: $issuance');
              return IssuanceModel.fromJson(issuance as Map<String, dynamic>);})
          .toList(),
      totalIssuanceCount: json['totalItemCount'],
    );
  }
}
