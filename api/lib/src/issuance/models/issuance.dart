class FundCluster {
  const FundCluster({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}

/// Represents the Entity or Agency
class Entity {
  const Entity({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;
}

/// Represents the office where the officer
/// is associated with
class Office {
  const Office({
    required this.id,
    required this.officeName,
  });

  final int id;
  final String officeName;
}

class Position {
  const Position({
    required this.id,
    required this.positionName,
    required this.positionDescription,
  });

  final int id;
  final String positionName;
  final String positionDescription;
}

/// Represents the officer associated within
/// the item issuance or document report
class Officer {
  const Officer({
    required this.id,
    required this.name,
    required this.officeId,
    required this.positionId,
  });

  final int id;
  final String name;
  final int officeId;
  final int positionId;
}

/// Represents an abstract entity base class for issuance
abstract class Issuance {
  const Issuance({
    required this.id,
    required this.entityId,
    required this.fundClusterId,
    required this.itemId,
    required this.quantity,
    required this.receivingOfficerId,
    required this.issuedDate,
  });

  final int id;
  final int entityId;
  final int fundClusterId;
  final int itemId;
  final int quantity;
  final Officer receivingOfficerId;
  final DateTime issuedDate;
}

/// Concrete implementation of issuance
class InventoryCustodianSlip extends Issuance {
  const InventoryCustodianSlip({
    required super.id, // refer to the parent/ issuance id
    required super.entityId,
    required super.fundClusterId,
    required super.itemId,
    required super.quantity,
    required super.receivingOfficerId,
    required super.issuedDate,
    required this.icsId,
    required this.issuanceId,
    required this.sendingOfficerId,
  });

  final String icsId;
  final int issuanceId;
  final int sendingOfficerId;
}
