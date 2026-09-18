import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/tranche.dart';
import 'session_ledger_service.dart';

class UpiService {
  /// Launches UPI intent URI (opens Google Pay, PhonePe, Paytm, etc. on mobile)
  /// and automatically appends a launched entry to the in-memory session ledger.
  static Future<bool> launchUpiIntent(
    String upiUri, {
    double? amount,
    String? receiverUpiId,
    String? senderUpiId,
    String? note,
    int? trancheIndex,
    int? billId,
  }) async {
    // 1. Extract metadata from upiUri if not explicitly passed
    double finalAmount = amount ?? 0.0;
    String finalReceiver = receiverUpiId ?? '';
    String? finalNote = note;

    try {
      final parsedUri = Uri.parse(upiUri);
      if (finalReceiver.isEmpty) {
        finalReceiver = parsedUri.queryParameters['pa'] ?? '';
      }
      if (finalAmount <= 0) {
        final amStr = parsedUri.queryParameters['am'];
        if (amStr != null) {
          finalAmount = double.tryParse(amStr) ?? 0.0;
        }
      }
      if (finalNote == null || finalNote.isEmpty) {
        finalNote = parsedUri.queryParameters['tn'];
      }
    } catch (_) {}

    // 2. Record tranche launch into session ledger (self-reported / inProgress)
    SessionLedgerService.instance.recordTrancheLaunch(
      amount: finalAmount,
      receiverUpiId: finalReceiver,
      senderUpiId: senderUpiId,
      note: finalNote,
      trancheIndex: trancheIndex,
      billId: billId,
      status: TrancheStatus.inProgress,
    );

    final uri = Uri.parse(upiUri);
    try {
      // Direct launch attempt for Android & iOS intent handlers
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (launched) return true;

      // Fallback attempt with externalApplication
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      try {
        return await launchUrl(uri);
      } catch (_) {
        return false;
      }
    }
  }

  /// Copies UPI link or VPA to clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Generates a viral share text for WhatsApp or Social Media
  static String generateViralShareText({
    required double totalAmount,
    required double mdrSaved,
    required int trancheCount,
  }) {
    return '⚡ Saved ₹${mdrSaved.toStringAsFixed(2)} MDR on a ₹${totalAmount.toStringAsFixed(0)} bill using @SplitPe!\n\n'
        'Split into $trancheCount sub-₹2,000 tranches to pay 0% MDR fee legally! 🚀\n'
        '#UPI #Fintech #SplitPe #ZeroMDR';
  }

  /// Generates group payment link message for WhatsApp
  static String generateGroupShareMessage({
    required String merchantName,
    required String payerName,
    required double amount,
    required String upiUri,
  }) {
    return 'Hey $payerName, your share for $merchantName is ₹${amount.toStringAsFixed(2)}.\n'
        'Click to pay via UPI (0% MDR): $upiUri';
  }
}
