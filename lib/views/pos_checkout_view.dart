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

  const KiranaPreset({
    required this.title,
    required this.amount,
  });
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
      if (am.isNotEmpty && double.tryParse(am) != null && double.parse(am) > 0) {
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

                // CRED NeoPOP Merchant Bar
                NeoPopCard(
                  color: AppColors.surface,
                  borderColor: AppColors.neoBorder,
                  depth: 2,
                  child: InkWell(
                    onTap: scanMerchantQr,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: AppColors.primaryGreen, width: 1.0),
                            ),
                            child: const Icon(
                              Icons.storefront_sharp,
                              size: 16,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PAYING TO MERCHANT',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _nameController.text.isNotEmpty
                                      ? _nameController.text.toUpperCase()
                                      : 'GUPTA KIRANA & STORE',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: AppColors.neoBorder),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.qr_code_scanner, size: 10, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'SCAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
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
                  child: Padding(
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
                                  hintStyle: TextStyle(color: Color(0xFF383B46)),
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
                                  _amountController.text == preset.amount.toStringAsFixed(0);
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: NeoPopButton(
                                  color: isSelected ? Colors.white : AppColors.surfaceElevated,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : AppColors.neoBorder,
                                    width: 1.2,
                                  ),
                                  depth: 2,
                                  onTapUp: () {
                                    _amountController.text = preset.amount.toStringAsFixed(0);
                                    _selectedPresetTitle = preset.title;
                                    _recalculateOrder();
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    child: Row(
                                      children: [
                                        Text(
                                          preset.title,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                            color: isSelected ? Colors.black : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '₹${preset.amount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color:
                                                isSelected ? Colors.black : AppColors.primaryGreen,
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
                                  border: Border.all(color: const Color(0xFF2E303A)),
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
                                  border: Border.all(color: AppColors.primaryGreen, width: 1.0),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          color: const Color(0xFF16281D),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL SURCHARGE SAVED',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '+₹$standardFee',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
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
                    'BYPASS ₹$standardFee FEE · PAY ON UPI',
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
