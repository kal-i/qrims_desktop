import 'package:intl/intl.dart';

String documentDateFormatter(DateTime dateTime) {
  return DateFormat('MM/dd/yyyy').format(dateTime);
}
