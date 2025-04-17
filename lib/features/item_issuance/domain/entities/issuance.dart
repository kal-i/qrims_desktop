import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/issuance_status.dart';
import '../../../officer/domain/entities/officer.dart';
import '../../../purchase_request/domain/entities/purchase_request.dart';
import 'issuance_item.dart';

abstract class IssuanceEntity {
  const IssuanceEntity({
    required this.id,
    required this.issuedDate,
    this.returnDate,
    required this.items,
    //this.batchItems,
    this.purchaseRequestEntity,
    this.entity,
    this.fundCluster,
    this.receivingOfficerEntity,
    this.issuingOfficerEntity,
    this.receivedDate,
    required this.qrCodeImageData,
    this.status = IssuanceStatus.unreceived,
    this.isArchived = false,
  });

  final String id;
  final DateTime issuedDate;
  final DateTime? returnDate;
  final List<IssuanceItemEntity> items;
  //final List<BatchItemEntity>? batchItems;
  final PurchaseRequestEntity? purchaseRequestEntity;
  final Entity? entity;
  final FundCluster? fundCluster;
  final OfficerEntity? receivingOfficerEntity;
  final OfficerEntity? issuingOfficerEntity;
  final DateTime? receivedDate;
  final String qrCodeImageData;
  final IssuanceStatus status;
  final bool isArchived;
}
