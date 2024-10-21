import '../enums/asset_sub_class.dart';

String readableEnumConverter(Object? enumValue) {
  String enumName = enumValue.toString().split('.').last;

  switch (enumValue) {
    case AssetSubClass.informationAndCommunicationTechnologyEquipment:
      return 'ICT Equipment';
    // Add other cases if necessary
    default:
      return enumName
          .replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
              (Match match) => '${match[1]} ${match[2]}')
          .replaceAll('_', ' ')
          .replaceAllMapped(
              RegExp(r'\b\w'), (Match match) => match[0]!.toUpperCase());
  }

  String readableString = enumName
      .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'), (Match match) => '${match[1]} ${match[2]}')
      .replaceAll('_', ' ')
      .replaceAllMapped(
          RegExp(r'\b\w'), (Match match) => match[0]!.toUpperCase());

  return readableString;
}
