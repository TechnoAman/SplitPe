import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Utility class for formatting numbers and currencies using the Indian numbering system.
class IndianNumberFormat {
  static final NumberFormat _intFormatter = NumberFormat('#,##,##0', 'en_IN');
  static final NumberFormat _decimalFormatter = NumberFormat('#,##,##0.00', 'en_IN');

  /// Formats a number with Indian commas without decimal digits (e.g., 3850 -> "3,850", 1500000 -> "15,00,000")
  static String format(num? value) {
    if (value == null) return '0';
    return _intFormatter.format(value.round());
  }

  /// Formats a number with Indian commas and a specified number of decimal digits (default 2)
  static String formatWithDecimals(num? value, [int decimals = 2]) {
    if (value == null) return decimals > 0 ? '0.${'0' * decimals}' : '0';
    if (decimals == 0) return _intFormatter.format(value);
    if (decimals == 2) return _decimalFormatter.format(value);
    final formatter = NumberFormat('#,##,##0.${'0' * decimals}', 'en_IN');
    return formatter.format(value);
  }

  /// Formats with Rupee symbol (e.g., "₹3,850" or "₹18.17")
  static String formatRupee(num? value, {bool showDecimals = false, int decimals = 2}) {
    if (value == null) return '₹0';
    if (showDecimals) {
      return '₹${formatWithDecimals(value, decimals)}';
    }
    return '₹${format(value)}';
  }

  /// Parses text that may contain commas and returns double
  static double parseAmount(String? text, [double defaultValue = 0.0]) {
    if (text == null || text.trim().isEmpty) return defaultValue;
    final cleaned = text.replaceAll(',', '').trim();
    return double.tryParse(cleaned) ?? defaultValue;
  }
}

/// Custom TextInputFormatter that formats numbers in real-time with Indian commas while keeping cursor in place.
class IndianCurrencyInputFormatter extends TextInputFormatter {
  final bool allowDecimals;

  IndianCurrencyInputFormatter({this.allowDecimals = true});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Strip everything except digits and decimal point
    String raw = newValue.text.replaceAll(',', '');
    if (!allowDecimals) {
      raw = raw.replaceAll('.', '');
    }

    // Only allow one decimal point
    final parts = raw.split('.');
    if (parts.length > 2) {
      return oldValue;
    }

    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    // Check if integer part is valid number
    if (intPart.isNotEmpty && int.tryParse(intPart) == null) {
      return oldValue;
    }

    final formattedInt = intPart.isEmpty
        ? ''
        : IndianNumberFormat.format(int.parse(intPart));

    String formattedText = formattedInt;
    if (parts.length > 1) {
      formattedText += '.$decPart';
    }

    // Calculate cursor position based on raw character count before cursor
    final oldCursorPos = newValue.selection.baseOffset;
    final rawCharsBeforeCursor = newValue.text
        .substring(0, oldCursorPos.clamp(0, newValue.text.length))
        .replaceAll(',', '')
        .length;

    int newCursorPos = 0;
    int rawCharsSeen = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (rawCharsSeen == rawCharsBeforeCursor) {
        break;
      }
      if (formattedText[i] != ',') {
        rawCharsSeen++;
      }
      newCursorPos = i + 1;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: newCursorPos.clamp(0, formattedText.length),
      ),
    );
  }
}
