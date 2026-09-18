import 'package:flutter/foundation.dart';
import '../models/ledger_entry.dart';
import '../models/split_order.dart';
import '../models/tranche.dart';
import 'user_profile_service.dart';

class SessionLedgerService extends ChangeNotifier {
  SessionLedgerService._();
  static final SessionLedgerService instance = SessionLedgerService._();

  // Strictly in-memory session list. Cleared on app refresh/restart.
  final List<LedgerEntry> _entries = [];

  List<LedgerEntry> get entries => List.unmodifiable(_entries);

  /// Returns entries ordered newest first
  List<LedgerEntry> get newestFirst => List.unmodifiable(_entries.reversed);

  int get count => _entries.length;

  double get totalVolume => _entries.fold(0.0, (acc, e) => acc + e.amount);

  /// Returns entries (newest first), optionally filtered by TrancheStatus
  List<LedgerEntry> getFilteredEntries({TrancheStatus? statusFilter}) {
    if (statusFilter == null) {
      return newestFirst;
    }
    return _entries.reversed.where((e) => e.status == statusFilter).toList();
  }

  /// Registers all tranches of a SplitOrder into the session ledger.
  /// Ensures all tranches of a split payment appear in the ledger immediately
  /// with their respective statuses (e.g. inProgress for active, pending for remaining, paid when settled).
  void registerOrder(SplitOrder order) {
    final sender = UserProfileService.instance.profile?.upiId ?? 'self@upi';
    final billId = order.hashCode;

    for (var i = 0; i < order.tranches.length; i++) {
      final t = order.tranches[i];
      final existingIndex = _entries.indexWhere(
        (e) => e.trancheIndex == t.index && e.billId == billId,
      );

      final status = t.isPaid
          ? TrancheStatus.paid
          : (existingIndex != -1 && _entries[existingIndex].status == TrancheStatus.inProgress
              ? TrancheStatus.inProgress
              : (t.status == TrancheStatus.inProgress || i == 0
                  ? TrancheStatus.inProgress
                  : TrancheStatus.pending));

      final note = (order.note.isNotEmpty)
          ? '${order.note} · Tranche ${i + 1}/${order.tranches.length}'
          : 'Tranche ${i + 1}/${order.tranches.length}';

      if (existingIndex != -1) {
        final current = _entries[existingIndex];
        if (current.status != status || current.amount != t.amount) {
          _entries[existingIndex] = current.copyWith(
            status: status,
            amount: t.amount,
          );
        }
      } else {
        _entries.add(
          LedgerEntry(
            timestamp: t.paidAt ?? order.createdAt,
            amount: t.amount,
            senderUpiId: sender,
            receiverUpiId: order.merchantVpa,
            note: note,
            trancheIndex: t.index,
            billId: billId,
            status: status,
          ),
        );
      }
    }
    notifyListeners();
  }

  /// Appends or updates a ledger entry whenever a tranche payment is launched.
  /// Status defaults to self-reported / launched (TrancheStatus.inProgress).
  void recordTrancheLaunch({
    required double amount,
    required String receiverUpiId,
    String? senderUpiId,
    String? note,
    int? trancheIndex,
    int? billId,
    DateTime? timestamp,
    TrancheStatus status = TrancheStatus.inProgress,
  }) {
    final sender = senderUpiId ??
        UserProfileService.instance.profile?.upiId ??
        'self@upi';

    // If an existing entry exists for this tranche & bill, update its status
    if (trancheIndex != null && billId != null) {
      final existingIndex = _entries.indexWhere(
        (e) => e.trancheIndex == trancheIndex && e.billId == billId,
      );
      if (existingIndex != -1) {
        _entries[existingIndex] = _entries[existingIndex].copyWith(
          status: status,
          amount: amount > 0 ? amount : _entries[existingIndex].amount,
          receiverUpiId: receiverUpiId.isNotEmpty ? receiverUpiId : _entries[existingIndex].receiverUpiId,
          note: note ?? _entries[existingIndex].note,
        );
        notifyListeners();
        return;
      }
    }

    final entry = LedgerEntry(
      timestamp: timestamp ?? DateTime.now(),
      amount: amount,
      senderUpiId: sender,
      receiverUpiId: receiverUpiId,
      note: note,
      trancheIndex: trancheIndex,
      billId: billId,
      status: status,
    );

    _entries.add(entry);
    notifyListeners();
  }

  /// Directly appends an entry (useful for tests or custom events)
  void addEntry(LedgerEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  /// Updates status of an entry by index
  void updateEntryStatus(int index, TrancheStatus status) {
    if (index >= 0 && index < _entries.length) {
      _entries[index] = _entries[index].copyWith(status: status);
      notifyListeners();
    }
  }

  /// Updates status of the most recent matching tranche, or adds it if missing
  void updateTrancheStatus({
    required int trancheIndex,
    int? billId,
    required TrancheStatus status,
    double? amount,
    String? receiverUpiId,
    String? note,
  }) {
    for (var i = _entries.length - 1; i >= 0; i--) {
      final e = _entries[i];
      if (e.trancheIndex == trancheIndex && (billId == null || e.billId == billId)) {
        _entries[i] = e.copyWith(status: status);
        notifyListeners();
        return;
      }
    }

    // Fallback: If not found, add it directly so it is never missing from the ledger
    if (amount != null && receiverUpiId != null) {
      final sender = UserProfileService.instance.profile?.upiId ?? 'self@upi';
      _entries.add(
        LedgerEntry(
          timestamp: DateTime.now(),
          amount: amount,
          senderUpiId: sender,
          receiverUpiId: receiverUpiId,
          note: note,
          trancheIndex: trancheIndex,
          billId: billId,
          status: status,
        ),
      );
      notifyListeners();
    }
  }

  /// Clears the in-memory ledger
  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
