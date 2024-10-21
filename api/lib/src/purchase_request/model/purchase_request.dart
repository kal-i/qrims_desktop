import '../../entity/model/entity.dart';
import '../../issuance/models/issuance.dart';
import '../../item/models/item.dart';
import '../../organization_management/models/office.dart';
import '../../organization_management/models/officer.dart';

enum PurchaseRequestStatus {
  cancelled,
  pending,
  partiallyFulfilled,
  fulfilled,
}

class PurchaseRequest {
  const PurchaseRequest({
    required this.id,
    required this.entity,
    required this.fundCluster,
    required this.office,
    this.responsibilityCenterCode,
    required this.date,
    required this.productName,
    required this.productDescription,
    required this.unit,
    required this.quantity,
    this.remainingQuantity,
    required this.unitCost,
    required this.totalCost,
    required this.purpose,
    required this.requestingOfficer,
    required this.approvingOfficer,
    this.purchaseRequestStatus = PurchaseRequestStatus.pending,
    this.isArchived = false,
  });

  final String id;
  final Entity entity;
  final FundCluster fundCluster;
  final Office office;
  final String? responsibilityCenterCode;
  final DateTime date;
  final ProductName productName;
  final ProductDescription productDescription;
  final Unit unit;
  final int quantity;
  final int? remainingQuantity; // to track if qty not yet fulfilled
  final double unitCost;
  final double totalCost;
  final String purpose;
  final Officer requestingOfficer;
  final Officer approvingOfficer;
  final PurchaseRequestStatus purchaseRequestStatus;
  final bool? isArchived;

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    final fundClusterString = json['fund_cluster'] as String;
    final unitString = json['unit'] as String;
    final prStatusString = json['status'] as String;

    final fundCluster = FundCluster.values.firstWhere(
      (e) => e.toString().split('.').last == fundClusterString,
    );

    final unit = Unit.values.firstWhere(
      (e) => e.toString().split('.').last == unitString,
    );

    final prStatus = PurchaseRequestStatus.values.firstWhere(
      (e) => e.toString().split('.').last == prStatusString,
    );

    return PurchaseRequest(
      id: json['id'] as String,
      entity: Entity.fromJson({
        'entity_id': json['entity_id'],
        'entity_name': json['entity_name'],
      }),
      fundCluster: fundCluster,
      office: Office.fromJson({
        'office_id': json['office_id'],
        'office_name': json['office_name'],
      }),
      responsibilityCenterCode:
          json['responsibility_center_code'] as String? ?? '',
      date: json['date'] is String
          ? DateTime.parse(json['date'] as String)
          : json['date'] as DateTime,
      productName: ProductName.fromJson({
        'product_name_id': json['product_name_id'],
        'product_name': json['product_name'],
      }),
      productDescription: ProductDescription.fromJson({
        'product_description_id': json['product_description_id'],
        'product_description': json['product_description'],
      }),
      unit: unit,
      quantity: json['quantity'] as int,
      remainingQuantity: json['remaining_quantity'] as int? ?? 0,
      unitCost: json['unit_cost'] is String
          ? double.parse(json['unit_cost'] as String)
          : json['unit_cost'] as double,
      totalCost: json['total_cost'] is String
          ? double.parse(json['total_cost'] as String)
          : json['total_cost'] as double,
      purpose: json['purpose'] as String,
      requestingOfficer: Officer.fromJson({
        'id': json['requesting_officer_id'],
        'user_id': json['requesting_officer_user_id'],
        'name': json['requesting_officer_name'],
        'position_id': json['requesting_officer_position_id'],
        'office_name': json['requesting_officer_office_name'],
        'position_name': json['requesting_officer_position_name'],
        'is_archived': json['requesting_officer_is_archived'],
      }),
      approvingOfficer: Officer.fromJson({
        'id': json['approving_officer_id'],
        'user_id': json['approving_officer_user_id'],
        'name': json['approving_officer_name'],
        'position_id': json['approving_officer_position_id'],
        'office_name': json['approving_officer_office_name'],
        'position_name': json['approving_officer_position_name'],
        'is_archived': json['approving_officer_is_archived'],
      }),
      purchaseRequestStatus: prStatus,
      isArchived: json['is_archived'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity': entity.toJson(),
      'fund_cluster': fundCluster.toString().split('.').last,
      'office': office.toJson(),
      'responsibility_center_code': responsibilityCenterCode,
      'date': date.toIso8601String(),
      'product_name': productName.toJson(),
      'product_description': productDescription.toJson(),
      'unit': unit.toString().split('.').last,
      'quantity': quantity,
      'remaining_quantity': remainingQuantity,
      'unit_cost': unitCost,
      'total_cost': totalCost,
      'purpose': purpose,
      'requesting_officer': requestingOfficer.toJson(),
      'approving_officer': approvingOfficer.toJson(),
      'status': purchaseRequestStatus.toString().split('.').last,
      'is_archived': isArchived,
    };
  }
}
