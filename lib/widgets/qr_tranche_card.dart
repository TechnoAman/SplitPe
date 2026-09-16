import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/tranche.dart';
import '../services/upi_service.dart';
import '../theme/app_theme.dart';

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColors.surface.withAlpha(160)
            : isCurrentActive
                ? AppColors.surfaceElevated
                : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPaid
              ? AppColors.primaryGreen.withAlpha(100)
              : isCurrentActive
                  ? AppColors.primaryGreen
                  : AppColors.cardBorder,
          width: isCurrentActive ? 2 : 1,
        ),
        boxShadow: isCurrentActive
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withAlpha(40),
                  blurRadius: 16,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tranche count & Status pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.primaryGreen.withAlpha(30)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPaid ? AppColors.primaryGreen : AppColors.cardBorder,
                      ),
                    ),
                    child: Text(
                      'TRANCHE ${tranche.index}/$totalTranches',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isPaid ? AppColors.primaryGreen : AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  if (tranche.payerName != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      tranche.payerName!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.primaryGreen
                      : isCurrentActive
                          ? AppColors.neonCyan.withAlpha(30)
                          : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPaid
                          ? Icons.check_circle_rounded
                          : isCurrentActive
                              ? Icons.play_arrow_rounded
                              : Icons.hourglass_top_rounded,
                      size: 14,
                      color: isPaid ? Colors.black : (isCurrentActive ? AppColors.neonCyan : AppColors.textMuted),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPaid
                          ? 'PAID'
                          : isCurrentActive
                              ? 'ACTIVE'
                              : 'QUEUED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isPaid ? Colors.black : (isCurrentActive ? AppColors.neonCyan : AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Middle: Amount & QR / Action
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // QR Code Box (Tap to zoom / copy)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(60),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: tranche.upiUri,
                  version: QrVersions.auto,
                  size: 90,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                ),
              ),

              const SizedBox(width: 16),

              // Details & Action
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${tranche.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isPaid ? AppColors.primaryGreen : AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.primaryGreen,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Zero MDR (≤ ₹2,000)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen.withAlpha(220),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Actions Row
                    if (!isPaid) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // UPI Intent Button
                          InkWell(
                            onTap: () async {
                              final launched = await UpiService.launchUpiIntent(tranche.upiUri);
                              if (!launched && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('UPI URI copied to clipboard! (UPI app not detected on this device)'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                await UpiService.copyToClipboard(tranche.upiUri);
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.neonCyan.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.neonCyan.withAlpha(100)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.launch_rounded, size: 13, color: AppColors.neonCyan),
                                  SizedBox(width: 4),
                                  Text(
                                    'Open UPI App',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.neonCyan,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Fast Simulate Pay Button
                          InkWell(
                            onTap: onSimulatePayment,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primaryGreen.withAlpha(100)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded, size: 14, color: AppColors.primaryGreen),
                                  SizedBox(width: 3),
                                  Text(
                                    'Simulate Pay',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Icon(Icons.done_all_rounded, size: 16, color: AppColors.primaryGreen),
                          const SizedBox(width: 4),
                          Text(
                            'Settled via SplitPe Engine',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
