import 'package:flutter_test/flutter_test.dart';
import 'package:splitpe/services/currency_formatter.dart';

void main() {
  group('IndianNumberFormat Tests', () {
    test('Formats integers in Indian Numbering System', () {
      expect(IndianNumberFormat.format(0), '0');
      expect(IndianNumberFormat.format(50), '50');
      expect(IndianNumberFormat.format(999), '999');
      expect(IndianNumberFormat.format(1000), '1,000');
      expect(IndianNumberFormat.format(2450), '2,450');
      expect(IndianNumberFormat.format(3200), '3,200');
      expect(IndianNumberFormat.format(3850), '3,850');
      expect(IndianNumberFormat.format(7500), '7,500');
      expect(IndianNumberFormat.format(10000), '10,000');
      expect(IndianNumberFormat.format(100000), '1,00,000');
      expect(IndianNumberFormat.format(1500000), '15,00,000');
      expect(IndianNumberFormat.format(10000000), '1,00,00,000');
    });

    test('Formats decimals in Indian Numbering System', () {
      expect(IndianNumberFormat.formatWithDecimals(18.17, 2), '18.17');
      expect(IndianNumberFormat.formatWithDecimals(2.77, 2), '2.77');
      expect(IndianNumberFormat.formatWithDecimals(2450.5, 2), '2,450.50');
      expect(IndianNumberFormat.formatWithDecimals(1500000.75, 2), '15,00,000.75');
    });

    test('Formats Rupee string correctly', () {
      expect(IndianNumberFormat.formatRupee(3850), '₹3,850');
      expect(IndianNumberFormat.formatRupee(18.17, showDecimals: true), '₹18.17');
    });

    test('Parses amounts with or without commas cleanly', () {
      expect(IndianNumberFormat.parseAmount('3,850'), 3850.0);
      expect(IndianNumberFormat.parseAmount('15,00,000'), 1500000.0);
      expect(IndianNumberFormat.parseAmount(' 2,450.50 '), 2450.5);
      expect(IndianNumberFormat.parseAmount(''), 0.0);
      expect(IndianNumberFormat.parseAmount(null), 0.0);
    });
  });
}
