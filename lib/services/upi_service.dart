import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiService {
  /// Launches UPI intent URI (opens Google Pay, PhonePe, Paytm, etc. on mobile)
  static Future<bool> launchUpiIntent(String upiUri) async {
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
