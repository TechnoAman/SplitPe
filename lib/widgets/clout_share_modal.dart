import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/split_order.dart';
import '../theme/app_theme.dart';
import 'neopop_components.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0C),
        border: Border(
          top: BorderSide(color: AppColors.primaryGreen, width: 2.0),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF27272A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NeoPopPillBadge(
                  label: 'ZERO-MDR VERIFIED RECEIPT',
                  color: AppColors.primaryGreen,
                  textColor: Colors.black,
                  icon: Icon(Icons.verified_rounded, color: Colors.black, size: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // The CRED NeoPOP Receipt Card
            NeoPopSurfaceCard(
              backgroundColor: const Color(0xFF141416),
              borderColor: AppColors.primaryGreen,
              shadowColor: AppColors.primaryGreen.withAlpha(120),
              depth: 4.0,
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // Merchant & Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.merchantName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.8,
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
                      const NeoPopPillBadge(
                        label: '100% SETTLED',
                        color: Color(0xFF1E1E22),
                        textColor: AppColors.primaryGreen,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFF27272A), thickness: 1),
                  const SizedBox(height: 14),

                  // Big Amount Paid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL SETTLED',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // MDR Surcharge Avoided (Hero Metric)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withAlpha(20),
                      border: Border.all(color: AppColors.primaryGreen.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt, color: AppColors.primaryGreen, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'MDR Surcharge Avoided',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '+₹${order.mdrSavings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tranches list summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Split into ${order.tranches.length} sub-₹2,000 tranches',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const Text(
                        '0% MDR Certified',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.neonCyan),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Share CTA Buttons
            Row(
              children: [
                Expanded(
                  child: NeoPopActionButton(
                    text: 'POST ON X 🔥',
                    color: Colors.white,
                    textColor: Colors.black,
                    prefixIcon: const Icon(Icons.send_rounded, color: Colors.black, size: 14),
                    onTap: () {
                      launchUrl(Uri.parse(twitterUrl), mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NeoPopActionButton(
                    text: 'WHATSAPP 💬',
                    color: AppColors.primaryGreen,
                    textColor: Colors.black,
                    prefixIcon: const Icon(Icons.share_rounded, color: Colors.black, size: 14),
                    onTap: () {
                      final msg = '⚡ Just settled a ₹${order.totalAmount.toStringAsFixed(0)} bill with ₹0 MDR using SplitPe!\n'
                          'Saved ₹${order.mdrSavings.toStringAsFixed(2)} in gateway fees.\n'
                          'Check out SplitPe!';
                      SharePlus.instance.share(ShareParams(text: msg));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
