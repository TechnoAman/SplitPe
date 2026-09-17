import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/split_order.dart';
import '../models/tranche.dart';
import '../services/upi_service.dart';
import '../theme/app_theme.dart';
import 'clout_share_modal.dart';
import 'splitpe_logo.dart';

class SplitCheckoutDialog extends StatefulWidget {
  final SplitOrder order;
  final Function(SplitOrder)? onOrderUpdated;

  const SplitCheckoutDialog({
    super.key,
    required this.order,
    this.onOrderUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required SplitOrder order,
    Function(SplitOrder)? onOrderUpdated,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(200),
      builder: (ctx) => SplitCheckoutDialog(
        order: order,
        onOrderUpdated: onOrderUpdated,
      ),
    );
  }

  @override
  State<SplitCheckoutDialog> createState() => _SplitCheckoutDialogState();
}

class _SplitCheckoutDialogState extends State<SplitCheckoutDialog> {
  late ConfettiController _confettiController;
  int _activeStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
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
        final nextUnpaid = widget.order.tranches.indexWhere((t) => !t.isPaid);
        if (nextUnpaid != -1) {
          _activeStepIndex = nextUnpaid;
        }
      }
    });

    widget.onOrderUpdated?.call(widget.order);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isDone = order.isFullyPaid;
    final totalSteps = order.tranches.length;
    final currentTranche = _activeStepIndex < totalSteps
        ? order.tranches[_activeStepIndex]
        : order.tranches.last;

    final isDark = ThemeController.isDark(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              color: AppColors.cardBg(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border(context), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withAlpha(160) : Colors.black.withAlpha(30),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Subtle Banknote Security Watermark in Dialog Background
                Positioned(
                  right: -10,
                  top: -10,
                  child: IgnorePointer(
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return RadialGradient(
                          center: Alignment.center,
                          radius: 0.8,
                          colors: [
                            Colors.white.withAlpha(isDark ? 41 : 46),
                            Colors.transparent,
                          ],
                          stops: const [0.4, 1.0],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.asset(
                        'assets/images/gandhi_currency.png',
                        width: 140,
                        height: 140,
                        color: isDark ? Colors.white : AppColors.primaryBlue,
                        colorBlendMode: BlendMode.srcIn,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Dialog Content
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header Row: Segment Bar & Close Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const SplitPeLogo(size: 16, showBadge: false),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.chipBg(context),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isDone ? 'COMPLETED' : 'TRANCHE ${_activeStepIndex + 1} OF $totalSteps',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSub(context),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close_rounded, color: AppColors.textSub(context), size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        if (!isDone) ...[
                          // 1. Sleek Segment Progress Line
                          Row(
                            children: List.generate(totalSteps, (index) {
                              final isPaid = order.tranches[index].isPaid;
                              final isCurrent = index == _activeStepIndex;

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _activeStepIndex = index;
                                    });
                                  },
                                  child: Container(
                                    height: 3.5,
                                    margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 5),
                                    decoration: BoxDecoration(
                                      color: isPaid
                                          ? AppColors.primaryBlue
                                          : isCurrent
                                              ? (isDark ? Colors.white : AppColors.primaryBlue)
                                              : (isDark ? const Color(0xFF2E2E34) : const Color(0xFFE2E8F0)),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 18),

                          // 2. Payee Name & VPA
                          Text(
                            order.merchantName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.merchantVpa,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 16),

                          // 3. Clean Centered QR Code
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(isDark ? 80 : 25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Opacity(
                              opacity: currentTranche.isPaid ? 0.3 : 1.0,
                              child: QrImageView(
                                data: currentTranche.upiUri,
                                version: QrVersions.auto,
                                size: 145.0,
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 4. Hero Amount
                          Text(
                            '₹${currentTranche.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text(context),
                              letterSpacing: -1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Total Bill: 0% MDR Qualified',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 5. Primary Action Button
                          if (!currentTranche.isPaid) ...[
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final launched = await UpiService.launchUpiIntent(currentTranche.upiUri);
                                  if (!launched) {
                                    await UpiService.copyToClipboard(currentTranche.upiUri);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('⚡ Copied UPI Link to Clipboard!'),
                                          backgroundColor: isDark ? const Color(0xFF1E1E22) : Colors.black87,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Pay ₹${currentTranche.amount.toStringAsFixed(0)} via UPI',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _markCurrentAsPaid,
                              child: Text(
                                'Mark as Paid (Demo)',
                                style: TextStyle(
                                  color: AppColors.textSub(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.blueSurface : const Color(0xFFE8F0FE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryBlue.withAlpha(80)),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tranche Paid',
                                    style: TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_activeStepIndex < totalSteps - 1) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _activeStepIndex++;
                                  });
                                },
                                child: const Text(
                                  'Next Tranche →',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ] else ...[
                          // Fully Settled View
                          const SizedBox(height: 12),
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? AppColors.blueSurface : const Color(0xFFE8F0FE),
                              border: Border.all(color: AppColors.primaryBlue, width: 2),
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              color: AppColors.primaryBlue,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Bill Fully Settled',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${order.totalAmount.toStringAsFixed(0)} settled across $totalSteps tranches with zero MDR fee.\nYou retained all your hard-earned Gandhis 💸',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSub(context),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                CloutShareModal.show(context, order);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Share Zero-MDR Receipt',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Done',
                              style: TextStyle(color: AppColors.textSub(context), fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confetti explosion
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
}
