import '../../domain/entities/feedbacks.dart';
import 'feedback.dart';

class FeedbacksModel extends FeedbacksEntity {
  const FeedbacksModel({
    required super.pending,
    required super.partiallyFulfilled,
    required super.fulfilled,
    required super.cancelled,
  });

  factory FeedbacksModel.fromJson(Map<String, dynamic> json) {
    return FeedbacksModel(
      pending: FeedbackModel.fromJson(json['pending']),
      partiallyFulfilled: FeedbackModel.fromJson(json['partiallyFulfilled']),
      fulfilled: FeedbackModel.fromJson(json['fulfilled']),
      cancelled: FeedbackModel.fromJson(json['cancelled']),
    );
  }
}
