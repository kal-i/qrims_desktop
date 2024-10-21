import '../../domain/entities/paginated_officer_result.dart';
import 'officer.dart';

class PaginatedOfficerResultModel extends PaginatedOfficerResultEntity {
  const PaginatedOfficerResultModel({
    required super.officers,
    required super.totalItemsCount,
  });

  factory PaginatedOfficerResultModel.fromJson(Map<String, dynamic> json) {
    return PaginatedOfficerResultModel(
      officers: (json['officers'] as List<dynamic>).map((e) => OfficerModel.fromJson(e)).toList(),
      totalItemsCount: json['totalItemCount'],
    );
  }
}
