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
    expect(order.tranches.every((t) => t.amount <= 2000), isTrue);
    expect(order.mdrStandard, 30.0); // 0.4% of 7500 = 30
    expect(order.mdrSavings, 30.0); // 100% saved
  });

  testWidgets('SplitPeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SplitPeApp());
    expect(find.text('SPLIT'), findsOneWidget);
    expect(find.text('PE'), findsOneWidget);
  });
}
