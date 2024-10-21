import 'package:api/src/item/models/item.dart';

import '../../entity/model/entity.dart';
import '../../organization_management/models/officer.dart';

enum FundCluster {
  depEDCentralOffice,
  depEDRegionalOffice,
  depEDDivisionOffice,
  depEDImplementingUnit,
  donatedByLGU,
  donatedByOtherEntity,
  assetIsOwnedByLGU,
  assetIsOwnedByOtherEntity,
  assetIsLeased,
}

class IssuanceItem {
  const IssuanceItem({
    required this.issuanceId,
    required this.item,
    required this.quantity,
  });

  final String issuanceId;
  final ItemWithStock item;
  final int quantity;

  factory IssuanceItem.fromJson(Map<String, dynamic> json) {
    return IssuanceItem(
      issuanceId: json['issuance_id'] as String,
      item: ItemWithStock.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issuance_id': issuanceId,
      'item': item.toJson(),
      'quantity': quantity,
    };
  }
}

/// Represents an abstract entity base class for issuance
abstract class Issuance {
  const Issuance({
    required this.id,
    required this.entity,
    required this.fundCluster,
    required this.items,
    required this.purchaseRequestId,
    required this.receivingOfficer,
    required this.issuedDate,
    this.returnDate,
    this.isArchived = false,
  });

  final String id;
  final Entity entity;
  final FundCluster fundCluster;
  final List<IssuanceItem> items;
  final String purchaseRequestId;
  final Officer receivingOfficer;
  final DateTime issuedDate;
  final DateTime? returnDate;
  final bool isArchived;
}

/// ics
/// ics no: sphv-yyyy-mm-n
/// ris no: yyyy-mm-n
/// par no: yyyy-mm-n
/// y represents the year
/// m for month
/// n for the no. of ris for that month
///
/// we need to get the last no. in the table and increment it by one
/// this will reset back when a new month arrives

/// should I extend it or just create a field for it?
/// Concrete entity of issuance
class InventoryCustodianSlip extends Issuance {
  const InventoryCustodianSlip({
    required super.id, // refer to the parent/ issuance id
    required super.entity,
    required super.fundCluster,
    required super.items,
    required super.purchaseRequestId,
    required super.receivingOfficer,
    required super.issuedDate,
    super.returnDate,
    super.isArchived,
    required this.icsId,
    required this.sendingOfficer,
  });

  final String icsId;
  final Officer sendingOfficer;

  factory InventoryCustodianSlip.fromJson(Map<String, dynamic> json) {
    final fundClusterString = json['fund_cluster'] as String;
    final fundCluster = FundCluster.values.firstWhere(
      (e) => e.toString().split('.').last == fundClusterString,
    );

    return InventoryCustodianSlip(
      id: json['id'] as String,
      entity: Entity.fromJson({
        'entity_id': json['entity_id'],
        'entity_name': json['entity_name'],
      }),
      fundCluster: fundCluster,
      items: (json['items'] as List<dynamic>)
          .map((itemJson) =>
          IssuanceItem.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
      purchaseRequestId: json['purchase_request_id'] as String,
      receivingOfficer: Officer.fromJson({
        'id': json['receiving_officer_id'],
        'user_id': json['receiving_officer_user_id'],
        'name': json['receiving_officer_name'],
        'position_id': json['receiving_officer_position_id'],
        'office_name': json['receiving_officer_office_name'],
        'position_name': json['receiving_officer_position_name'],
        'is_archived': json['receiving_officer_is_archived'],
      }),
      issuedDate: json['issued_date'] is String
          ? DateTime.parse(json['issued_date'] as String)
          : json['issued_date'] as DateTime,
      returnDate: json['return_date'] is String
          ? DateTime.parse(json['return_date'] as String)
          : json['return_date'] as DateTime,
      isArchived: json['is_archived'] as bool,
      icsId: json['ics_id'] as String,
      sendingOfficer: Officer.fromJson({
        'id': json['sending_officer_id'],
        'user_id': json['sending_officer_user_id'],
        'name': json['sending_officer_name'],
        'position_id': json['sending_officer_position_id'],
        'office_name': json['sending_officer_office_name'],
        'position_name': json['sending_officer_position_name'],
        'is_archived': json['sending_officer_is_archived'],
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity': entity.toJson(),
      'fund_cluster': fundCluster.toString().split('.').last,
      'purchase_request_id': purchaseRequestId,
      'receiving_officer': receivingOfficer.toJson(),
      'issued_date': issuedDate,
      'return_date': returnDate,
      'is_archived': isArchived,
      'ics_id': icsId,
      'items': items.map((item) => item.toJson()).toList(),
      'sending_officer': sendingOfficer.toJson(),
    };
  }
}

// when items are return, then just create another issuance doc?

// class PropertyAcknowledgementReceipt extends Issuance {
//   const PropertyAcknowledgementReceipt({
//     required super.id, // refer to the parent/ issuance id
//     required super.entityId,
//     required super.fundClusterId,
//     required super.purchaseRequestId,
//     required super.quantity,
//     required super.receivingOfficerId,
//     required super.issuedDate,
//     required this.parId,
//     required this.propertyNumber,
//     required this.sendingOfficerId,
//   });
//
//   final String parId;
//   final String propertyNumber;
//   final String sendingOfficerId;
// }
//
// class RequisitionSlip extends Issuance {
//   const RequisitionSlip({
//     required super.id, // refer to the parent/ issuance id
//     required super.entityId,
//     required super.fundClusterId,
//     required super.quantity,
//     required super.receivingOfficerId,
//     required super.issuedDate,
//     required super.purchaseRequestId,
//   });
//
//   final String risId;
//   final String divisionId;
//   final String responsibilityCenterCode;
//   final String officeId;
//   final String itemId;
//   final bool isStockAvailable;
//   final int quantityLeft;
//   final String remarks;
//   final String purpose;
//   final String requestingOfficerId;
//   final String approvingOfficerId;
//   final String issuingOfficerId;
// }
