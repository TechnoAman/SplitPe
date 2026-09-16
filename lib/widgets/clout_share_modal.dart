import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/split_order.dart';
import '../services/upi_service.dart';
import '../theme/app_theme.dart';

class CloutShareModal extends StatelessWidget {
  final SplitOrder order;

  const CloutShareModal({super.key, required this.order});

  static void show(BuildContext context, SplitOrder order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => CloutShareModal(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tweetText = Uri.encodeComponent(
      '🔥 Just bypassed the new 0.4% UPI MDR on a ₹${order.totalAmount.toStringAsFixed(0)} bill using @SplitPe!\n\n'
      '⚡ Split into ${order.tranches.length} sub-₹2,000 tranches.\n'
      '💰 Net MDR Paid: ₹0.00 (Saved ₹${order.mdrSavings.toStringAsFixed(2)})\n\n'
      'Peak Indian Jugaad 🇮🇳🚀 #UPI #Fintech #SplitPe #ZeroMDR',
    );

    final twitterUrl = 'https://twitter.com/intent/tweet?text=$tweetText';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, color: Colors.black, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'ZERO-MDR RECEIPT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // The Luxe Receipt Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withAlpha(20),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Merchant & Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.merchantName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            order.merchantVpa,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '100% EXEMPT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(color: AppColors.cardBorder, height: 28),

                  // Numbers breakdown
                  _buildReceiptRow('Total Bill Amount', '₹${order.totalAmount.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildReceiptRow('Tranches Processed', '${order.tranches.length} sub-₹2,000 splits'),
                  const SizedBox(height: 8),
                  _buildReceiptRow('Standard 0.4% MDR', '₹${order.mdrStandard.toStringAsFixed(2)}', isCrossed: true),
                  const SizedBox(height: 8),
                  _buildReceiptRow('SplitPe MDR Charged', '₹0.00', isGreen: true),

                  const Divider(color: AppColors.cardBorder, height: 28),

                  // Highlighted Savings
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGreen.withAlpha(120)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL SAVED',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        Text(
                          '₹${order.mdrSavings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
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

            const SizedBox(height: 20),

            // Share Buttons
            Row(
              children: [
                // Post to X / Twitter
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(twitterUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.rocket_launch_rounded, size: 18, color: Colors.black),
                    label: const Text(
                      'Post on X / Twitter',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Native Share / WhatsApp
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final shareMsg = UpiService.generateViralShareText(
                        totalAmount: order.totalAmount,
                        mdrSaved: order.mdrSavings,
                        trancheCount: order.tranches.length,
                      );
                      await SharePlus.instance.share(ShareParams(text: shareMsg));
                    },
                    icon: const Icon(Icons.share_rounded, color: AppColors.textPrimary),
                    tooltip: 'Share Receipt',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String value, {bool isCrossed = false, bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            decoration: isCrossed ? TextDecoration.lineThrough : null,
            decorationColor: AppColors.alertRed,
            color: isGreen
                ? AppColors.primaryGreen
                : isCrossed
                    ? AppColors.alertRed
                    : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
