import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

class HttpService {
  final Dio dio;
  String? bearerToken;

  HttpService(this.dio) {
    dio.options.baseUrl = baseUrl;
    dio.options.headers['Content-Type'] = 'application/json';

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (bearerToken != null) {
            options.headers['Authorization'] = 'Bearer $bearerToken';
          }
          print('Request [${options.method}] => PATH: ${options.baseUrl}${options.path}, BODY: ${options.data}, HEADERS: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('Response [${response.statusCode}] => DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('Request error: ${e.message}');
          print('Error type: ${e.type}');
          print('Error response: ${e.response?.data}');
          print('Error status code: ${e.response?.statusCode}');
          if (e.response != null) {
            print('Error Data: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  void updateBearerToken(String token) {
    print('Updating bearer token: $token');
    bearerToken = token;
  }

  Future<Response> get({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? params,
  }) async {
    return dio.get(
      endpoint,
      queryParameters: queryParams,
      data: params,
    );
  }

  Future<Response> post({
    required String endpoint,
    Map<String, dynamic>? params,
  }) async {
    return dio.post(
      endpoint,
      data: params,
    );
  }

  Future<Response> patch({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    required Map<String, dynamic> params,
  }) async {
    print('patch triggered');
    print('bearer token: $bearerToken');
    return dio.patch(
      endpoint,
      queryParameters: queryParams,
      data: params,
    );
  }
}
