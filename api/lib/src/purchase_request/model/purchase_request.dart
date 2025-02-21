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

enum FulfillmentStatus {
  notFulfilled,
  partiallyFulfilled,
  fulfilled,
}

class RequestedItem {
  const RequestedItem({
    required this.id,
    required this.prId,
    required this.productName,
    required this.productDescription,
    this.specification,
    required this.unit,
    required this.quantity,
    required this.remainingQuantity,
    required this.unitCost,
    required this.totalCost,
    this.fulfillmentStatus = FulfillmentStatus.notFulfilled,
  });

  final int id;
  final String prId;
  final ProductName productName;
  final ProductDescription productDescription;
  final String? specification;
  final Unit unit;
  final int quantity;
  final int? remainingQuantity;
  final double unitCost;
  final double totalCost;
  final FulfillmentStatus fulfillmentStatus;

  factory RequestedItem.fromJson(Map<String, dynamic> json) {
    final unitString = json['unit'] as String;

    final unit = Unit.values.firstWhere(
      (e) => e.toString().split('.').last == unitString,
    );

    final productName = ProductName.fromJson({
      'product_name_id': json['product_name_id'],
      'product_name': json['product_name'],
    });

    final productDescription = ProductDescription.fromJson({
      'product_description_id': json['product_description_id'],
      'product_description': json['product_description'],
    });

    return RequestedItem(
      id: json['id'] as int,
      prId: json['pr_id'] as String,
      productName: productName,
      productDescription: productDescription,
      specification: json['specification'] as String?,
      unit: unit,
      quantity: json['quantity'] as int,
      remainingQuantity: json['remaining_quantity'] as int? ?? 0,
      unitCost: json['unit_cost'] is String
          ? double.parse(json['unit_cost'] as String)
          : json['unit_cost'] as double,
      totalCost: json['total_cost'] is String
          ? double.parse(json['total_cost'] as String)
          : json['total_cost'] as double,
      fulfillmentStatus: FulfillmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => FulfillmentStatus.notFulfilled,
      ), //
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pr_id': prId,
      'product_name': productName.toJson(),
      'product_description': productDescription.toJson(),
      'specification': specification,
      'unit': unit.toString().split('.').last,
      'quantity': quantity,
      'remaining_quantity': remainingQuantity,
      'unit_cost': unitCost,
      'total_cost': totalCost,
      'status': fulfillmentStatus.toString().split('.').last,
    };
  }
}

class PurchaseRequest {
  const PurchaseRequest({
    required this.id,
    required this.entity,
    required this.fundCluster,
    required this.office,
    this.responsibilityCenterCode,
    required this.date,
    required this.requestedItems,
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
  final List<RequestedItem> requestedItems;
  final String purpose;
  final Officer requestingOfficer;
  final Officer approvingOfficer;
  final PurchaseRequestStatus purchaseRequestStatus;
  final bool? isArchived;

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    print('pr json: $json');
    final fundClusterString = json['fund_cluster'] as String;
    final prStatusString = json['status'] as String;

    final fundCluster = FundCluster.values.firstWhere(
      (e) => e.toString().split('.').last == fundClusterString,
    );

    final prStatus = PurchaseRequestStatus.values.firstWhere(
      (e) => e.toString().split('.').last == prStatusString,
    );

    final entity = Entity.fromJson({
      'entity_id': json['entity_id'],
      'entity_name': json['entity_name'],
    });

    final office = Office.fromJson({
      'office_id': json['office_id'],
      'office_name': json['office_name'],
    });

    final requestedItems = (json['requested_items'] as List<dynamic>)
        .map((requestedItem) => RequestedItem.fromJson({
              'id': requestedItem['id'],
              'pr_id': requestedItem['pr_id'],
              'product_name_id': requestedItem['product_name']
                  ['product_name_id'],
              'product_name': requestedItem['product_name']['product_name'],
              'product_description_id': requestedItem['product_description']
                  ['product_description_id'],
              'product_description': requestedItem['product_description']
                  ['product_description'],
              'specification': requestedItem['specification'],
              'unit': requestedItem['unit'],
              'quantity': requestedItem['quantity'],
              'remaining_quantity': requestedItem['remaining_quantity'],
              'unit_cost': requestedItem['unit_cost'],
              'total_cost': requestedItem['total_cost'],
              'status': requestedItem['status'],
            }))
        .toList();

    final requestingOfficer = Officer.fromJson(
      json['requesting_officer'] as Map<String, dynamic>,
    );

    final approvingOfficer = Officer.fromJson(
      json['approving_officer'] as Map<String, dynamic>,
    );

    return PurchaseRequest(
      id: json['id'] as String,
      entity: entity,
      fundCluster: fundCluster,
      office: office,
      responsibilityCenterCode:
          json['responsibility_center_code'] as String? ?? '',
      date: json['date'] is String
          ? DateTime.parse(json['date'] as String)
          : json['date'] as DateTime,
      requestedItems: requestedItems,
      purpose: json['purpose'] as String,
      requestingOfficer: requestingOfficer,
      approvingOfficer: approvingOfficer,
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
      'requested_items': requestedItems
          .map((requestedItem) => requestedItem.toJson())
          .toList(),
      'purpose': purpose,
      'requesting_officer': requestingOfficer.toJson(),
      'approving_officer': approvingOfficer.toJson(),
      'status': purchaseRequestStatus.toString().split('.').last,
      'is_archived': isArchived,
    };
  }
}
