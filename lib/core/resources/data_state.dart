import 'package:dio/dio.dart';

// A wrapper class for network or async calls
// has two states: success or failed
/// This will determine the state of the request
/// and response sent to the sever
sealed class DataState<T> {
  final T? data;
  final DioException? err;

  const DataState({
    this.data,
    this.err,
  });
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(DioException err) : super(err: err);
}