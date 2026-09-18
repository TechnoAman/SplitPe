import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/tranche.dart';
import '../services/upi_service.dart';
import '../theme/app_theme.dart';
import 'neopop_components.dart';

class QrTrancheCard extends StatelessWidget {
  final Tranche tranche;
  final int totalTranches;
  final VoidCallback onSimulatePayment;
  final bool isCurrentActive;

  const QrTrancheCard({
    super.key,
    required this.tranche,
    required this.totalTranches,
    required this.onSimulatePayment,
    this.isCurrentActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = tranche.isPaid;
    final isDark = ThemeController.isDark(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isPaid
            ? (isDark ? const Color(0xFF0E1E38) : const Color(0xFFF0F7FF))
            : AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPaid
              ? AppColors.primaryBlue
              : isCurrentActive
                  ? AppColors.primaryBlueDark
                  : AppColors.border(context),
          width: isCurrentActive || isPaid ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isPaid
                ? AppColors.primaryBlue.withAlpha(120)
                : isCurrentActive
                    ? AppColors.primaryBlueDark.withAlpha(120)
                    : (isDark ? const Color(0xFF000000) : const Color(0xFFCBD5E1)),
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tranche count & Status pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  NeoPopPillBadge(
                    label: 'TRANCHE ${tranche.index}/$totalTranches',
                    color: isPaid
                        ? AppColors.primaryBlue
                        : isCurrentActive
                            ? AppColors.primaryBlueDark
                            : (isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0)),
                    textColor: isPaid || isCurrentActive ? Colors.white : AppColors.text(context),
                  ),
                  if (tranche.payerName != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      tranche.payerName!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text(context),
                      ),
                    ),
                  ],
                ],
              ),
              // Status Badge
              if (isPaid)
                const NeoPopPillBadge(
                  label: '✓ PAID',
                  color: AppColors.primaryBlue,
                  textColor: Colors.white,
                  icon: Icon(Icons.check, size: 10, color: Colors.white),
                )
              else if (isCurrentActive)
                const NeoPopPillBadge(
                  label: 'PAY NOW',
                  color: AppColors.goldenYellow,
                  textColor: Colors.black,
                )
              else
                NeoPopPillBadge(
                  label: 'PENDING',
                  color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0),
                  textColor: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Main Body: QR Code & Amount Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // High-contrast NeoPOP QR Frame
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF000000),
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Opacity(
                  opacity: isPaid ? 0.3 : 1.0,
                  child: QrImageView(
                    data: tranche.upiUri,
                    version: QrVersions.auto,
                    size: 96.0,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Tranche Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AMOUNT DUE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: AppColors.textSub(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${tranche.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isPaid ? AppColors.primaryBlue : AppColors.text(context),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Zero MDR Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(20),
                        border: Border.all(color: AppColors.primaryBlue.withAlpha(80)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 12, color: AppColors.primaryBlue),
                          SizedBox(width: 3),
                          Text(
                            '0% MDR Arbitrage',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (tranche.suggestedDelaySeconds > 0 && !isPaid) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 11, color: AppColors.textSub(context)),
                          const SizedBox(width: 4),
                          Text(
                            'Pacing: ~${tranche.suggestedDelaySeconds}s delay',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSub(context),
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (isPaid && tranche.txnRef != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Ref: ${tranche.txnRef}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons
          if (!isPaid) ...[
            Row(
              children: [
                // 1. CRED NeoPop Intent Trigger
                Expanded(
                  flex: 3,
                  child: NeoPopButton(
                    color: isCurrentActive ? AppColors.primaryGreen : AppColors.neonCyan,
                    bottomShadowColor: const Color(0xFF000000),
                    rightShadowColor: const Color(0xFF000000),
                    depth: 3.0,
                    border: Border.all(color: Colors.black, width: 1.5),
                    onTapUp: () async {
                      final launched = await UpiService.launchUpiIntent(
                        tranche.upiUri,
                        amount: tranche.amount,
                        trancheIndex: tranche.index,
                      );
                      if (!launched) {
                        await UpiService.copyToClipboard(tranche.upiUri);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚡ Copied UPI Payment Link to Clipboard!'),
                              backgroundColor: AppColors.surfaceElevated,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.rocket_launch_rounded, color: Colors.black, size: 14),
                          const SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Pay #${tranche.index}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 2. Simulate Pay Demo Button
                Expanded(
                  flex: 2,
                  child: NeoPopButton(
                    color: const Color(0xFF27272A),
                    bottomShadowColor: const Color(0xFF000000),
                    rightShadowColor: const Color(0xFF000000),
                    depth: 3.0,
                    border: Border.all(color: AppColors.cardBorder, width: 1.5),
                    onTapUp: onSimulatePayment,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: AppColors.textSecondary, size: 14),
                          SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Simulate',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withAlpha(25),
                border: Border.all(color: AppColors.primaryGreen.withAlpha(100)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 14, color: AppColors.primaryGreen),
                  SizedBox(width: 6),
                  Text(
                    'Tranche Cleared · ₹0 MDR Incurred',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
