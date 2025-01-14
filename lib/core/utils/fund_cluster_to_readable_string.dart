import '../enums/fund_cluster.dart';

extension FundClusterExtension on FundCluster {
  String toReadableString() {
    switch (this) {
      case FundCluster.depEDCentralOffice:
        return "DepEd Central Office";
      case FundCluster.depEDRegionalOffice:
        return "DepEd Regional Office";
      case FundCluster.depEDDivisionOffice:
        return "DepEd Division Office";
      case FundCluster.depEDImplementingUnit:
        return "DepEd Implementing Unit";
      case FundCluster.donatedByLGU:
        return "Donated by LGU";
      case FundCluster.donatedByOtherEntity:
        return "Donated by Other Entity";
      case FundCluster.assetIsOwnedByLGU:
        return "Asset is Owned by LGU";
      case FundCluster.assetIsOwnedByOtherEntity:
        return "Asset is Owned by Other Entity";
      case FundCluster.assetIsLeased:
        return "Asset is Leased";
      case FundCluster.unknown:
      default:
        return "Unknown";
    }
  }
}
