import '../../../../core/enums/fund_cluster.dart';
import '../../../../core/enums/purchase_request_status.dart';
import '../../../../core/enums/unit.dart';
import '../../../item_inventory/data/models/product_description.dart';
import '../../../item_inventory/data/models/product_name.dart';
import '../../../officer/data/models/office.dart';
import '../../../officer/data/models/officer.dart';
import '../../domain/entities/purchase_request.dart';

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
    required super.productNameEntity,
    required super.productDescriptionEntity,
    required super.unit,
    required super.quantity,
    super.remainingQuantity,
    required super.unitCost,
    required super.totalCost,
    required super.purpose,
    required super.requestingOfficerEntity,
    required super.approvingOfficerEntity,
    super.purchaseRequestStatus,
    super.isArchived,
  });

  factory PurchaseRequestModel.fromJson(Map<String, dynamic> json) {
    final fundClusterString = json['fund_cluster'] as String;
    final unitString = json['unit'] as String;
    final prStatusString = json['status'] as String;

    final fundCluster = FundCluster.values.firstWhere(
          (e) => e.toString().toLowerCase().split('.').last == fundClusterString.toLowerCase(),
    );

    final unit = Unit.values.firstWhere(
          (e) => e.toString().split('.').last == unitString,
      orElse: () => Unit.undetermined,
    );

    final prStatus = PurchaseRequestStatus.values.firstWhere(
      (e) => e.toString().split('.').last == prStatusString,
    );

    final entity = EntityModel.fromJson(json['entity']);

    final office = OfficeModel.fromJson({
      'id': json['office']['office_id'],
      'name': json['office']['office_name'],
    });

    final productName = ProductNameModel.fromJson(json['product_name']);

    final productDescription = ProductDescriptionModel.fromJson(json['product_description']);

    final receivingOfficer = OfficerModel.fromJson(json['requesting_officer']);

    final approvingOfficer = OfficerModel.fromJson(json['approving_officer']);

    return PurchaseRequestModel(
      id: json['id'] as String,
      entity: entity,
      fundCluster: fundCluster,
      officeEntity: office,
      responsibilityCenterCode: json['responsibility_center_code'],
      date: json['date'] is String ? DateTime.parse(json['date'] as String) : json['date'] as DateTime,
      productNameEntity: productName,
      productDescriptionEntity: productDescription,
      unit: unit,
      quantity: json['quantity'] as int,
      remainingQuantity: json['remaining_quantity'] as int,
      unitCost: json['unit_cost'] as double,
      totalCost: json['total_cost'] as double,
      purpose: json['purpose'] as String,
      requestingOfficerEntity: receivingOfficer,
      approvingOfficerEntity: approvingOfficer,
      purchaseRequestStatus: prStatus,
      isArchived: json['is_archived'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity': (entity as EntityModel).toJson(),
      'fund_cluster': fundCluster.toString().split('.').last,
      'office': (officeEntity as OfficeModel).toJson(),
      'responsibility_center_code': responsibilityCenterCode,
      'date': date,
      'product_name': (productNameEntity as ProductNameModel).toJson(),
      'product_description':
          (productDescriptionEntity as ProductDescriptionModel).toJson(),
      'unit': unit.toString().split('.').last,
      'quantity': quantity,
      'remaining_quantity': remainingQuantity,
      'unit_cost': unitCost,
      'total_cost': totalCost,
      'purpose': purpose,
      'requesting_officer': (requestingOfficerEntity as OfficerModel).toJson(),
      'approving_officer': (approvingOfficerEntity as OfficerModel).toJson(),
      'status': purchaseRequestStatus.toString().split('.').last,
      'is_archived': isArchived,
    };
  }
}
