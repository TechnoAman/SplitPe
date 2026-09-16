import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:neopop/neopop.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/split_order.dart';
import '../models/tranche.dart';
import '../services/upi_service.dart';
import '../theme/app_theme.dart';
import 'clout_share_modal.dart';
import 'neopop_components.dart';

class SplitCheckoutModal extends StatefulWidget {
  final SplitOrder order;
  final Function(SplitOrder)? onOrderUpdated;

  const SplitCheckoutModal({
    super.key,
    required this.order,
    this.onOrderUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required SplitOrder order,
    Function(SplitOrder)? onOrderUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SplitCheckoutModal(
        order: order,
        onOrderUpdated: onOrderUpdated,
      ),
    );
  }

  @override
  State<SplitCheckoutModal> createState() => _SplitCheckoutModalState();
}

class _SplitCheckoutModalState extends State<SplitCheckoutModal> {
  late ConfettiController _confettiController;
  int _activeStepIndex = 0;
  bool _showAllTranches = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    // Find the first unpaid tranche index
    final firstUnpaid = widget.order.tranches.indexWhere((t) => !t.isPaid);
    _activeStepIndex = firstUnpaid != -1 ? firstUnpaid : 0;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _markCurrentAsPaid() {
    final tranche = widget.order.tranches[_activeStepIndex];
    if (tranche.isPaid) return;

    setState(() {
      tranche.status = TrancheStatus.paid;
      tranche.paidAt = DateTime.now();
      tranche.txnRef =
          'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      if (widget.order.isFullyPaid) {
        _confettiController.play();
      } else {
        // Auto-advance to next unpaid step
        final nextUnpaid = widget.order.tranches.indexWhere((t) => !t.isPaid);
        if (nextUnpaid != -1) {
          _activeStepIndex = nextUnpaid;
        }
      }
    });

    widget.onOrderUpdated?.call(widget.order);
  }

  void _markAllAsPaid() {
    setState(() {
      for (var t in widget.order.tranches) {
        t.status = TrancheStatus.paid;
        t.paidAt = DateTime.now();
        t.txnRef =
            'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      }
      _confettiController.play();
    });

    widget.onOrderUpdated?.call(widget.order);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final remaining = order.totalAmount - order.paidAmount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFF0C0C0E),
        border: Border(
          top: BorderSide(color: AppColors.primaryGreen, width: 2.0),
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Modal Drag Handle & Close Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              border: Border.all(color: Colors.black, width: 1.2),
                            ),
                            child: const Text(
                              '0% MDR CHECKOUT',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Saved ₹${order.mdrSavings.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Color(0xFF1E1E22), height: 1),

                // Payee Info Header Strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  color: const Color(0xFF141416),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.merchantName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              order.merchantVpa,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'REMAINING',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                          ),
                          Text(
                            '₹${remaining.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: remaining > 0 ? AppColors.goldenYellow : AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Stepper Progress Bar
                if (!order.isFullyPaid)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStepperBar(order),
                  ),

                const SizedBox(height: 12),

                // Main Content Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (order.isFullyPaid)
                          _buildFullySettledView(order)
                        else
                          _buildFocusedTrancheView(order),

                        const SizedBox(height: 16),

                        // All Tranches Accordion
                        _buildAllTranchesAccordion(order),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confetti overlay on settlement
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
      ),
    );
  }

  Widget _buildStepperBar(SplitOrder order) {
    final tranches = order.tranches;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tranches.length, (index) {
          final tranche = tranches[index];
          final isActive = index == _activeStepIndex;
          final isPaid = tranche.isPaid;

          return InkWell(
            onTap: () {
              setState(() {
                _activeStepIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isPaid
                    ? const Color(0xFF0F1E15)
                    : isActive
                        ? AppColors.primaryGreen
                        : const Color(0xFF161618),
                border: Border.all(
                  color: isPaid
                      ? AppColors.primaryGreen
                      : isActive
                          ? Colors.black
                          : AppColors.cardBorder,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPaid
                        ? Icons.check_circle_rounded
                        : isActive
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                    size: 13,
                    color: isPaid
                        ? AppColors.primaryGreen
                        : isActive
                            ? Colors.black
                            : AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Step ${index + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isPaid
                          ? AppColors.primaryGreen
                          : isActive
                              ? Colors.black
                              : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFocusedTrancheView(SplitOrder order) {
    if (_activeStepIndex >= order.tranches.length) return const SizedBox.shrink();
    final tranche = order.tranches[_activeStepIndex];
    final isPaid = tranche.isPaid;

    return NeoPopSurfaceCard(
      backgroundColor: const Color(0xFF101012),
      borderColor: isPaid ? AppColors.primaryGreen : AppColors.neonCyan,
      shadowColor: isPaid ? AppColors.primaryGreen.withAlpha(120) : AppColors.neonCyan.withAlpha(120),
      depth: 4.0,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NeoPopPillBadge(
                label: 'PAYMENT ${_activeStepIndex + 1} OF ${order.tranches.length}',
                color: isPaid ? AppColors.primaryGreen : AppColors.neonCyan,
                textColor: Colors.black,
              ),
              NeoPopPillBadge(
                label: isPaid ? '✓ SETTLED' : 'READY TO PAY',
                color: isPaid ? AppColors.primaryGreen : AppColors.goldenYellow,
                textColor: Colors.black,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // High Resolution QR Frame
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Opacity(
              opacity: isPaid ? 0.35 : 1.0,
              child: QrImageView(
                data: tranche.upiUri,
                version: QrVersions.auto,
                size: 150.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            '₹${tranche.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: isPaid ? AppColors.primaryGreen : Colors.white,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '≤ ₹2,000 Cap · 0% Surcharge Compliant',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
          ),

          const SizedBox(height: 18),

          if (!isPaid) ...[
            NeoPopActionButton(
              text: 'PAY ₹${tranche.amount.toStringAsFixed(0)} VIA UPI APP 🚀',
              color: AppColors.primaryGreen,
              textColor: Colors.black,
              prefixIcon: const Icon(Icons.bolt, color: Colors.black, size: 18),
              onTap: () async {
                final launched = await UpiService.launchUpiIntent(tranche.upiUri);
                if (!launched) {
                  await UpiService.copyToClipboard(tranche.upiUri);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚡ Copied UPI Link to Clipboard!'),
                        backgroundColor: AppColors.surfaceElevated,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NeoPopButton(
                    color: const Color(0xFF1E1E22),
                    bottomShadowColor: Colors.black,
                    rightShadowColor: Colors.black,
                    depth: 2.0,
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    onTapUp: _markCurrentAsPaid,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            'Mark Paid (Demo)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeoPopButton(
                    color: const Color(0xFF1E1E22),
                    bottomShadowColor: Colors.black,
                    rightShadowColor: Colors.black,
                    depth: 2.0,
                    border: Border.all(color: AppColors.cardBorder, width: 1.2),
                    onTapUp: () {
                      if (_activeStepIndex < order.tranches.length - 1) {
                        setState(() {
                          _activeStepIndex++;
                        });
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Next Step →',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withAlpha(25),
                border: Border.all(color: AppColors.primaryGreen, width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'Tranche Settled · ₹0 MDR',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
            if (_activeStepIndex < order.tranches.length - 1) ...[
              const SizedBox(height: 10),
              NeoPopActionButton(
                text: 'PROCEED TO NEXT TRANCHE →',
                color: AppColors.neonCyan,
                textColor: Colors.black,
                onTap: () {
                  setState(() {
                    _activeStepIndex++;
                  });
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFullySettledView(SplitOrder order) {
    return NeoPopSurfaceCard(
      backgroundColor: const Color(0xFF0F1E15),
      borderColor: AppColors.primaryGreen,
      shadowColor: AppColors.primaryGreen.withAlpha(160),
      depth: 4.0,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.verified_rounded, color: AppColors.primaryGreen, size: 48),
          const SizedBox(height: 10),
          const Text(
            'BILL 100% SETTLED',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Total ₹${order.totalAmount.toStringAsFixed(0)} cleared across ${order.tranches.length} tranches with zero MDR.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          NeoPopActionButton(
            text: 'CLAIM ZERO-MDR RECEIPT 🔥',
            color: AppColors.primaryGreen,
            textColor: Colors.black,
            prefixIcon: const Icon(Icons.share, color: Colors.black, size: 16),
            onTap: () {
              Navigator.pop(context);
              CloutShareModal.show(context, order);
            },
          ),
          const SizedBox(height: 10),
          NeoPopActionButton(
            text: 'DONE / CLOSE',
            color: const Color(0xFF1E1E22),
            textColor: Colors.white,
            depth: 2.0,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTranchesAccordion(SplitOrder order) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        border: Border.all(color: AppColors.neoBorder, width: 1.2),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _showAllTranches = !_showAllTranches;
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        'ALL TRANCHES (${order.tranches.length})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showAllTranches ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                if (!order.isFullyPaid)
                  NeoPopButton(
                    color: AppColors.surfaceElevated,
                    bottomShadowColor: Colors.black,
                    rightShadowColor: Colors.black,
                    depth: 1.5,
                    border: Border.all(color: AppColors.cardBorder, width: 1.0),
                    onTapUp: _markAllAsPaid,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Settle All (Demo)',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_showAllTranches)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                children: order.tranches.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tranche = entry.value;
                  final isSelected = index == _activeStepIndex;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _activeStepIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1B1B1E)
                            : tranche.isPaid
                                ? const Color(0xFF0F1E15)
                                : const Color(0xFF101012),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : tranche.isPaid
                                  ? AppColors.primaryGreen.withAlpha(100)
                                  : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                tranche.isPaid ? Icons.check_circle : Icons.circle_outlined,
                                size: 14,
                                color: tranche.isPaid ? AppColors.primaryGreen : AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tranche #${tranche.index}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ],
                          ),
                          Text(
                            '₹${tranche.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: tranche.isPaid ? AppColors.primaryGreen : Colors.white,
                            ),
                          ),
                        ],
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
}
