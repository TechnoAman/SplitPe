import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import '../models/split_order.dart';
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
    KiranaPreset(title: 'ATTA & OIL', amount: 2450),
    KiranaPreset(title: 'DAIRY & GHEE', amount: 3200),
    KiranaPreset(title: 'DHABA DINNER', amount: 3850),
    KiranaPreset(title: 'DRY FRUITS', amount: 4500),
    KiranaPreset(title: 'FULL RATION', amount: 7500),
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
          decoration: const BoxDecoration(
            color: Color(0xFF0F1014),
            border: Border(
              top: BorderSide(color: AppColors.primaryGreen, width: 2.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ENTER MERCHANT UPI ID',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
                  color: Colors.black,
                  border: Border.all(color: AppColors.neoBorder, width: 1.2),
                ),
                child: TextField(
                  controller: tempVpaController,
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. guptakirana@okhdfcbank',
                    hintStyle: TextStyle(
                      color: Color(0xFF4A4E5C),
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
                            color: const Color(0xFF1B1C22),
                            border: Border.all(color: const Color(0xFF2E303A)),
                          ),
                          child: Text(
                            handle,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
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
                  color: Colors.black,
                  border: Border.all(color: AppColors.neoBorder, width: 1.2),
                ),
                child: TextField(
                  controller: tempNameController,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Gupta Kirana Store',
                    hintStyle: TextStyle(
                      color: Color(0xFF4A4E5C),
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
                    color: const Color(0xFF14151B),
                    border: Border.all(color: const Color(0xFF2E303A)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'OR SCAN MERCHANT QR CODE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Confirm Button
              NeoPopButton(
                color: AppColors.primaryGreen,
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

                  setState(() {
                    _vpaController.text = vpa;
                    _nameController.text =
                        tempNameController.text.trim().isNotEmpty
                        ? tempNameController.text.trim()
                        : vpa.split('@').first.toUpperCase();
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
                        color: Colors.black,
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
                'SETTLED: ₹${updatedOrder.totalAmount.toStringAsFixed(0)} VIA 0% MDR';
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = _currentOrder;
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final trancheCount = (amt / 1999.0).ceil();
    final standardFee = (amt * 0.004).toStringAsFixed(2);
    final isVpaSet = _vpaController.text.trim().isNotEmpty;

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
                  color: isVpaSet ? AppColors.surface : const Color(0xFF14151B),
                  borderColor: isVpaSet
                      ? AppColors.neoBorder
                      : AppColors.primaryGreen,
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
                              color: Colors.black,
                              border: Border.all(
                                color: isVpaSet
                                    ? AppColors.primaryGreen
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
                                  ? AppColors.primaryGreen
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
                                      ? 'PAYING TO UPI ID'
                                      : 'MERCHANT UPI ID (REQUIRED)',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: isVpaSet
                                        ? AppColors.textMuted
                                        : AppColors.primaryGreen,
                                  ),
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
                                        ? Colors.white
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
                              color: Colors.black,
                              border: Border.all(color: AppColors.neoBorder),
                            ),
                            child: Text(
                              isVpaSet ? 'EDIT ▾' : 'ENTER ▾',
                              style: const TextStyle(
                                color: Colors.white,
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
                  color: AppColors.surface,
                  borderColor: AppColors.neoBorder,
                  depth: 4,
                  child: Stack(
                    children: [
                      // Subdued Banknote Security Watermark
                      Positioned(
                        right: -10,
                        top: -10,
                        bottom: -10,
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.09,
                            child: Image.asset(
                              'assets/images/gandhi_currency.png',
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
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TOTAL BILL AMOUNT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  'NPCI 0.4% CAP: ₹2,000',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryGreen,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  '₹',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1.0,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      hintText: '0',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF383B46),
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
                                      ? Colors.white
                                      : AppColors.surfaceElevated,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.neoBorder,
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
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '₹${preset.amount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: isSelected
                                                ? Colors.black
                                                : AppColors.primaryGreen,
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
                  color: const Color(0xFF0F1014),
                  borderColor: AppColors.neoBorder,
                  depth: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ARBITRAGE BREAKDOWN',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'ZERO MDR POLICY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.textMuted,
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
                                  color: Colors.black,
                                  border: Border.all(
                                    color: const Color(0xFF2E303A),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'REGULAR GPAY',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '+₹$standardFee FEE',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.alertRed,
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
                                  color: Colors.black,
                                  border: Border.all(
                                    color: AppColors.primaryGreen,
                                    width: 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'SPLITPE ($trancheCount TRANCHES)',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '₹0.00 (100% FREE)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.primaryGreen,
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
                          color: const Color(0xFF16281D),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.primaryGreen.withAlpha(120),
                                  ),
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/gandhi_currency.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GANDHIS SAVED FROM MDR',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Real cash retained in pocket',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textMuted,
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
                                  color: AppColors.primaryGreen,
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
                              const Text(
                                'DYNAMIC ZERO-MDR TRANCHES',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: AppColors.textSecondary,
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
                                    color: Colors.black,
                                    border: Border.all(
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '🎲',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'RE-ROLL',
                                        style: TextStyle(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.primaryGreen,
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
                                  color: const Color(0xFF14151B),
                                  border: Border.all(
                                    color: const Color(0xFF26262E),
                                  ),
                                ),
                                child: Text(
                                  '#${t.index}: ₹${t.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
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
                      color: const Color(0xFF141418),
                      border: Border.all(color: const Color(0xFF26262E)),
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
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(color: Color(0xFF1E2026), width: 1.0),
            ),
          ),
          child: NeoPopTiltedButton(
            isFloating: true,
            onTapUp: _openCheckoutDialog,
            decoration: const NeoPopTiltedButtonDecoration(
              color: AppColors.primaryGreen,
              plunkColor: Color(0xFF00A859),
              shadowColor: Color(0xFF000000),
              showShimmer: true,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: Colors.black, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isVpaSet
                        ? 'BYPASS ₹$standardFee FEE · PAY ON UPI'
                        : 'ENTER UPI ID · PAY ON UPI ⚡',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
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
