import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import '../models/split_order.dart';
import '../services/split_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/neopop_components.dart';
import '../widgets/soundbox_speaker_widget.dart';
import '../widgets/split_checkout_modal.dart';
import 'qr_scanner_view.dart';

class PosCheckoutView extends StatefulWidget {
  final Map<String, String>? initialScannedData;
  const PosCheckoutView({super.key, this.initialScannedData});

  @override
  State<PosCheckoutView> createState() => PosCheckoutViewState();
}

class PosCheckoutViewState extends State<PosCheckoutView> {
  final _amountController = TextEditingController(text: '7500');
  final _vpaController = TextEditingController(text: '');
  final _nameController = TextEditingController(text: '');

  SplitOrder? _currentOrder;
  String? _soundboxAnnouncement;

  final List<double> _quickAmounts = [3500, 5800, 7500, 10000, 15000, 25000];

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
          '⚡ Loaded Payee: ${_nameController.text.isNotEmpty ? _nameController.text : _vpaController.text}',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    // Auto-open checkout modal on scan
    _openCheckoutModal();
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
        : 'payee@upi';
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Store Checkout';

    setState(() {
      _currentOrder = SplitEngine.createTrancheOrder(
        totalAmount: amt,
        merchantVpa: vpa,
        merchantName: name,
        note: 'Bill Payment',
      );
    });
  }

  void _openCheckoutModal() {
    _recalculateOrder();
    if (_currentOrder == null) return;

    SplitCheckoutModal.show(
      context,
      order: _currentOrder!,
      onOrderUpdated: (updatedOrder) {
        setState(() {
          _currentOrder = updatedOrder;
          if (updatedOrder.isFullyPaid) {
            _soundboxAnnouncement =
                '🎉 Bill of ₹${updatedOrder.totalAmount.toStringAsFixed(0)} 100% settled with ₹0 MDR fee!';
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
    final potentialSavings = (amt * 0.004).toStringAsFixed(2);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Soundbox Live Broadcast Bar
          SoundboxSpeakerWidget(
            announcementText: _soundboxAnnouncement,
            isPlaying: order?.isFullyPaid ?? false,
          ),

          const SizedBox(height: 14),

          // Main Setup Card (Payee + Amount)
          NeoPopSurfaceCard(
            backgroundColor: const Color(0xFF101012),
            borderColor: AppColors.neoBorder,
            depth: 4.0,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payee Selector Banner
                InkWell(
                  onTap: scanMerchantQr,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: _vpaController.text.isNotEmpty
                          ? const Color(0xFF16251C)
                          : const Color(0xFF18181B),
                      border: Border.all(
                        color: _vpaController.text.isNotEmpty
                            ? AppColors.primaryGreen
                            : AppColors.cardBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _vpaController.text.isNotEmpty
                              ? Icons.verified_user_rounded
                              : Icons.qr_code_scanner_rounded,
                          size: 20,
                          color: _vpaController.text.isNotEmpty
                              ? AppColors.primaryGreen
                              : AppColors.neonCyan,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text
                                    : (_vpaController.text.isNotEmpty
                                        ? _vpaController.text
                                        : 'Scan Merchant QR Code'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: _vpaController.text.isNotEmpty
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _vpaController.text.isNotEmpty
                                    ? _vpaController.text
                                    : 'Tap to scan counter standee or QR',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _vpaController.text.isNotEmpty
                                      ? AppColors.primaryGreen
                                      : AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        NeoPopPillBadge(
                          label: _vpaController.text.isNotEmpty ? 'CHANGE' : 'SCAN 📷',
                          color: AppColors.primaryGreen,
                          textColor: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),

                const Text(
                  'ENTER BILL AMOUNT (INR)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -1.0,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                        ),
                        onChanged: (_) => _recalculateOrder(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Quick Amount Selection Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickAmounts.map((qAmt) {
                      final isSelected = _amountController.text == qAmt.toStringAsFixed(0);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: NeoPopButton(
                          color: isSelected ? AppColors.primaryGreen : const Color(0xFF1E1E22),
                          bottomShadowColor: Colors.black,
                          rightShadowColor: Colors.black,
                          depth: isSelected ? 3.0 : 1.5,
                          border: Border.all(
                            color: isSelected ? Colors.black : AppColors.cardBorder,
                            width: 1.2,
                          ),
                          onTapUp: () {
                            _amountController.text = qAmt.toStringAsFixed(0);
                            _recalculateOrder();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              '₹${qAmt.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.black : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // MDR Arbitrage Info Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141416),
                    border: Border.all(color: AppColors.neoBorder, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt, color: AppColors.primaryGreen, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Auto-splits into $trancheCount tranches',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        'Saves ₹$potentialSavings MDR',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Primary Launch Checkout Modal Action
          NeoPopActionButton(
            text: 'PROCEED TO PAY ₹${amt.toStringAsFixed(0)} (0% MDR) ⚡',
            color: AppColors.primaryGreen,
            textColor: Colors.black,
            prefixIcon: const Icon(Icons.lock_open_rounded, color: Colors.black, size: 18),
            onTap: _openCheckoutModal,
          ),

          if (order != null && order.paidAmount > 0) ...[
            const SizedBox(height: 16),
            // Active Payment Status Bar
            InkWell(
              onTap: _openCheckoutModal,
              child: NeoPopSurfaceCard(
                backgroundColor: const Color(0xFF161618),
                borderColor: AppColors.primaryGreen,
                depth: 3.0,
                padding: const EdgeInsets.all(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          order.isFullyPaid ? Icons.check_circle : Icons.timelapse_rounded,
                          color: order.isFullyPaid ? AppColors.primaryGreen : AppColors.goldenYellow,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.isFullyPaid ? 'Bill Fully Settled' : 'Payment In Progress',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            Text(
                              '₹${order.paidAmount.toStringAsFixed(0)} / ₹${order.totalAmount.toStringAsFixed(0)} Settled',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const NeoPopPillBadge(
                      label: 'RESUME →',
                      color: AppColors.primaryGreen,
                      textColor: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
