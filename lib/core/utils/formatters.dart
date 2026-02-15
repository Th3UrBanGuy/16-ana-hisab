import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  // Currency Formatter
  static String formatCurrency(double amount) {
    return '${AppConstants.currency}${amount.toStringAsFixed(2)}';
  }
  
  // Date Formatter
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  // Time Formatter
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
  
  // DateTime Formatter
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} • ${formatTime(dateTime)}';
  }
  
  // Compact Date (for receipts)
  static String formatCompactDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }
  
  // Percentage Formatter
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }
  
  // Stock Level Color
  static String getStockStatus(int quantity) {
    if (quantity == 0) return 'Out of Stock';
    if (quantity < 10) return 'Low Stock';
    return 'In Stock';
  }
  
  // Generate Invoice Number
  static String generateInvoiceNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(7);
    return '#$timestamp';
  }
  
  // Generate Membership Code
  static String generateMembershipCode(int customerId) {
    return 'MEM${customerId.toString().padLeft(6, '0')}';
  }
}
