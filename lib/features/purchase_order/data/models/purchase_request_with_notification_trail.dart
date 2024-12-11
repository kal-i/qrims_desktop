import '../../../navigation/data/data/models/notification.dart';
import '../../domain/entities/purchase_request_with_notification_trail.dart';
import 'purchase_request.dart';

class PurchaseRequestWithNotificationTrailModel
    extends PurchaseRequestWithNotificationTrailEntity {
  const PurchaseRequestWithNotificationTrailModel({
    required super.purchaseRequestEntity,
    required super.notificationEntities,
  });

  factory PurchaseRequestWithNotificationTrailModel.fromJson(
      Map<String, dynamic> json) {

    return PurchaseRequestWithNotificationTrailModel(
      purchaseRequestEntity: PurchaseRequestModel.fromJson(json['purchase_request']),
      notificationEntities: (json['notifications'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
    );
  }
}
