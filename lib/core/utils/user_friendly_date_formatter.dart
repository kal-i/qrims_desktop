import 'package:intl/intl.dart';

String userFriendlyDateFormatter(DateTime dateTime) {
  // Define the desired format
  final DateFormat formatter = DateFormat("MMM dd, yyyy \nHH:mm");

  // Format the DateTime object
  return formatter.format(dateTime);
}
