import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage/quick_pay_storage.dart';

class SavedMerchant {
  final String vpa;
  final String name;
  final DateTime lastUsedAt;
  final double? lastAmount;

  const SavedMerchant({
    required this.vpa,
    required this.name,
    required this.lastUsedAt,
    this.lastAmount,
  });

  Map<String, dynamic> toJson() => {
    'vpa': vpa,
    'name': name,
    'lastUsedAt': lastUsedAt.toIso8601String(),
    if (lastAmount != null) 'lastAmount': lastAmount,
  };

  factory SavedMerchant.fromJson(Map<String, dynamic> json) {
    return SavedMerchant(
      vpa: json['vpa'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.tryParse(json['lastUsedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastAmount: (json['lastAmount'] as num?)?.toDouble(),
    );
  }

  String get timeAgoDescription {
    final diff = DateTime.now().difference(lastUsedAt);
    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

class QuickPayService {
  QuickPayService._();
  static final QuickPayService instance = QuickPayService._();

  static const String storageKey = 'splitpe_last_merchant';

  final ValueNotifier<SavedMerchant?> lastMerchant = ValueNotifier<SavedMerchant?>(null);

  Future<SavedMerchant?> loadLastMerchant() async {
    try {
      final raw = await QuickPayStorage.instance.readString(storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final merchant = SavedMerchant.fromJson(decoded);
          if (merchant.vpa.isNotEmpty) {
            lastMerchant.value = merchant;
            return merchant;
          }
        }
      }
    } catch (_) {}
    lastMerchant.value = null;
    return null;
  }

  Future<void> saveMerchant({
    required String vpa,
    required String name,
    double? amount,
  }) async {
    final cleanVpa = vpa.trim();
    if (cleanVpa.isEmpty) return;

    final cleanName = name.trim().isNotEmpty
        ? name.trim()
        : cleanVpa.split('@').first.toUpperCase();

    final merchant = SavedMerchant(
      vpa: cleanVpa,
      name: cleanName,
      lastUsedAt: DateTime.now(),
      lastAmount: amount,
    );

    lastMerchant.value = merchant;

    try {
      final jsonStr = jsonEncode(merchant.toJson());
      await QuickPayStorage.instance.saveString(storageKey, jsonStr);
    } catch (_) {}
  }

  Future<void> clearSavedMerchant() async {
    lastMerchant.value = null;
    try {
      await QuickPayStorage.instance.remove(storageKey);
    } catch (_) {}
  }
}
