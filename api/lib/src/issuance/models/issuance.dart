import 'package:api/src/item/models/item.dart';
import 'package:api/src/purchase_request/model/purchase_request.dart';

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
    print('received item: ${json['item']}');
    final item = ItemWithStock.fromJson(json['item'] as Map<String, dynamic>);
    print('after conversion to obj: $item');

    return IssuanceItem(
      issuanceId: json['issuance_id'] as String,
      item: item,
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
    required this.items,
    required this.purchaseRequest,
    required this.receivingOfficer,
    required this.issuedDate,
    this.returnDate,
    this.isArchived = false,
  });

  final String id;
  final List<IssuanceItem> items;
  final PurchaseRequest purchaseRequest;
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
    required super.items,
    required super.purchaseRequest,
    required super.receivingOfficer,
    required super.issuedDate,
    super.returnDate,
    super.isArchived,
    required this.icsId,
    required this.sendingOfficer,
  });

  final String icsId;
  final Officer sendingOfficer; // represents the receive from

  factory InventoryCustodianSlip.fromJson(Map<String, dynamic> json) {
    return InventoryCustodianSlip(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((itemJson) =>
          IssuanceItem.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
      purchaseRequest: PurchaseRequest.fromJson(
        json['purchase_request'] as Map<String, dynamic>
      ),
      receivingOfficer: Officer.fromJson(
        json['receiving_officer'] as Map<String, dynamic>
      ),
      issuedDate: json['issued_date'] is String
          ? DateTime.parse(json['issued_date'] as String)
          : json['issued_date'] as DateTime,
      returnDate: json['return_date'] is String
          ? DateTime.parse(json['return_date'] as String)
          : json['return_date'] as DateTime,
      isArchived: json['is_archived'] as bool,
      icsId: json['ics_id'] as String,
      sendingOfficer: Officer.fromJson(
        json['sending_officer'] as Map<String, dynamic>
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_request': purchaseRequest.toJson(),
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
