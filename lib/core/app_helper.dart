import 'package:intl/intl.dart';

class AppHelper{
  static String formatAmount(String amount) {
    if (amount.isEmpty) return '0';

    try {
      final number = double.parse(amount);
      // ✅ Keep decimals if present, up to 2 digits
      final formatter = NumberFormat("#,##0.##", "en_US");
      return formatter.format(number);
    } catch (e) {
      return amount; // fallback if parsing fails
    }
  }
}