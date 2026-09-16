import 'package:flutter/material.dart';
import '../models/split_order.dart';
import '../services/split_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/soundbox_speaker_widget.dart';
import '../widgets/split_checkout_modal.dart';
import 'qr_scanner_view.dart';

class KiranaPreset {
  final String title;
  final double amount;
  final String icon;

  const KiranaPreset({
    required this.title,
    required this.amount,
    required this.icon,
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
  String _selectedPresetTitle = 'Custom Bill';

  static const List<KiranaPreset> _kiranaPresets = [
    KiranaPreset(title: '🌾 Atta & Oil', amount: 2450, icon: '🌾'),
    KiranaPreset(title: '🧈 Dairy & Ghee', amount: 3200, icon: '🧈'),
    KiranaPreset(title: '🍽️ Dhaba Dinner', amount: 3850, icon: '🍽️'),
    KiranaPreset(title: '🥜 Dry Fruits', amount: 4500, icon: '🥜'),
    KiranaPreset(title: '🛒 Full Ration', amount: 7500, icon: '🛒'),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⚡ Payee set: ${_nameController.text.isNotEmpty ? _nameController.text : _vpaController.text}',
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E22),
        duration: const Duration(seconds: 2),
      ),
    );

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
                '🎉 Bill of ₹${updatedOrder.totalAmount.toStringAsFixed(0)} settled with 0% MDR!';
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
    final perTrancheAmount = trancheCount > 0 ? (amt / trancheCount).toStringAsFixed(2) : '0.00';

    return Column(
      children: [
        // Top Scrollable Content Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Soundbox Live Broadcast Bar
                SoundboxSpeakerWidget(
                  announcementText: _soundboxAnnouncement,
                  isPlaying: order?.isFullyPaid ?? false,
                ),

                const SizedBox(height: 10),

                // Merchant Profile Card
                InkWell(
                  onTap: scanMerchantQr,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141417),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _vpaController.text.isNotEmpty
                            ? AppColors.primaryGreen.withAlpha(80)
                            : const Color(0xFF27272A),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E2620),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 18,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _nameController.text.isNotEmpty
                                          ? _nameController.text
                                          : 'Gupta Kirana & General Store',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 13),
                                ],
                              ),
                              Text(
                                _vpaController.text.isNotEmpty
                                    ? _vpaController.text
                                    : 'guptakirana@okhdfcbank',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
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
                            color: const Color(0xFF222228),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.qr_code_scanner_rounded, size: 11, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'SCAN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Bill Amount Input Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141417),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF27272A), width: 1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ENTER BILL AMOUNT',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '₹',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1.0,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: '0',
                                hintStyle: TextStyle(color: Color(0xFF52525B)),
                              ),
                              onChanged: (_) {
                                _selectedPresetTitle = 'Custom Bill';
                                _recalculateOrder();
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Kirana & Everyday Jugaad Presets
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _kiranaPresets.map((preset) {
                            final isSelected = _amountController.text == preset.amount.toStringAsFixed(0);
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: () {
                                  _amountController.text = preset.amount.toStringAsFixed(0);
                                  _selectedPresetTitle = preset.title;
                                  _recalculateOrder();
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : const Color(0xFF1E1E24),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? Colors.white : const Color(0xFF2E2E34),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        preset.title,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? Colors.black : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '₹${preset.amount.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected ? Colors.black : AppColors.primaryGreen,
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

                const SizedBox(height: 10),

                // THE VIRAL SIDE-BY-SIDE ARBITRAGE COMPARISON CARD
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111114),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF27272A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'NPCI 0.4% ARBITRAGE ENGINE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '> ₹2,000 CAP',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Comparison Columns
                      Row(
                        children: [
                          // Column 1: Normal GPay / PhonePe
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF2E2E34)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '❌ Normal UPI',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '+₹$standardFee Fee',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFF43F5E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Column 2: SplitPe Zero-MDR
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16251C),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryGreen.withAlpha(80)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⚡ $trancheCount Splits (~₹$perTrancheAmount)',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '₹0.00 (100% Free)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Net Surcharge Saved Highlight
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2A20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Surcharge Saved',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            Text(
                              '+₹$standardFee',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sticky Bottom CTA (ALWAYS Visible, Never Hidden, No Scrolling Needed!)
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF0F0F12),
            border: Border(
              top: BorderSide(color: Color(0xFF202024), width: 1.0),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _openCheckoutDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: Colors.black, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Bypass ₹$standardFee Fee · Pay on UPI',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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
