import 'package:intl/intl.dart';

String documentDateFormatter(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy').format(dateTime);
}