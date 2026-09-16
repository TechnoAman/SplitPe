import 'tranche.dart';

class SplitOrder {
  final String orderId;
  final String merchantVpa;
  final String merchantName;
  final double totalAmount;
  final String note;
  final List<Tranche> tranches;
  final DateTime createdAt;

  SplitOrder({
    required this.orderId,
    required this.merchantVpa,
    required this.merchantName,
    required this.totalAmount,
    required this.note,
    required this.tranches,
    required this.createdAt,
  });

  double get paidAmount => tranches
      .where((t) => t.isPaid)
      .fold(0.0, (sum, item) => sum + item.amount);

  double get remainingAmount => (totalAmount - paidAmount).clamp(0.0, totalAmount);

  double get progress => totalAmount == 0 ? 0.0 : (paidAmount / totalAmount);

  bool get isFullyPaid => tranches.isNotEmpty && tranches.every((t) => t.isPaid);

  /// MDR without SplitPe (0.4% on full transaction if > ₹2,000, capped at ₹300 for >= 75k)
  double get mdrStandard {
    if (totalAmount <= 2000) return 0.0;
    final fee = totalAmount * 0.004;
    return fee > 300 ? 300.0 : fee;
  }

  /// MDR with SplitPe (0% since each tranche <= ₹2,000)
  double get mdrWithSplitPe => 0.0;

  /// Net savings achieved
  double get mdrSavings => mdrStandard - mdrWithSplitPe;

  Tranche? get currentPendingTranche {
    try {
      return tranches.firstWhere((t) => !t.isPaid);
    } catch (_) {
      return null;
    }
  }
}
