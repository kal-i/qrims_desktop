import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/http_service.dart';
import '../../models/user_activity.dart';
import 'user_activity_remote_data_source.dart';

class UserActivityRemoteDataSourceImpl implements UserActivityRemoteDataSource {
  const UserActivityRemoteDataSourceImpl({
    required this.httpService,
  });

  final HttpService httpService;

  @override
  Future<List<UserActivityModel>> getUserActivities({
    required int userId,
    required int page,
    required int pageSize,
  }) async {
    final Map<String, dynamic> queryParams = {
      'user_id': userId,
      'page': page,
      'page_size': pageSize,
    };

    final response = await httpService.get(
      endpoint: userActsEP,
      queryParams: queryParams,
    );

    if (response.statusCode == 200) {
      if (!response.data.containsKey('user_activities')) {
        throw const ServerException(
            'Key "user_activities" not found in response.');
      }

      final List<dynamic>? userActivitiesJson =
          response.data['user_activities'];

      if (userActivitiesJson == null) {
        throw const ServerException('User activities data is null.');
      }

      return userActivitiesJson
          .map((userAct) => UserActivityModel.fromJson(userAct))
          .toList();

      // final decodedJson = json.decode(response.data);
      //
      // if (decodedJson == null || !decodedJson.containsKey('user_activities')) {
      //   throw ServerException('Invalid response format');
      // }
      //
      // final List userActivitiesJson = decodedJson['user_activities'];
      //
      // print(userActivitiesJson);
      //
      // return userActivitiesJson
      //     .map((json) => UserActivityModel.fromJson(json as Map<String, dynamic>))
      //     .toList();
    } else {
      throw ServerException(
          'Failed to load user activities. Status code: ${response.statusCode}');
    }
  }
}

// if (!response.data.containsKey('user_activities')) {
//   throw const ServerException('Key "user_activities" not found in response.');
// }
//
// final List<dynamic>? userActivitiesJson = response.data['user_activities'];
//
// if (userActivitiesJson == null) {
//   throw const ServerException('User activities data is null.');
// }
//
// return userActivitiesJson
//     .map((userAct) => UserActivityModel.fromJson(userAct))
//     .toList();

// try {
//   final Map<String, dynamic> queryParams = {
//     'user_id': userId,
//     'page': page,
//     'page_size': pageSize,
//   };
//
//   final response = await httpService.get(
//     endpoint: userActsEP,
//     queryParams: queryParams,
//   );
//
//   print('Response status code: ${response.statusCode}');
//   print('Response data: ${response.data}');
//
//   if (response.statusCode == 200) {
//     final List decodedJson = json.decode(response.data)['user_activities'];
//     return decodedJson.map((json) => UserActivityModel.fromJson(json)).toList();
//     // if (!response.data.containsKey('user_activities')) {
//     //   throw const ServerException('Key "user_activities" not found in response.');
//     // }
//     //
//     // final List<dynamic>? userActivitiesJson = response.data['user_activities'];
//     //
//     // if (userActivitiesJson == null) {
//     //   throw const ServerException('User activities data is null.');
//     // }
//     //
//     // return userActivitiesJson
//     //     .map((userAct) => UserActivityModel.fromJson(userAct))
//     //     .toList();
//   } else {
//     throw ServerException('Failed to load user activities. Status code: ${response.statusCode}');
//   }
// } catch (e) {
//   print('Exception: $e');
//   throw ServerException(e.toString());
// }
