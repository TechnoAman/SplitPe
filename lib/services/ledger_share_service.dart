import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ledger_entry.dart';
import 'ledger_exporter.dart';
import 'upi_phone_extractor.dart';

class LedgerShareService {
  LedgerShareService._();
  static final LedgerShareService instance = LedgerShareService._();

  /// Shares CSV export via system share sheet (share_plus)
  Future<void> shareCsv(List<LedgerEntry> entries) async {
    final csv = LedgerExporter.generateCsv(entries);
    await SharePlus.instance.share(ShareParams(text: csv));
  }

  /// Shares plain-text summary via system share sheet (share_plus)
  Future<void> shareSummary(List<LedgerEntry> entries) async {
    final summary = LedgerExporter.generatePlainTextSummary(entries);
    await SharePlus.instance.share(ShareParams(text: summary));
  }

  /// Checks if a receiver UPI ID has an extractable 10-digit phone number
  bool hasMerchantPhone(String receiverUpiId) {
    return extractPhoneFromUpiId(receiverUpiId) != null;
  }

  /// Launches SMS app to share summary to merchant phone if extractable.
  /// Uses `sms:<phone>?body=<encoded_summary>` launched via url_launcher.
  /// Degrades gracefully: returns false if phone is null or launch fails.
  Future<bool> shareToMerchantViaSms({
    required String receiverUpiId,
    required List<LedgerEntry> entries,
  }) async {
    final phone = extractPhoneFromUpiId(receiverUpiId);
    if (phone == null) return false;

    final summary = LedgerExporter.generatePlainTextSummary(entries);
    final encodedSummary = Uri.encodeComponent(summary);
    final smsUri = Uri.parse('sms:$phone?body=$encodedSummary');

    try {
      final launched = await launchUrl(
        smsUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
      return await launchUrl(smsUri);
    } catch (_) {
      return false;
    }
  }

  /// Shares a single ledger entry to merchant via SMS if extractable.
  Future<bool> shareEntryToMerchantViaSms(LedgerEntry entry) async {
    final phone = extractPhoneFromUpiId(entry.receiverUpiId);
    if (phone == null) return false;

    final noteSuffix = (entry.note != null && entry.note!.trim().isNotEmpty)
        ? ' [${entry.note!.trim()}]'
        : '';
    final text =
        'SplitPe Payment: ₹${entry.amount.toStringAsFixed(0)} sent to ${entry.receiverUpiId}$noteSuffix. Status: ${entry.statusLabel}';
    final encoded = Uri.encodeComponent(text);
    final smsUri = Uri.parse('sms:$phone?body=$encoded');

    try {
      final launched = await launchUrl(
        smsUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;
      return await launchUrl(smsUri);
    } catch (_) {
      return false;
    }
  }
}
