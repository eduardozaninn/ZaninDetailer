import 'package:intl/intl.dart';

class DateTimeUtils {
  // Brasil aboliu o horário de verão em 2019; -03:00 cobre a maior parte
  // do país (exceto Acre e parte do Amazonas, que usam -04:00).
  static const String _brazilUtcOffset = '-03:00';

  static String toIsoWithBrazilOffset(DateTime dateTime) {
    final formatted = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dateTime);
    return '$formatted$_brazilUtcOffset';
  }
}
