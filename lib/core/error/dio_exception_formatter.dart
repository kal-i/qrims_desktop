import 'package:dio/dio.dart';

String formatDioError(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout) {
    return 'Connection timeout. Please check your network connection.';
  } else if (error.type == DioExceptionType.sendTimeout) {
    return 'Send timeout. Please try again later.';
  } else if (error.type == DioExceptionType.receiveTimeout) {
    return 'Receive timeout. The server took too long to respond.';
  } else if (error.type == DioExceptionType.badResponse) {
    return 'Bad response from server: ${error.response?.statusCode} ${error.response?.statusMessage}';
  } else if (error.type == DioExceptionType.cancel) {
    return 'Request was cancelled.';
  } else if (error.type == DioExceptionType.unknown) {
    return 'An unknown error occurred: ${error.message}';
  } else {
    return 'An unexpected error occurred: ${error.message}';
  }
}
