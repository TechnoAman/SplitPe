import 'tranche.dart';

class LedgerEntry {
  final DateTime timestamp;
  final double amount;
  final String senderUpiId;
  final String receiverUpiId;
  final String? note;
  final int? trancheIndex;
  final int? billId;
  final TrancheStatus status;

  const LedgerEntry({
    required this.timestamp,
    required this.amount,
    required this.senderUpiId,
    required this.receiverUpiId,
    this.note,
    this.trancheIndex,
    this.billId,
    this.status = TrancheStatus.inProgress,
  });

  /// Human-readable label explicitly noting that these are self-reported/launched payments,
  /// never bank-verified or bank-confirmed.
  String get statusLabel {
    switch (status) {
      case TrancheStatus.inProgress:
        return 'LAUNCHED (SELF-REPORTED)';
      case TrancheStatus.paid:
        return 'PAID (SELF-REPORTED)';
      case TrancheStatus.failed:
        return 'FAILED';
      case TrancheStatus.pending:
        return 'PENDING';
    }
  }

  LedgerEntry copyWith({
    DateTime? timestamp,
    double? amount,
    String? senderUpiId,
    String? receiverUpiId,
    String? note,
    int? trancheIndex,
    int? billId,
    TrancheStatus? status,
  }) {
    return LedgerEntry(
      timestamp: timestamp ?? this.timestamp,
      amount: amount ?? this.amount,
      senderUpiId: senderUpiId ?? this.senderUpiId,
      receiverUpiId: receiverUpiId ?? this.receiverUpiId,
      note: note ?? this.note,
      trancheIndex: trancheIndex ?? this.trancheIndex,
      billId: billId ?? this.billId,
      status: status ?? this.status,
    );
  }
}
