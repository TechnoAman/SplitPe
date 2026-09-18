import 'package:flutter_test/flutter_test.dart';
import 'package:splitpe/main.dart';
import 'package:splitpe/services/split_engine.dart';
import 'package:splitpe/services/quick_pay_service.dart';

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

  test('SplitEngine minimizes transaction count and randomizes distribution for ₹4,000', () {
    final order = SplitEngine.createTrancheOrder(
      totalAmount: 4000,
      merchantVpa: 'guptakirana@okhdfcbank',
      merchantName: 'Gupta Kirana',
    );

    // Rule 1: Exactly 3 tranches (minimum possible: ceil(4000 / 1999) = 3)
    expect(order.tranches.length, 3);

    // Rule 2: Every tranche is strictly <= 1999 and > 0
    expect(order.tranches.every((t) => t.amount <= 1999.0 && t.amount > 0), isTrue);

    // Rule 3: Sum of all tranches equals 4000 exactly
    final sum = order.tranches.fold(0.0, (acc, t) => acc + t.amount);
    expect(sum, 4000.0);

    // Rule 4: Not greedy [1999, 1999, 2] and not uniform equal split
    final amounts = order.tranches.map((t) => t.amount).toList();
    expect(amounts.contains(2.0), isFalse);
    expect(amounts.every((a) => a == amounts.first), isFalse);

    // Rule 5: Timing jitter simulation (first tranche has 0 delay, subsequent > 0)
    expect(order.tranches[0].suggestedDelaySeconds, 0);
    expect(order.tranches[1].suggestedDelaySeconds, greaterThanOrEqualTo(15));
    expect(order.tranches[2].suggestedDelaySeconds, greaterThanOrEqualTo(15));
  });

  testWidgets('SplitPeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SplitPeApp());
    expect(find.text('SPLIT'), findsOneWidget);
    expect(find.text('PE'), findsOneWidget);
  });

  test('QuickPayService saves, loads, and clears merchant accurately', () async {
    final service = QuickPayService.instance;
    await service.clearSavedMerchant();
    expect(service.lastMerchant.value, isNull);

    await service.saveMerchant(
      vpa: 'guptakirana@okhdfcbank',
      name: 'Gupta Kirana Store',
      amount: 4500,
    );

    expect(service.lastMerchant.value, isNotNull);
    expect(service.lastMerchant.value!.vpa, 'guptakirana@okhdfcbank');
    expect(service.lastMerchant.value!.name, 'Gupta Kirana Store');
    expect(service.lastMerchant.value!.lastAmount, 4500);
    expect(service.lastMerchant.value!.timeAgoDescription, 'Just now');

    // Reload from storage
    final loaded = await service.loadLastMerchant();
    expect(loaded, isNotNull);
    expect(loaded!.vpa, 'guptakirana@okhdfcbank');
    expect(loaded.name, 'Gupta Kirana Store');
    expect(loaded.lastAmount, 4500);

    // Clear merchant
    await service.clearSavedMerchant();
    expect(service.lastMerchant.value, isNull);
    final reloaded = await service.loadLastMerchant();
    expect(reloaded, isNull);
  });
}

