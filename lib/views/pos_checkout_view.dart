import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:neopop/neopop.dart';
import '../models/split_order.dart';
import '../models/tranche.dart';
import '../services/split_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/clout_share_modal.dart';
import '../widgets/neopop_components.dart';
import '../widgets/qr_tranche_card.dart';
import '../widgets/soundbox_speaker_widget.dart';
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

  late ConfettiController _confettiController;
  SplitOrder? _currentOrder;
  String? _soundboxAnnouncement;

  final List<double> _quickAmounts = [3500, 5800, 7500, 10000, 15000, 25000];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.initialScannedData != null) {
      applyScannedData(widget.initialScannedData!);
    } else {
      _generateSplitOrder();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _vpaController.dispose();
    _nameController.dispose();
    _confettiController.dispose();
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
      _generateSplitOrder();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⚡ Scanned Payee: ${_nameController.text.isNotEmpty ? _nameController.text : _vpaController.text}',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
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

  void _generateSplitOrder() {
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
      _soundboxAnnouncement =
          'Split into ${_currentOrder!.tranches.length} tranches. Zero MDR active!';
    });
  }

  void _simulatePayTranche(Tranche tranche) {
    if (_currentOrder == null || tranche.isPaid) return;

    setState(() {
      tranche.status = TrancheStatus.paid;
      tranche.paidAt = DateTime.now();
      tranche.txnRef = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final saved = (tranche.amount * 0.004).toStringAsFixed(2);
      _soundboxAnnouncement =
          '🔊 ₹${tranche.amount.toStringAsFixed(0)} received on SplitPe! Zero MDR charged (Saved ₹$saved)';

      if (_currentOrder!.isFullyPaid) {
        _confettiController.play();
        _soundboxAnnouncement =
            '🎉 Full Bill of ₹${_currentOrder!.totalAmount.toStringAsFixed(0)} settled with ₹0 MDR! (Total Saved: ₹${_currentOrder!.mdrSavings.toStringAsFixed(2)})';
      }
    });
  }

  void _simulatePayAll() {
    if (_currentOrder == null) return;
    setState(() {
      for (var t in _currentOrder!.tranches) {
        t.status = TrancheStatus.paid;
        t.paidAt = DateTime.now();
        t.txnRef = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      }
      _confettiController.play();
      _soundboxAnnouncement =
          '🎉 100% Bill Settled! Saved ₹${_currentOrder!.mdrSavings.toStringAsFixed(2)} MDR on SplitPe!';
    });
  }

  void _resetOrder() {
    setState(() {
      _generateSplitOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = _currentOrder;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Soundbox announcement bar
              SoundboxSpeakerWidget(
                announcementText: _soundboxAnnouncement,
                isPlaying: order?.isFullyPaid ?? false,
              ),

              const SizedBox(height: 14),

              // CRED NeoPOP Input Amount & Config Card
              _buildInputCard(),

              const SizedBox(height: 14),

              if (order != null) ...[
                // CRED NeoPOP MDR Savings Summary Banner
                _buildSavingsBanner(order),

                const SizedBox(height: 14),

                // Order Progress Indicator
                _buildProgressCard(order),

                const SizedBox(height: 16),

                // Section Title & Batch Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE TRANCHES (${order.tranches.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (!order.isFullyPaid)
                      NeoPopButton(
                        color: AppColors.surfaceElevated,
                        bottomShadowColor: Colors.black,
                        rightShadowColor: Colors.black,
                        depth: 2.0,
                        border: Border.all(color: AppColors.primaryGreen, width: 1.2),
                        onTapUp: _simulatePayAll,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flash_on_rounded, size: 13, color: AppColors.primaryGreen),
                              SizedBox(width: 4),
                              Text(
                                'Settle All (Demo)',
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      NeoPopButton(
                        color: AppColors.surfaceElevated,
                        bottomShadowColor: Colors.black,
                        rightShadowColor: Colors.black,
                        depth: 2.0,
                        border: Border.all(color: AppColors.neonCyan, width: 1.2),
                        onTapUp: _resetOrder,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh_rounded, size: 13, color: AppColors.neonCyan),
                              SizedBox(width: 4),
                              Text(
                                'Reset',
                                style: TextStyle(
                                  color: AppColors.neonCyan,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // List of Tranche QR Cards
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.tranches.length,
                  itemBuilder: (context, index) {
                    final tranche = order.tranches[index];
                    final isCurrentActive = !tranche.isPaid &&
                        (index == 0 || order.tranches[index - 1].isPaid);

                    return QrTrancheCard(
                      tranche: tranche,
                      totalTranches: order.tranches.length,
                      isCurrentActive: isCurrentActive,
                      onSimulatePayment: () => _simulatePayTranche(tranche),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Viral Clout Receipt Button
                if (order.isFullyPaid)
                  NeoPopActionButton(
                    text: 'CLAIM & POST ZERO-MDR RECEIPT 🔥',
                    color: AppColors.primaryGreen,
                    textColor: Colors.black,
                    prefixIcon: const Icon(Icons.verified_rounded, color: Colors.black, size: 18),
                    onTap: () => CloutShareModal.show(context, order),
                  ),

                const SizedBox(height: 40),
              ],
            ],
          ),
        ),

        // Confetti overlay on completion
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            AppColors.primaryGreen,
            AppColors.neonCyan,
            AppColors.goldenYellow,
            Colors.white,
          ],
        ),
      ],
    );
  }

  Widget _buildInputCard() {
    return NeoPopSurfaceCard(
      backgroundColor: const Color(0xFF101012),
      borderColor: AppColors.neoBorder,
      depth: 4.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payee Status Banner
          InkWell(
            onTap: scanMerchantQr,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
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
                    size: 18,
                    color: _vpaController.text.isNotEmpty
                        ? AppColors.primaryGreen
                        : AppColors.neonCyan,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text
                              : (_vpaController.text.isNotEmpty
                                  ? _vpaController.text
                                  : 'No Merchant QR Scanned'),
                          style: TextStyle(
                            fontSize: 13,
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
                              : 'Tap to Scan QR Code or set Payee VPA',
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
            'BILL AMOUNT (INR)',
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
                  fontSize: 32,
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
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -1.0,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: AppColors.textMuted),
                  ),
                  onSubmitted: (_) => _generateSplitOrder(),
                ),
              ),
              NeoPopButton(
                color: AppColors.primaryGreen,
                bottomShadowColor: Colors.black,
                rightShadowColor: Colors.black,
                depth: 3.0,
                border: Border.all(color: Colors.black, width: 1.5),
                onTapUp: _generateSplitOrder,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Text(
                    'SPLIT ⚡',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quick Amount Pills (CRED NeoPOP Style)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickAmounts.map((amt) {
                final isSelected = _amountController.text == amt.toStringAsFixed(0);
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
                      _amountController.text = amt.toStringAsFixed(0);
                      _generateSplitOrder();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        '₹${amt.toStringAsFixed(0)}',
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
        ],
      ),
    );
  }

  Widget _buildSavingsBanner(SplitOrder order) {
    return NeoPopSurfaceCard(
      backgroundColor: const Color(0xFF00FFA3),
      borderColor: Colors.black,
      shadowColor: const Color(0xFF00E599),
      depth: 4.0,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MDR ARBITRAGE SAVED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₹${order.mdrSavings.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -1.0,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Govt 0.4% Fee',
                  style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w700),
                ),
                Text(
                  '₹${order.mdrStandard.toStringAsFixed(2)} ❌',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.alertRed,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(SplitOrder order) {
    return NeoPopSurfaceCard(
      backgroundColor: const Color(0xFF101012),
      borderColor: AppColors.neoBorder,
      depth: 3.0,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SETTLED: ₹${order.paidAmount.toStringAsFixed(0)} / ₹${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppColors.textPrimary,
                ),
              ),
              NeoPopPillBadge(
                label: '${(order.progress * 100).toInt()}%',
                color: order.isFullyPaid ? AppColors.primaryGreen : AppColors.neonCyan,
                textColor: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E22),
              border: Border.all(color: AppColors.neoBorder, width: 1.0),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: order.progress.clamp(0.0, 1.0),
              child: Container(
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
