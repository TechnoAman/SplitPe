enum TrancheStatus { pending, inProgress, paid, failed }

class Tranche {
  final String id;
  final int index;
  final double amount;
  final String upiUri;
  final String? payerName;
  TrancheStatus status;
  DateTime? paidAt;
  String? txnRef;
  final int suggestedDelaySeconds;

  Tranche({
    required this.id,
    required this.index,
    required this.amount,
    required this.upiUri,
    this.payerName,
    this.status = TrancheStatus.pending,
    this.paidAt,
    this.txnRef,
    this.suggestedDelaySeconds = 0,
  });

  bool get isPaid => status == TrancheStatus.paid;

  Tranche copyWith({
    String? id,
    int? index,
    double? amount,
    String? upiUri,
    String? payerName,
    TrancheStatus? status,
    DateTime? paidAt,
    String? txnRef,
    int? suggestedDelaySeconds,
  }) {
    return Tranche(
      id: id ?? this.id,
      index: index ?? this.index,
      amount: amount ?? this.amount,
      upiUri: upiUri ?? this.upiUri,
      payerName: payerName ?? this.payerName,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      txnRef: txnRef ?? this.txnRef,
      suggestedDelaySeconds: suggestedDelaySeconds ?? this.suggestedDelaySeconds,
    );
  }
}
