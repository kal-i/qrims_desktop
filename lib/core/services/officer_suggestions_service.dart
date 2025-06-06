import '../constants/endpoints.dart';
import '../utils/capitalizer.dart';
import '../utils/standardize_position_name.dart';
import 'http_service.dart';

class OfficerSuggestionsService {
  const OfficerSuggestionsService({
    required this.httpService,
  });

  final HttpService httpService;

  Future<List<String>?> fetchOffices({
    //required int page,
    String? officeName,
  }) async {
    final Map<String, dynamic> queryParam = {
      // 'page': page,
      // 'page_size': 2,
      if (officeName != null && officeName.isNotEmpty)
        'office_name': officeName,
    };

    final response = await httpService.get(
      endpoint: officesEP,
      queryParams: queryParam,
    );

    final officeNames = (response.data['offices'] as List<dynamic>?)
        ?.map((officeName) => capitalizeWord(officeName))
        .toList();

    return officeNames;
  }

  Future<List<String>?> fetchOfficePositions({
    required String officeName,
    String? positionName,
  }) async {
    final Map<String, dynamic> queryParams = {
      'office_name': officeName,
      if (positionName != null && positionName.isNotEmpty)
        'position_name': positionName,
    };

    final response = await httpService.get(
      endpoint: positionsEP,
      queryParams: queryParams,
    );

    final positionNames = (response.data['positions'] as List<dynamic>?)
        ?.map((position) => standardizePositionName(position))
        .toList();

    return positionNames;
  }

  Future<List<String>?> fetchOfficers({
    String? officeName,
    String? positionName,
    String? officerName,
  }) async {
    final Map<String, dynamic> queryParams = {
      if (officeName != null && officeName.isNotEmpty)
        'office_name': officeName,
      if (positionName != null && positionName.isNotEmpty)
        'position_name': positionName,
      if (officerName != null && officerName.isNotEmpty)
        'officer_name': officerName,
    };

    final response = await httpService.get(
      endpoint: officerNamesEP,
      queryParams: queryParams,
    );

    final officerNames = (response.data['officers'] as List<dynamic>?)
        ?.map((position) => capitalizeWord(position))
        .toList();

    return officerNames;
  }
}
