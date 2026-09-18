import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import '../models/split_order.dart';
import '../services/quick_pay_service.dart';
import '../services/session_ledger_service.dart';
import '../services/split_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/soundbox_speaker_widget.dart';
import '../widgets/split_checkout_modal.dart';
import 'qr_scanner_view.dart';

class KiranaPreset {
  final String title;
  final double amount;

  const KiranaPreset({required this.title, required this.amount});
}

class PosCheckoutView extends StatefulWidget {
  final Map<String, String>? initialScannedData;
  const PosCheckoutView({super.key, this.initialScannedData});

  @override
  State<PosCheckoutView> createState() => PosCheckoutViewState();
}

class PosCheckoutViewState extends State<PosCheckoutView> {
  final _amountController = TextEditingController(text: '3850');
  final _vpaController = TextEditingController(text: '');
  final _nameController = TextEditingController(text: '');

  SplitOrder? _currentOrder;
  String? _soundboxAnnouncement;
  String _selectedPresetTitle = 'CUSTOM BILL';

  static const List<KiranaPreset> _kiranaPresets = [
    KiranaPreset(title: '🌾 ATTA & OIL', amount: 2450),
    KiranaPreset(title: '🥛 DAIRY & GHEE', amount: 3200),
    KiranaPreset(title: '🍛 DHABA DINNER', amount: 3850),
    KiranaPreset(title: '🥜 DRY FRUITS', amount: 4500),
    KiranaPreset(title: '🛒 FULL RATION', amount: 7500),
  ];

  static const List<String> _upiHandles = [
    '@okhdfcbank',
    '@okaxis',
    '@paytm',
    '@ybl',
    '@upi',
  ];

  @override
  void initState() {
    super.initState();
    QuickPayService.instance.loadLastMerchant();
    if (widget.initialScannedData != null) {
      applyScannedData(widget.initialScannedData!);
    } else {
      _recalculateOrder();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _vpaController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void applyScannedData(Map<String, String> result) {
    final vpa = result['pa'] ?? '';
    final name = result['pn'] ?? '';
    final am = result['am'] ?? '';

    if (vpa.isNotEmpty) {
      final decodedName = name.isNotEmpty ? Uri.decodeComponent(name) : '';
      QuickPayService.instance.saveMerchant(
        vpa: vpa,
        name: decodedName,
        amount: double.tryParse(am),
      );
    }

    setState(() {
      if (vpa.isNotEmpty) _vpaController.text = vpa;
      if (name.isNotEmpty) _nameController.text = Uri.decodeComponent(name);
      if (am.isNotEmpty &&
          double.tryParse(am) != null &&
          double.parse(am) > 0) {
        _amountController.text = double.parse(am).toStringAsFixed(0);
      }
      _recalculateOrder();
    });

    _openCheckoutDialog();
  }

  Future<void> scanMerchantQr() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerView()),
    );

    if (result != null && mounted) {
      applyScannedData(result);
    }
  }

  void _showUpiInputDialog() {
    final tempVpaController = TextEditingController(text: _vpaController.text);
    final tempNameController = TextEditingController(
      text: _nameController.text,
    );

    final isDark = ThemeController.isDark(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBg(context),
            border: const Border(
              top: BorderSide(color: AppColors.primaryBlue, width: 2.0),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(180)
                    : Colors.black.withAlpha(30),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ENTER MERCHANT UPI ID',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.text(context),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSub(context),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quick Pay Suggestion (if available)
              ValueListenableBuilder<SavedMerchant?>(
                valueListenable: QuickPayService.instance.lastMerchant,
                builder: (context, saved, _) {
                  if (saved == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        tempVpaController.text = saved.vpa;
                        tempNameController.text = saved.name;
                        setModalState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFEFF6FF),
                          border: Border.all(
                            color: AppColors.primaryBlue.withAlpha(140),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Text('⚡', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'QUICK PAY: ${saved.name.toUpperCase()}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                      color: AppColors.primaryBlue,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '${saved.vpa} · ${saved.timeAgoDescription}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSub(context),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'USE ⚡',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // UPI ID (VPA) Input
              const Text(
                'UPI ID (VPA)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: AppColors.border(context),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: tempVpaController,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text(context),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. guptakirana@okhdfcbank',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Quick Handle Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _upiHandles.map((handle) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () {
                          final current = tempVpaController.text
                              .split('@')
                              .first;
                          if (current.isNotEmpty) {
                            tempVpaController.text = '$current$handle';
                          } else {
                            tempVpaController.text = handle;
                          }
                          setModalState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.blueSurface
                                : const Color(0xFFE8F0FE),
                            border: Border.all(
                              color: AppColors.primaryBlue.withAlpha(100),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            handle,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              // Store / Merchant Name Input
              const Text(
                'MERCHANT / STORE NAME (OPTIONAL)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : const Color(0xFFF1F5F9),
                  border: Border.all(
                    color: AppColors.border(context),
                    width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: tempNameController,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Gupta Kirana Store',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Scan QR Alternative Button
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  scanMerchantQr();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF14151B)
                        : const Color(0xFFF1F5F9),
                    border: Border.all(color: AppColors.border(context)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 16,
                        color: AppColors.text(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'OR SCAN MERCHANT QR CODE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.text(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Button
              NeoPopButton(
                color: AppColors.primaryBlue,
                border: Border.all(color: Colors.black, width: 1.5),
                depth: 3.0,
                onTapUp: () {
                  final vpa = tempVpaController.text.trim();
                  if (vpa.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter a valid UPI ID (e.g. store@upi)',
                        ),
                        backgroundColor: AppColors.alertRed,
                      ),
                    );
                    return;
                  }

                  final resolvedName = tempNameController.text.trim().isNotEmpty
                      ? tempNameController.text.trim()
                      : vpa.split('@').first.toUpperCase();

                  QuickPayService.instance.saveMerchant(
                    vpa: vpa,
                    name: resolvedName,
                    amount: double.tryParse(_amountController.text.trim()),
                  );

                  setState(() {
                    _vpaController.text = vpa;
                    _nameController.text = resolvedName;
                    _recalculateOrder();
                  });

                  Navigator.pop(ctx);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      'CONFIRM UPI ID ⚡',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _recalculateOrder() {
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amt <= 0) return;

    final vpa = _vpaController.text.trim().isNotEmpty
        ? _vpaController.text.trim()
        : 'guptakirana@okhdfcbank';
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Gupta Kirana & General Store';

    setState(() {
      _currentOrder = SplitEngine.createTrancheOrder(
        totalAmount: amt,
        merchantVpa: vpa,
        merchantName: name,
        note: _selectedPresetTitle,
      );
    });
  }

  void _openCheckoutDialog() {
    if (_vpaController.text.trim().isEmpty) {
      _showUpiInputDialog();
      return;
    }

    QuickPayService.instance.saveMerchant(
      vpa: _vpaController.text.trim(),
      name: _nameController.text.trim(),
      amount: double.tryParse(_amountController.text.trim()),
    );

    _recalculateOrder();
    if (_currentOrder == null) return;

    SessionLedgerService.instance.registerOrder(_currentOrder!);

    SplitCheckoutDialog.show(
      context,
      order: _currentOrder!,
      onOrderUpdated: (updatedOrder) {
        setState(() {
          _currentOrder = updatedOrder;
          SessionLedgerService.instance.registerOrder(updatedOrder);
          if (updatedOrder.isFullyPaid) {
            _soundboxAnnouncement =
                'SETTLED: ₹${updatedOrder.totalAmount.toStringAsFixed(0)} VIA 0% MDR';
          }
        });
      },
    );
  }

  Widget _buildQuickAddChip(String label, double add, bool isDark) {
    return InkWell(
      onTap: () {
        final current = double.tryParse(_amountController.text.trim()) ?? 0.0;
        final next = (current + add).clamp(0.0, 999999.0);
        _amountController.text = next.toStringAsFixed(0);
        _selectedPresetTitle = 'CUSTOM BILL';
        _recalculateOrder();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF14151C) : const Color(0xFFF1F5F9),
          border: Border.all(
            color: isDark ? const Color(0xFF282A36) : const Color(0xFFCBD5E1),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimary : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _currentOrder;
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final baseMdr = (amt <= 2000 ? 0.0 : (amt * 0.004 > 300 ? 300.0 : amt * 0.004));
    final gstFee = baseMdr * 0.18;
    final totalFee = baseMdr + gstFee;
    final standardFee = totalFee.toStringAsFixed(2);
    final baseMdrStr = baseMdr.toStringAsFixed(2);
    final gstStr = gstFee.toStringAsFixed(2);
    final isVpaSet = _vpaController.text.trim().isNotEmpty;
    final isDark = ThemeController.isDark(context);
    final savedMerchant = QuickPayService.instance.lastMerchant.value;
    final isSavedQuickPay = savedMerchant != null &&
        isVpaSet &&
        savedMerchant.vpa.toLowerCase() ==
            _vpaController.text.trim().toLowerCase();

    return Column(
      children: [
        // Main Scrollable Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Soundbox Live Broadcast Bar
                if (_soundboxAnnouncement != null) ...[
                  SoundboxSpeakerWidget(
                    announcementText: _soundboxAnnouncement,
                    isPlaying: order?.isFullyPaid ?? false,
                  ),
                  const SizedBox(height: 12),
                ],

                // CRED NeoPOP Quick Pay Banner (1-tap use saved merchant)
                ValueListenableBuilder<SavedMerchant?>(
                  valueListenable: QuickPayService.instance.lastMerchant,
                  builder: (context, saved, _) {
                    if (saved == null) return const SizedBox.shrink();
                    final isApplied = isVpaSet &&
                        _vpaController.text.trim().toLowerCase() ==
                            saved.vpa.toLowerCase();
                    if (isApplied) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NeoPopCard(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFEFF6FF),
                        borderColor: AppColors.primaryBlue,
                        depth: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.bolt,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              'QUICK PAY',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.8,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'SAVED MERCHANT · ${saved.timeAgoDescription.toUpperCase()}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                          color: AppColors.textSub(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      QuickPayService.instance
                                          .clearSavedMerchant();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppColors.textSub(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          saved.name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.4,
                                            color: AppColors.text(context),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          saved.vpa,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryBlue,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  NeoPopButton(
                                    color: AppColors.primaryBlue,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.2,
                                    ),
                                    depth: 2,
                                    onTapUp: () {
                                      setState(() {
                                        _vpaController.text = saved.vpa;
                                        _nameController.text = saved.name;
                                        _recalculateOrder();
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '⚡ Quick Pay: Loaded ${saved.name}',
                                          ),
                                          duration: const Duration(
                                            seconds: 2,
                                          ),
                                          backgroundColor:
                                              AppColors.primaryBlueDark,
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.bolt,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '1-TAP PAY',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.8,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // CRED NeoPOP Merchant Bar (Tap to Enter / Change UPI ID)
                NeoPopCard(
                  color: isVpaSet
                      ? AppColors.cardBg(context)
                      : (isDark
                            ? const Color(0xFF14151B)
                            : AppColors.lightSurfaceElevated),
                  borderColor: isVpaSet
                      ? AppColors.border(context)
                      : AppColors.primaryBlue,
                  depth: 3,
                  child: InkWell(
                    onTap: _showUpiInputDialog,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black
                                  : const Color(0xFFE2E8F0),
                              border: Border.all(
                                color: isVpaSet
                                    ? AppColors.primaryBlue
                                    : AppColors.goldenYellow,
                                width: 1.0,
                              ),
                            ),
                            child: Icon(
                              isVpaSet
                                  ? Icons.storefront_sharp
                                  : Icons.add_link_rounded,
                              size: 16,
                              color: isVpaSet
                                  ? AppColors.primaryBlue
                                  : AppColors.goldenYellow,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isVpaSet
                                          ? 'PAYING TO UPI ID'
                                          : 'MERCHANT UPI ID (REQUIRED)',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                        color: isVpaSet
                                            ? AppColors.textSub(context)
                                            : AppColors.primaryBlue,
                                      ),
                                    ),
                                    if (isSavedQuickPay) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue
                                              .withAlpha(isDark ? 50 : 30),
                                          border: Border.all(
                                            color: AppColors.primaryBlue,
                                            width: 0.8,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: const Text(
                                          '⚡ QUICK PAY',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.6,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isVpaSet
                                      ? '${_nameController.text.toUpperCase()} (${_vpaController.text})'
                                      : 'TAP TO SET UPI ID / VPA',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: isVpaSet
                                        ? AppColors.text(context)
                                        : AppColors.goldenYellow,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black
                                  : const Color(0xFFE2E8F0),
                              border: Border.all(
                                color: AppColors.border(context),
                              ),
                            ),
                            child: Text(
                              isVpaSet ? 'EDIT ▾' : 'ENTER ▾',
                              style: TextStyle(
                                color: AppColors.text(context),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // CRED NeoPOP Amount Card
                NeoPopCard(
                  color: AppColors.cardBg(context),
                  borderColor: AppColors.border(context),
                  depth: 4,
                  child: Stack(
                    children: [
                      // Authentic Banknote Security Watermark (White lining in Dark mode, Electric Blue in Light mode)
                      Positioned(
                        right: -5,
                        top: -5,
                        bottom: 25,
                        child: IgnorePointer(
                          child: ShaderMask(
                            shaderCallback: (rect) {
                              return RadialGradient(
                                center: Alignment.center,
                                radius: 0.85,
                                colors: [
                                  Colors.white.withAlpha(
                                    isDark ? 56 : 66,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const [0.6, 1.0],
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.dstIn,
                            child: Image.asset(
                              'assets/images/gandhi_currency.png',
                              color: isDark
                                  ? Colors.white
                                  : AppColors.primaryBlue,
                              colorBlendMode: BlendMode.srcIn,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TOTAL BILL AMOUNT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: AppColors.textSub(context),
                                  ),
                                ),
                                const Text(
                                  'NPCI 0.4% CAP: ₹2,000',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryBlue,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '₹',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.text(context),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.text(context),
                                      letterSpacing: -1.0,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      hintText: '0',
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF383B46)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    onChanged: (_) {
                                      _selectedPresetTitle = 'CUSTOM BILL';
                                      _recalculateOrder();
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Mobile-first Quick Increment Micro-Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildQuickAddChip('+₹100', 100, isDark),
                                  const SizedBox(width: 6),
                                  _buildQuickAddChip('+₹500', 500, isDark),
                                  const SizedBox(width: 6),
                                  _buildQuickAddChip('+₹1,000', 1000, isDark),
                                  const SizedBox(width: 6),
                                  _buildQuickAddChip('+₹2,000', 2000, isDark),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      _amountController.text = '0';
                                      _selectedPresetTitle = 'CUSTOM BILL';
                                      _recalculateOrder();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E2028)
                                            : const Color(0xFFE2E8F0),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'CLEAR',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                          color: isDark
                                              ? AppColors.textSecondary
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),

                            // CRED NeoPOP Preset Buttons
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _kiranaPresets.map((preset) {
                                  final isSelected =
                                      _amountController.text ==
                                      preset.amount.toStringAsFixed(0);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: NeoPopButton(
                                      color: isSelected
                                          ? (isDark
                                                ? Colors.white
                                                : AppColors.primaryBlue)
                                          : AppColors.cardElevated(context),
                                      border: Border.all(
                                        color: isSelected
                                            ? (isDark
                                                  ? Colors.white
                                                  : AppColors.primaryBlue)
                                            : AppColors.border(context),
                                        width: 1.2,
                                      ),
                                      depth: 2,
                                      onTapUp: () {
                                        _amountController.text = preset.amount
                                            .toStringAsFixed(0);
                                        _selectedPresetTitle = preset.title;
                                        _recalculateOrder();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              preset.title,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
                                                color: isSelected
                                                    ? (isDark
                                                          ? Colors.black
                                                          : Colors.white)
                                                    : AppColors.text(context),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '₹${preset.amount.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: isSelected
                                                    ? (isDark
                                                          ? Colors.black
                                                          : Colors.white)
                                                    : AppColors.primaryBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // CRED NeoPOP Arbitrage Shield Card
                NeoPopCard(
                  color: isDark
                      ? const Color(0xFF0F1014)
                      : AppColors.cardBg(context),
                  borderColor: AppColors.border(context),
                  depth: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ARBITRAGE BREAKDOWN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: AppColors.textSub(context),
                              ),
                            ),
                            Text(
                              'ZERO MDR POLICY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: isDark
                                    ? AppColors.textMuted
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black
                                      : const Color(0xFFF8FAFC),
                                  border: Border.all(
                                    color: AppColors.border(context),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'REGULAR GPAY',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AppColors.textMuted
                                            : AppColors.lightTextMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '+₹$standardFee FEE',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.alertRed,
                                      ),
                                    ),
                                    Text(
                                      '0.4% MDR + 18% GST',
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.textMuted
                                            : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black
                                      : const Color(0xFFF0F7FF),
                                  border: Border.all(
                                    color: AppColors.primaryBlue,
                                    width: 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SPLITPE (0% MDR)',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      '₹0.00 (100% FREE)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    Text(
                                      '0% MDR · 0% GST',
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBlue.withAlpha(200),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          color: AppColors.chipBg(context),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? AppColors.blueSurface
                                      : const Color(0xFFE8F0FE),
                                  border: Border.all(
                                    color: AppColors.primaryBlue.withAlpha(160),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.savings_outlined,
                                    size: 16,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GANDHIS SAVED (MDR + GST)',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: AppColors.text(context),
                                      ),
                                    ),
                                    Text(
                                      amt <= 2000
                                          ? 'Transactions ≤ ₹2,000 are already free'
                                          : 'Saved ₹$baseMdrStr MDR + ₹$gstStr GST (18%)',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.textMuted
                                            : AppColors.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '+₹$standardFee',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (order != null && order.tranches.length > 1) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DYNAMIC ZERO-MDR TRANCHES',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: AppColors.textSub(context),
                                ),
                              ),
                              NeoPopButton(
                                color: isDark
                                    ? const Color(0xFF161822)
                                    : const Color(0xFFE8F0FE),
                                border: Border.all(
                                  color: AppColors.primaryBlue.withAlpha(150),
                                  width: 1.0,
                                ),
                                depth: 1.5,
                                onTapUp: _recalculateOrder,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('🎲', style: TextStyle(fontSize: 11)),
                                      SizedBox(width: 4),
                                      Text(
                                        'RE-ROLL',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primaryBlue,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: order.tranches.map((t) {
                              final delayStr = t.suggestedDelaySeconds == 0
                                  ? '⚡ Instant'
                                  : '⏱ +${t.suggestedDelaySeconds}s';
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF14161F)
                                      : const Color(0xFFF1F5F9),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF282C3C)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue
                                            .withAlpha(isDark ? 50 : 30),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        '#${t.index}',
                                        style: const TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '₹${t.amount.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.text(context),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      delayStr,
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AppColors.textSecondary
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Educational Disclaimer Pill
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141418)
                          : const Color(0xFFEDF2F7),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF26262E)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('⚖️', style: TextStyle(fontSize: 10)),
                        SizedBox(width: 6),
                        Text(
                          'FOR EDUCATIONAL & RESEARCH PURPOSES ONLY',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // STICKY CRED NEOPOP 3D PRIMARY CTA (Official CRED NeoPopTiltedButton)
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            color: AppColors.bg(context),
            border: Border(
              top: BorderSide(color: AppColors.border(context), width: 1.0),
            ),
          ),
          child: NeoPopTiltedButton(
            isFloating: true,
            onTapUp: _openCheckoutDialog,
            decoration: const NeoPopTiltedButtonDecoration(
              color: AppColors.primaryBlue,
              plunkColor: AppColors.primaryBlueDark,
              shadowColor: Color(0xFF000000),
              showShimmer: true,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isVpaSet
                        ? 'BYPASS ₹$standardFee FEE · PAY ON UPI'
                        : 'ENTER UPI ID · PAY ON UPI ⚡',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
