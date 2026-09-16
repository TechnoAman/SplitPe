import 'dart:math';
import '../models/split_order.dart';
import '../models/tranche.dart';

class SplitEngine {
  /// Default safe threshold per tranche (below ₹2,000 to be 100% exempt from MDR)
  static const double safeTrancheCap = 1999.0;

  /// Calculates randomized or fixed tranche amounts that sum exactly to [totalAmount]
  /// with each tranche <= [maxTranche].
  static List<double> calculateTrancheAmounts({
    required double totalAmount,
    double maxTranche = safeTrancheCap,
    bool randomize = true,
  }) {
    if (totalAmount <= 0) return [];
    if (totalAmount <= maxTranche) return [totalAmount];

    final int trancheCount = (totalAmount / maxTranche).ceil();
    final List<double> amounts = [];
    final random = Random();
    double remaining = totalAmount;

    if (!randomize || trancheCount <= 1) {
      for (int i = 0; i < trancheCount; i++) {
        if (i == trancheCount - 1) {
          amounts.add(double.parse(remaining.toStringAsFixed(2)));
        } else {
          final amt = min(maxTranche, remaining);
          amounts.add(double.parse(amt.toStringAsFixed(2)));
          remaining -= amt;
        }
      }
      return amounts;
    }

    // Natural randomized distribution
    for (int i = 0; i < trancheCount - 1; i++) {
      final remainingCount = trancheCount - 1 - i;
      // To ensure remaining tranches can fulfill the rest without exceeding maxTranche:
      final minAllowed = max(10.0, remaining - (remainingCount * maxTranche));
      // To ensure remaining tranches have at least min (e.g. ₹10) each:
      final maxAllowed = min(maxTranche, remaining - (remainingCount * 10.0));

      double picked;
      if (maxAllowed <= minAllowed) {
        picked = minAllowed;
      } else {
        final isWhole = (totalAmount % 1 == 0);
        final spread = maxAllowed - minAllowed;

        if (isWhole && spread >= 10) {
          final minInt = minAllowed.ceil();
          final maxInt = maxAllowed.floor();
          if (maxInt > minInt) {
            // Pick a random whole rupee
            picked = (minInt + random.nextInt(maxInt - minInt + 1)).toDouble();
          } else {
            picked = minInt.toDouble();
          }
        } else {
          picked = minAllowed + random.nextDouble() * (maxAllowed - minAllowed);
          picked = (picked * 100).round() / 100.0;
        }
      }

      amounts.add(double.parse(picked.toStringAsFixed(2)));
      remaining -= picked;
      remaining = double.parse(remaining.toStringAsFixed(2));
    }

    // Last tranche gets the exact remaining amount
    amounts.add(double.parse(remaining.toStringAsFixed(2)));

    // Fallback sanity check: if any tranche violated bounds, use balanced split
    if (amounts.any((a) => a > maxTranche || a <= 0)) {
      amounts.clear();
      remaining = totalAmount;
      final base = (totalAmount / trancheCount);
      for (int i = 0; i < trancheCount; i++) {
        if (i == trancheCount - 1) {
          amounts.add(double.parse(remaining.toStringAsFixed(2)));
        } else {
          final amt = double.parse(base.toStringAsFixed(2));
          amounts.add(amt);
          remaining -= amt;
        }
      }
    }

    return amounts;
  }

  /// Creates a SplitOrder by dividing [totalAmount] into sub-₹2,000 tranches.
  static SplitOrder createTrancheOrder({
    required double totalAmount,
    required String merchantVpa,
    required String merchantName,
    String note = 'SplitPe Checkout',
    double maxTranche = safeTrancheCap,
    bool randomize = true,
  }) {
    final orderId =
        'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final List<Tranche> tranches = [];

    if (totalAmount <= 0) {
      return SplitOrder(
        orderId: orderId,
        merchantVpa: merchantVpa,
        merchantName: merchantName,
        totalAmount: 0,
        note: note,
        tranches: [],
        createdAt: DateTime.now(),
      );
    }

    final amounts = calculateTrancheAmounts(
      totalAmount: totalAmount,
      maxTranche: maxTranche,
      randomize: randomize,
    );

    final trancheCount = amounts.length;
    for (int i = 0; i < trancheCount; i++) {
      final trancheAmt = amounts[i];
      final index = i + 1;
      final trancheId = '${orderId}_$index';
      final upiUri = buildUpiUri(
        vpa: merchantVpa,
        name: merchantName,
        amount: trancheAmt,
        note: trancheCount == 1 ? note : '$note Tranche $index/$trancheCount',
      );

      tranches.add(
        Tranche(
          id: trancheId,
          index: index,
          amount: trancheAmt,
          upiUri: upiUri,
        ),
      );
    }

    return SplitOrder(
      orderId: orderId,
      merchantVpa: merchantVpa,
      merchantName: merchantName,
      totalAmount: totalAmount,
      note: note,
      tranches: tranches,
      createdAt: DateTime.now(),
    );
  }

  /// Creates a group bill split between friends (each share guaranteed <= ₹2,000 if split count allows)
  static SplitOrder createGroupSplitOrder({
    required double totalAmount,
    required int numberOfPeople,
    required String merchantVpa,
    required String merchantName,
    List<String>? friendNames,
    String note = 'Group Bill Split',
  }) {
    final orderId =
        'GRP${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final List<Tranche> tranches = [];
    final people = max(1, numberOfPeople);

    double perPersonBase = (totalAmount / people);
    double distributedTotal = 0;

    for (int i = 0; i < people; i++) {
      String personName = (friendNames != null && i < friendNames.length)
          ? friendNames[i]
          : 'Friend #${i + 1}';

      double amt;
      if (i == people - 1) {
        amt = double.parse((totalAmount - distributedTotal).toStringAsFixed(2));
      } else {
        amt = double.parse(perPersonBase.toStringAsFixed(2));
      }
      distributedTotal += amt;

      final trancheId = '${orderId}_${i + 1}';
      final upiUri = buildUpiUri(
        vpa: merchantVpa,
        name: merchantName,
        amount: amt,
        note: '$note ($personName)',
      );

      tranches.add(
        Tranche(
          id: trancheId,
          index: i + 1,
          amount: amt,
          payerName: personName,
          upiUri: upiUri,
        ),
      );
    }

    return SplitOrder(
      orderId: orderId,
      merchantVpa: merchantVpa,
      merchantName: merchantName,
      totalAmount: totalAmount,
      note: note,
      tranches: tranches,
      createdAt: DateTime.now(),
    );
  }

  /// Builds standard NPCI UPI Intent URI (clean format compliant with GPay, PhonePe & Paytm)
  static String buildUpiUri({
    required String vpa,
    required String name,
    required double amount,
    String? txnRef,
    required String note,
  }) {
    final params = <String, String>{
      'pa': vpa.trim(),
      if (name.trim().isNotEmpty) 'pn': name.trim(),
      'am': amount.toStringAsFixed(2),
      'cu': 'INR',
      if (note.trim().isNotEmpty) 'tn': note.trim(),
    };

    if (txnRef != null && txnRef.trim().isNotEmpty) {
      params['tr'] = txnRef.trim();
    }

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'upi://pay?$query';
  }

  /// Parses a raw scanned UPI QR string into a map of parameters (pa, pn, am, tn, etc.)
  static Map<String, String> parseUpiUri(String rawData) {
    var clean = rawData.trim();
    final Map<String, String> result = {'pa': '', 'pn': '', 'am': '', 'tn': ''};

    if (clean.isEmpty) return result;

    // Remove any surrounding quotes
    if (clean.startsWith('"') && clean.endsWith('"')) {
      clean = clean.substring(1, clean.length - 1).trim();
    }

    // Try standard URI parse
    try {
      final uri = Uri.parse(clean);
      final query = uri.queryParameters;
      
      // Case-insensitive query lookup
      for (final entry in query.entries) {
        final key = entry.key.toLowerCase();
        if (key == 'pa') result['pa'] = Uri.decodeComponent(entry.value);
        if (key == 'pn') result['pn'] = Uri.decodeComponent(entry.value);
        if (key == 'am') result['am'] = entry.value;
        if (key == 'tn') result['tn'] = Uri.decodeComponent(entry.value);
      }
    } catch (_) {}

    // Regex fallback if standard URI parse didn't find 'pa'
    if (result['pa']!.isEmpty) {
      final paMatch = RegExp(r'[?&]pa=([^&]+)', caseSensitive: false).firstMatch(clean);
      if (paMatch != null) result['pa'] = Uri.decodeComponent(paMatch.group(1) ?? '');

      final pnMatch = RegExp(r'[?&]pn=([^&]+)', caseSensitive: false).firstMatch(clean);
      if (pnMatch != null) result['pn'] = Uri.decodeComponent(pnMatch.group(1) ?? '');

      final amMatch = RegExp(r'[?&]am=([^&]+)', caseSensitive: false).firstMatch(clean);
      if (amMatch != null) result['am'] = amMatch.group(1) ?? '';

      final tnMatch = RegExp(r'[?&]tn=([^&]+)', caseSensitive: false).firstMatch(clean);
      if (tnMatch != null) result['tn'] = Uri.decodeComponent(tnMatch.group(1) ?? '');
    }

    // Fallback: Direct VPA string (e.g. name@okhdfcbank)
    if (result['pa']!.isEmpty && clean.contains('@') && !clean.contains('://')) {
      result['pa'] = clean.replaceAll(RegExp(r'\s+'), '');
    }

    // Default friendly name from VPA if name is blank
    if (result['pn']!.isEmpty && result['pa']!.isNotEmpty) {
      final handle = result['pa']!.split('@').first;
      result['pn'] = handle[0].toUpperCase() + handle.substring(1);
    }

    return result;
  }
}
