import '../../../navigation/domain/domain/entities/notification.dart';
import 'purchase_request.dart';

class PurchaseRequestWithNotificationTrailEntity {
  const PurchaseRequestWithNotificationTrailEntity({
    required this.purchaseRequestEntity,
    required this.notificationEntities,
  });

  final PurchaseRequestEntity purchaseRequestEntity;
  final List<NotificationEntity> notificationEntities;
}
