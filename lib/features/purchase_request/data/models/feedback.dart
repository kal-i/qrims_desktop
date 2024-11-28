import '../../domain/entities/feedback.dart';

class FeedbackModel extends FeedbackEntity {
  const FeedbackModel({
    required super.feedback,
    required super.isIncrease,
    required super.percentage,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      feedback: json['feedback'],
      isIncrease: json['is_increase'],
      percentage: json['percentage'],
    );
  }
}
