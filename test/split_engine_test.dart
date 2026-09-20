import 'package:flutter_test/flutter_test.dart';
import 'package:splitpe/services/split_engine.dart';

void main() {
  group('SplitEngine.calculateTrancheAmounts edge cases', () {
    test('returns one tranche at exact safe cap', () {
      final amounts = SplitEngine.calculateTrancheAmounts(
        totalAmount: SplitEngine.safeTrancheCap,
        randomize: false,
      );

      expect(amounts, [1999.0]);
    });

    test('splits exact double cap into two cap-sized tranches', () {
      final amounts = SplitEngine.calculateTrancheAmounts(
        totalAmount: 3998.0,
        randomize: false,
      );

      expect(amounts, [1999.0, 1999.0]);
    });

    test('creates three tranches just above double cap', () {
      final amounts = SplitEngine.calculateTrancheAmounts(
        totalAmount: 3999.0,
        randomize: false,
      );

      expect(amounts.length, 3);
      expect(
        amounts.every(
          (amount) =>
              amount > 0 && amount <= SplitEngine.safeTrancheCap,
        ),
        isTrue,
      );
      expect(
        amounts.fold<double>(0, (sum, amount) => sum + amount),
        3999.0,
      );
    });

    test('returns empty list for zero and negative totals', () {
      expect(
        SplitEngine.calculateTrancheAmounts(totalAmount: 0),
        isEmpty,
      );

      expect(
        SplitEngine.calculateTrancheAmounts(totalAmount: -100),
        isEmpty,
      );
    });

    test('respects custom tranche cap', () {
      const cap = 500.0;

      final amounts = SplitEngine.calculateTrancheAmounts(
        totalAmount: 1200.0,
        maxTranche: cap,
        randomize: false,
      );

      expect(amounts.length, 3);
      expect(
        amounts.every((amount) => amount > 0 && amount <= cap),
        isTrue,
      );
      expect(
        amounts.fold<double>(0, (sum, amount) => sum + amount),
        1200.0,
      );
    });
  });
}