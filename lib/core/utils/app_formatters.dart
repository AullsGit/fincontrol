import 'package:intl/intl.dart';

class AppFormatters {
  static String formatMZN(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_MZ',
      symbol: 'MZN ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  static String formatMZNCompact(double value) {
    if (value >= 1000000) {
      return 'MZN ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'MZN ${(value / 1000).toStringAsFixed(1)}K';
    }
    return 'MZN ${value.toStringAsFixed(0)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'pt').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM', 'pt').format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy', 'pt').format(date);
  }

  static String formatMonthShort(DateTime date) {
    return DateFormat('MMM yyyy', 'pt').format(date);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return 'há ${diff.inDays} dia(s)';
    if (diff.inHours > 0) return 'há ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'há ${diff.inMinutes}min';
    return 'agora';
  }
}