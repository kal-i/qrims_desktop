import 'package:intl/intl.dart';

String dateFormatter(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd').format(dateTime);
}