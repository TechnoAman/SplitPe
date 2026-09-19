import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import '../l10n/app_strings.dart';
import '../models/split_order.dart';
import '../services/currency_formatter.dart';
import '../services/split_engine.dart';
import '../services/upi_validator.dart';
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
  final _amountController = TextEditingController(text: '3,850');
  final _vpaController = TextEditingController(text: '');
  final _nameController = TextEditingController(text: '');

  SplitOrder? _currentOrder;
  String? _soundboxAnnouncement;
  String? _selectedPresetTitle;

  List<KiranaPreset> get _kiranaPresets => [
    KiranaPreset(title: AppStrings.presetAttaOil, amount: 2450),
    KiranaPreset(title: AppStrings.presetDairyGhee, amount: 3200),
    KiranaPreset(title: AppStrings.presetDhabaDinner, amount: 3850),
    KiranaPreset(title: AppStrings.presetDryFruits, amount: 4500),
    KiranaPreset(title: AppStrings.presetFullRation, amount: 7500),
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

    setState(() {
      if (vpa.isNotEmpty) _vpaController.text = vpa;
      if (name.isNotEmpty) _nameController.text = Uri.decodeComponent(name);
      if (am.isNotEmpty &&
          double.tryParse(am) != null &&
          double.parse(am) > 0) {
        _amountController.text = IndianNumberFormat.format(double.parse(am));
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: AppColors.border(context), width: 1.2),
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
                    AppStrings.enterMerchantUpiId,
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

              // UPI ID (VPA) Input
              Text(
                AppStrings.upiIdVpa,
                style: const TextStyle(
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
              Text(
                AppStrings.merchantNameOptional,
                style: const TextStyle(
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
                  final validation = UpiValidator.validate(vpa);
                  if (!validation.isValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          validation.errorMessage ??
                              'Please enter a valid UPI ID (e.g. store@upi)',
                        ),
                        backgroundColor: AppColors.alertRed,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _vpaController.text = validation.vpa!;
                    _nameController.text =
                        tempNameController.text.trim().isNotEmpty
                        ? tempNameController.text.trim()
                        : validation.merchantName!;
                    _recalculateOrder();
                  });

                  Navigator.pop(ctx);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text(
                      AppStrings.saveUpiId,
                      style: const TextStyle(
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
    final amt = IndianNumberFormat.parseAmount(_amountController.text);
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
        note: _selectedPresetTitle ?? AppStrings.customBill,
      );
    });
  }

  void _openCheckoutDialog() {
    if (_vpaController.text.trim().isEmpty) {
      _showUpiInputDialog();
      return;
    }

    _recalculateOrder();
    if (_currentOrder == null) return;

    SplitCheckoutDialog.show(
      context,
      order: _currentOrder!,
      onOrderUpdated: (updatedOrder) {
        setState(() {
          _currentOrder = updatedOrder;
          if (updatedOrder.isFullyPaid) {
            _soundboxAnnouncement =
                'SETTLED: ₹${IndianNumberFormat.format(updatedOrder.totalAmount)} VIA 0% MDR';
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _currentOrder;
    final amt = IndianNumberFormat.parseAmount(_amountController.text);
    final baseMdr = (amt <= 2000
        ? 0.0
        : (amt * 0.004 > 300 ? 300.0 : amt * 0.004));
    final gstFee = baseMdr * 0.18;
    final totalFee = baseMdr + gstFee;
    final standardFee = IndianNumberFormat.formatWithDecimals(totalFee, 2);
    final baseMdrStr = IndianNumberFormat.formatWithDecimals(baseMdr, 2);
    final gstStr = IndianNumberFormat.formatWithDecimals(gstFee, 2);
    final isVpaSet = _vpaController.text.trim().isNotEmpty;
    final isDark = ThemeController.isDark(context);

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
                                Text(
                                  isVpaSet
                                      ? AppStrings.payingToUpiId
                                      : AppStrings.merchantUpiIdRequired,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: isVpaSet
                                        ? AppColors.textSub(context)
                                        : AppColors.primaryBlue,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isVpaSet
                                      ? '${_nameController.text.toUpperCase()} (${_vpaController.text})'
                                      : AppStrings.tapToSetUpiId,
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
                                if (isVpaSet) ...[
                                  Builder(
                                    builder: (context) {
                                      final val = UpiValidator.validate(
                                        _vpaController.text,
                                      );
                                      if (val.issuerLabel != null) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.verified_outlined,
                                                size: 11,
                                                color: AppColors.primaryBlue,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                val.issuerLabel!,
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ],
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
                              isVpaSet ? 'EDIT ▾' : AppStrings.btnEnter,
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
                              AppStrings.totalBillAmount,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: AppColors.textSub(context),
                              ),
                            ),
                            Text(
                              AppStrings.npciCap,
                              style: const TextStyle(
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
                                inputFormatters: [
                                  IndianCurrencyInputFormatter(
                                    allowDecimals: true,
                                  ),
                                ],
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
                                  _selectedPresetTitle = AppStrings.customBill;
                                  _recalculateOrder();
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // CRED NeoPOP Preset Buttons
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _kiranaPresets.map((preset) {
                              final currentVal =
                                  IndianNumberFormat.parseAmount(
                                    _amountController.text,
                                  );
                              final isSelected =
                                  currentVal == preset.amount;
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
                                    _amountController.text =
                                        IndianNumberFormat.format(
                                          preset.amount,
                                        );
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
                                          '₹${IndianNumberFormat.format(preset.amount)}',
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
                              AppStrings.arbitrageBreakdown,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: AppColors.textSub(context),
                              ),
                            ),
                            Text(
                              AppStrings.zeroMdrPolicy,
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
                                      AppStrings.regularGpay,
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
                                      '+₹$standardFee ${AppStrings.feeTag}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.alertRed,
                                      ),
                                    ),
                                    Text(
                                      AppStrings.regularMdrDesc,
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
                                    Text(
                                      AppStrings.splitpeZeroMdr,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      AppStrings.free100Percent,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                    Text(
                                      AppStrings.zeroMdrGstDesc,
                                      style: TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBlue.withAlpha(
                                          200,
                                        ),
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
                                      AppStrings.gandhisSaved,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: AppColors.text(context),
                                      ),
                                    ),
                                    Text(
                                      amt <= 2000
                                          ? AppStrings.under2000Free
                                          : AppStrings.savingsDesc(baseMdrStr, gstStr),
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
                                AppStrings.dynamicTranches,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: AppColors.textSub(context),
                                ),
                              ),
                              InkWell(
                                onTap: _recalculateOrder,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black : Colors.white,
                                    border: Border.all(
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '🎲',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        AppStrings.reRoll,
                                        style: const TextStyle(
                                          fontSize: 8.5,
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
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: order.tranches.map((t) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF14151B)
                                      : const Color(0xFFF1F5F9),
                                  border: Border.all(
                                    color: AppColors.border(context),
                                  ),
                                ),
                                child: Text(
                                  '#${t.index}: ₹${IndianNumberFormat.format(t.amount)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text(context),
                                  ),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚖️', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 6),
                        Text(
                          AppStrings.educationalDisclaimer,
                          style: const TextStyle(
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
              shadowColor: Color(0xFF003C8F),
              showShimmer: true,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Text(
                  isVpaSet
                      ? (amt <= 2000
                            ? AppStrings.enterUpiId
                            : AppStrings.bypassFeePayUpi(standardFee))
                      : AppStrings.enterUpiId,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
