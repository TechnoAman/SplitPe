import 'dart:math';
import '../models/split_order.dart';
import '../models/tranche.dart';

class SplitEngine {
  /// Default safe threshold per tranche (below ₹2,000 to be 100% exempt from MDR)
  static const double safeTrancheCap = 1999.0;

  /// Calculates randomized transaction amounts that sum exactly to [totalAmount]
  /// satisfying two key constraints simultaneously:
  /// 1. Minimizes total transactions: K = ceil(totalAmount / maxTranche).
  /// 2. Avoids uniform or predictable transaction amounts (non-uniform distribution).
  ///
  /// Every tranche satisfies: 0 < tranche <= maxTranche < 2000.
  static List<double> calculateTrancheAmounts({
    required double totalAmount,
    double maxTranche = safeTrancheCap,
    bool randomize = true,
  }) {
    if (totalAmount <= 0) return [];
    if (totalAmount <= maxTranche) {
      return [double.parse(totalAmount.toStringAsFixed(2))];
    }

    // Stage 1: Determine minimum transaction count
    // minimum_transactions = ceil(amount / maxTranche)
    final int trancheCount = (totalAmount / maxTranche).ceil();
    if (trancheCount <= 1) {
      return [double.parse(totalAmount.toStringAsFixed(2))];
    }

    // Deterministic fallback if randomization is disabled
    if (!randomize) {
      final base = double.parse((totalAmount / trancheCount).toStringAsFixed(2));
      final List<double> amounts = List.filled(trancheCount - 1, base);
      final distributed = amounts.fold(0.0, (sum, a) => sum + a);
      amounts.add(double.parse((totalAmount - distributed).toStringAsFixed(2)));
      return amounts;
    }

    // Stage 2: Generate a non-uniform randomized split within minimum_transactions
    final random = Random();
    final isWhole = (totalAmount % 1 == 0);
    final intAmt = isWhole ? totalAmount.round() : 0;

    // Detect natural step size to favor human-friendly payment values (e.g. ₹50, ₹100)
    double baseStep;
    if (isWhole && intAmt % 100 == 0) {
      baseStep = 100.0;
    } else if (isWhole && intAmt % 50 == 0) {
      baseStep = 50.0;
    } else if (isWhole && intAmt % 10 == 0) {
      baseStep = 10.0;
    } else if (isWhole && intAmt % 5 == 0) {
      baseStep = 5.0;
    } else if (isWhole) {
      baseStep = 1.0;
    } else {
      baseStep = 0.01;
    }

    // Initialize base allocation in units of baseStep
    final int totalUnits = (totalAmount / baseStep).round();
    final int q = totalUnits ~/ trancheCount;
    final int r = totalUnits % trancheCount;

    final List<double> amounts = [];
    for (int i = 0; i < trancheCount; i++) {
      final units = q + (i < r ? 1 : 0);
      amounts.add(double.parse((units * baseStep).toStringAsFixed(2)));
    }

    // Determine candidate step sizes for random diffusion
    List<double> stepCandidates;
    if (baseStep >= 50.0) {
      stepCandidates = (baseStep == 100.0 || intAmt % 50 == 0)
          ? const [100.0, 50.0]
          : const [50.0];
    } else if (baseStep >= 10.0) {
      stepCandidates = const [10.0, 5.0];
    } else if (baseStep >= 1.0) {
      stepCandidates = const [10.0, 5.0, 1.0];
    } else {
      stepCandidates = const [1.0, 0.1, 0.01];
    }

    // Absolute mathematical lower bound to guarantee remaining tranches can fulfill
    // the total without any tranche exceeding maxTranche:
    final double absMinAllowed = max(
      isWhole ? 1.0 : 0.01,
      totalAmount - ((trancheCount - 1) * maxTranche),
    );

    final double avgAmt = totalAmount / trancheCount;
    // Target min bound: prevents tiny slivers like ₹2 or ₹50 on large bills,
    // but strictly respects absMinAllowed
    double desiredMin = max(absMinAllowed, min(500.0, avgAmt * 0.35));
    desiredMin = min(desiredMin, avgAmt * 0.75);

    // Iterative bounded transfer (constrained random walk on simplex)
    final int iterations = 35 * trancheCount;
    for (int iter = 0; iter < iterations; iter++) {
      final i = random.nextInt(trancheCount);
      final j = random.nextInt(trancheCount);
      if (i == j) continue;

      final step = stepCandidates[random.nextInt(stepCandidates.length)];
      final canGive = amounts[i] - desiredMin;
      final canTake = maxTranche - amounts[j];
      final maxTransfer = min(canGive, canTake);

      if (maxTransfer >= step) {
        final maxSteps = (maxTransfer / step).floor();
        final numSteps = 1 + random.nextInt(min(maxSteps, 4));
        final delta = double.parse((numSteps * step).toStringAsFixed(2));

        amounts[i] = double.parse((amounts[i] - delta).toStringAsFixed(2));
        amounts[j] = double.parse((amounts[j] + delta).toStringAsFixed(2));
      }
    }

    // Enforce upper bounds strictly
    for (int i = 0; i < trancheCount; i++) {
      if (amounts[i] > maxTranche) {
        final excess = double.parse((amounts[i] - maxTranche).toStringAsFixed(2));
        amounts[i] = maxTranche;
        for (int other = 0; other < trancheCount; other++) {
          if (other != i && amounts[other] + excess <= maxTranche) {
            amounts[other] = double.parse((amounts[other] + excess).toStringAsFixed(2));
            break;
          }
        }
      }
    }

    // Correct any rounding discrepancies while respecting bounds
    final currentSum = amounts.fold(0.0, (sum, a) => sum + a);
    final diff = double.parse((totalAmount - currentSum).toStringAsFixed(2));
    if (diff != 0.0) {
      for (int i = 0; i < trancheCount; i++) {
        if (amounts[i] + diff <= maxTranche && amounts[i] + diff >= absMinAllowed) {
          amounts[i] = double.parse((amounts[i] + diff).toStringAsFixed(2));
          break;
        }
      }
    }

    // Shuffle amounts so larger or smaller tranches don't follow a fixed positional pattern
    amounts.shuffle(random);

    return amounts;
  }

  /// Algorithmic Research Note: In payment pattern simulation, synchronous sub-second
  /// multi-tranche execution creates predictable velocity/burst signatures on banking switches.
  /// This models an organic human cadence window (e.g. 15-45s) between sequential tranches.
  static int calculateSuggestedJitterDelay(
    int trancheIndex, {
    int minSeconds = 15,
    int maxSeconds = 45,
  }) {
    if (trancheIndex <= 1) return 0;
    final random = Random();
    return minSeconds + random.nextInt(maxSeconds - minSeconds + 1);
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
          suggestedDelaySeconds: index == 1 ? 0 : calculateSuggestedJitterDelay(index),
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
