import '../models/ledger_entry.dart';

class LedgerExporter {
  /// Generates CSV representation of ledger entries.
  /// Header: Date,Time,Amount,Sender UPI,Receiver UPI,Note
  /// Proper CSV escaping on the note field: wrapped in quotes if it contains commas,
  /// quotes, or newlines, with embedded double-quotes escaped ("").
  static String generateCsv(List<LedgerEntry> entries) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Time,Amount,Sender UPI,Receiver UPI,Note');

    for (final entry in entries) {
      final dateStr =
          '${entry.timestamp.year.toString().padLeft(4, '0')}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}';
      final amountStr = entry.amount.toStringAsFixed(2);
      final noteStr = escapeCsvNote(entry.note);

      buffer.writeln(
        '$dateStr,$timeStr,$amountStr,${entry.senderUpiId},${entry.receiverUpiId},$noteStr',
      );
    }

    return buffer.toString();
  }

  /// Escapes note field for RFC 4180 CSV compatibility:
  /// Wrap in quotes if it contains commas, quotes, or newlines, and double-quote escape embedded quotes.
  static String escapeCsvNote(String? note) {
    if (note == null || note.isEmpty) return '';
    final needsQuotes = note.contains(',') ||
        note.contains('"') ||
        note.contains('\n') ||
        note.contains('\r');
    if (needsQuotes) {
      return '"${note.replaceAll('"', '""')}"';
    }
    return note;
  }

  /// Generates a short, human-readable plain-text summary formatted for readability
  /// with total amount and tranche count, optimized for SMS character limits.
  static String generatePlainTextSummary(List<LedgerEntry> entries) {
    if (entries.isEmpty) {
      return 'SplitPe: No transactions in this session.';
    }

    final total = entries.fold<double>(0.0, (acc, e) => acc + e.amount);
    final count = entries.length;
    final buffer = StringBuffer();
    buffer.writeln('SplitPe Summary: $count tranches, Total ₹${total.toStringAsFixed(0)}');

    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final noteSuffix =
          (e.note != null && e.note!.trim().isNotEmpty) ? ' (${e.note!.trim()})' : '';
      buffer.writeln(
        '#${i + 1}: ₹${e.amount.toStringAsFixed(0)} to ${e.receiverUpiId}$noteSuffix',
      );
    }

    return buffer.toString().trim();
  }
}
