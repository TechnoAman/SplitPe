import 'package:flutter/foundation.dart';
import '../models/ledger_entry.dart';
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

  /// Appends a new ledger entry whenever a tranche payment is launched.
  /// Status is initialized to self-reported / launched (TrancheStatus.inProgress).
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

  /// Updates status of the most recent matching tranche
  void updateTrancheStatus({
    required int trancheIndex,
    int? billId,
    required TrancheStatus status,
  }) {
    for (var i = _entries.length - 1; i >= 0; i--) {
      final e = _entries[i];
      if (e.trancheIndex == trancheIndex && (billId == null || e.billId == billId)) {
        _entries[i] = e.copyWith(status: status);
        notifyListeners();
        return;
      }
    }
  }

  /// Clears the in-memory ledger
  void clear() {
    _entries.clear();
    notifyListeners();
  }
}
