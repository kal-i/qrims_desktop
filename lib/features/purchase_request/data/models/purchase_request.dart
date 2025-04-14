import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/purchase_request_status.dart';
import '../../../officer/data/models/office.dart';
import '../../../officer/data/models/officer.dart';
import '../../domain/entities/purchase_request.dart';
import 'requested_item.dart';

class EntityModel extends Entity {
  const EntityModel({
    required super.id,
    required super.name,
  });

  factory EntityModel.fromJson(Map<String, dynamic> json) {
    return EntityModel(
      id: json['entity_id'] as String,
      name: json['entity_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entity_id': id,
      'entity_name': name,
    };
  }
}

class PurchaseRequestModel extends PurchaseRequestEntity {
  const PurchaseRequestModel({
    required super.id,
    required super.entity,
    required super.fundCluster,
    required super.officeEntity,
    super.responsibilityCenterCode,
    required super.date,
    required super.requestedItemEntities,
    required super.purpose,
    required super.requestingOfficerEntity,
    required super.approvingOfficerEntity,
    super.purchaseRequestStatus,
    super.isArchived,
  });

  factory PurchaseRequestModel.fromJson(Map<String, dynamic> json) {
    final fundClusterString = json['fund_cluster'] as String;
    final prStatusString = json['status'] as String;

    final fundCluster = FundCluster.values.firstWhere(
      (e) =>
          e.toString().toLowerCase().split('.').last ==
          fundClusterString.toLowerCase(),
    );

    final prStatus = PurchaseRequestStatus.values.firstWhere(
      (e) => e.toString().split('.').last == prStatusString,
    );

    final entity = EntityModel.fromJson(json['entity']);

    final office = OfficeModel.fromJson({
      'id': json['office']['id'],
      'name': json['office']['name'],
    });

    final requestedItems =
        (json['requested_items'] as List<dynamic>).map((requestedItem) {
      final reqItem = RequestedItemModel.fromJson(requestedItem);
      return reqItem;
    }).toList();

    final receivingOfficer = OfficerModel.fromJson(json['requesting_officer']);

    final approvingOfficer = OfficerModel.fromJson(json['approving_officer']);

    final pr = PurchaseRequestModel(
      id: json['id'] as String,
      entity: entity,
      fundCluster: fundCluster,
      officeEntity: office,
      responsibilityCenterCode: json['responsibility_center_code'],
      date: json['date'] is String
          ? DateTime.parse(json['date'] as String)
          : json['date'] as DateTime,
      requestedItemEntities: requestedItems,
      purpose: json['purpose'] as String,
      requestingOfficerEntity: receivingOfficer,
      approvingOfficerEntity: approvingOfficer,
      purchaseRequestStatus: prStatus,
      isArchived: json['is_archived'] as bool,
    );

    return pr;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity': (entity as EntityModel).toJson(),
      'fund_cluster': fundCluster.toString().split('.').last,
      'office': (officeEntity as OfficeModel).toJson(),
      'responsibility_center_code': responsibilityCenterCode,
      'date': date,
      'requested_items': requestedItemEntities
          .map(
              (requestedItem) => (requestedItem as RequestedItemModel).toJson())
          .toList(),
      'purpose': purpose,
      'requesting_officer': (requestingOfficerEntity as OfficerModel).toJson(),
      'approving_officer': (approvingOfficerEntity as OfficerModel).toJson(),
      'status': purchaseRequestStatus.toString().split('.').last,
      'is_archived': isArchived,
    };
  }
}
