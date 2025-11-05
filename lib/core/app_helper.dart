import 'package:cloud_firestore/cloud_firestore.dart';
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

  static String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
  static String formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }
}