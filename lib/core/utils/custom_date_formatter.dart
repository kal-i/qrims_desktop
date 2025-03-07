import 'package:intl/intl.dart';

String customDateFormatter(DateTime date) {
  return DateFormat('MMMM d, y').format(date);
}
