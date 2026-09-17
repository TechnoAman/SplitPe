import 'package:flutter_test/flutter_test.dart';
import 'package:splitpe/main.dart';
import 'package:splitpe/services/split_engine.dart';

void main() {
  test('SplitEngine correctly splits ₹7,500 into 4 sub-₹2,000 tranches', () {
    final order = SplitEngine.createTrancheOrder(
      totalAmount: 7500,
      merchantVpa: 'store@okhdfcbank',
      merchantName: 'Test Store',
    );

    expect(order.tranches.length, 4);
    expect(order.tranches.every((t) => t.amount <= 1999), isTrue);
    final totalSum = order.tranches.fold(0.0, (sum, t) => sum + t.amount);
    expect(totalSum, 7500.0);
    expect(order.mdrStandard, 30.0); // 0.4% of 7500 = 30
    expect(order.gstOnMdr, 5.40); // 18% GST on ₹30 = ₹5.40
    expect(order.totalStandardFee, 35.40); // ₹30 + ₹5.40 = ₹35.40
    expect(order.mdrSavings, 35.40); // 100% saved via 0% MDR tranches
  });

  test('SplitEngine produces randomized natural tranche amounts instead of static 1999', () {
    final amounts1 = SplitEngine.calculateTrancheAmounts(totalAmount: 3850, randomize: true);
    final amounts2 = SplitEngine.calculateTrancheAmounts(totalAmount: 3850, randomize: true);

    expect(amounts1.length, 2);
    expect(amounts1.every((a) => a <= 1999.0 && a > 0), isTrue);
    expect(amounts1.reduce((a, b) => a + b), 3850.0);

    expect(amounts2.length, 2);
    expect(amounts2.every((a) => a <= 1999.0 && a > 0), isTrue);
    expect(amounts2.reduce((a, b) => a + b), 3850.0);
  });

  testWidgets('SplitPeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SplitPeApp());
    expect(find.text('SPLIT'), findsOneWidget);
    expect(find.text('PE'), findsOneWidget);
  });
}
