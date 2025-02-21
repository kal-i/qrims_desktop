import '../issuance/models/issuance.dart';

extension FundClusterExtension on FundCluster {
  String get value {
    switch (this) {
      case FundCluster.depEDCentralOffice:
        return "CO";
      case FundCluster.depEDRegionalOffice:
        return "RO";
      case FundCluster.depEDDivisionOffice:
        return "DO";
      case FundCluster.depEDImplementingUnit:
        return "IU";
      case FundCluster.donatedByLGU:
        return "DL";
      case FundCluster.donatedByOtherEntity:
        return "DEO";
      case FundCluster.assetIsOwnedByLGU:
        return "OL";
      case FundCluster.assetIsOwnedByOtherEntity:
        return "OOE";
      case FundCluster.assetIsLeased:
        return "AL";
      case FundCluster.unknown:
        return "UNKNOWN";
    }
  }
}
