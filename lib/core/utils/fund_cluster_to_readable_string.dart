import '../enums/fund_cluster.dart';
String fundClusterToReadableString(FundCluster cluster) {
  // Convert enum value to string
  String clusterString = cluster.toString().split('.').last;

  // Replace underscores with spaces
  clusterString = clusterString.replaceAll('_', ' ');

  // Ensure "DepED" stays together
  clusterString = clusterString.replaceAllMapped(RegExp(r'depED'), (match) => 'DepED');

  // Add spaces between words by splitting at uppercase letters
  clusterString = clusterString.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'), (match) => '${match.group(1)} ${match.group(2)}');

  // Capitalize first letter of each word
  clusterString = clusterString.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');

  return clusterString;
}
