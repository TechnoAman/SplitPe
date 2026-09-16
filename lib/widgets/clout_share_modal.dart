import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/split_order.dart';
import '../theme/app_theme.dart';

class CloutShareModal extends StatelessWidget {
  final SplitOrder order;

  const CloutShareModal({super.key, required this.order});

  static void show(BuildContext context, SplitOrder order) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(200),
      builder: (ctx) => CloutShareModal(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tweetText = Uri.encodeComponent(
      '🔥 Just settled a ₹${order.totalAmount.toStringAsFixed(0)} bill with ₹0 MDR using @SplitPe!\n\n'
      '⚡ Split into ${order.tranches.length} sub-₹2,000 tranches.\n'
      '💰 Net MDR Surcharge Paid: ₹0.00 (Saved ₹${order.mdrSavings.toStringAsFixed(2)})\n\n'
      '100% Compliant #UPI #Fintech #SplitPe #ZeroMDR',
    );

    final twitterUrl = 'https://twitter.com/intent/tweet?text=$tweetText';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF141417),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF27272A), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(160),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B2E24),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: AppColors.primaryGreen, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Zero-MDR Receipt',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Receipt Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E2E34)),
              ),
              child: Column(
                children: [
                  // Merchant & VPA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.merchantName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              order.merchantVpa,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2E24),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '100% Settled',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFF28282E), height: 1),
                  const SizedBox(height: 14),

                  // Amount Settled
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Settled',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '₹${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // MDR Saved Highlight
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16251C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryGreen.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt, color: AppColors.primaryGreen, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'MDR Surcharge Saved',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                        Text(
                          '+₹${order.mdrSavings.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${order.tranches.length} sub-₹2,000 tranches',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const Text(
                        '0% MDR Certified',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Share Buttons (Responsive, no overflow)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        launchUrl(Uri.parse(twitterUrl), mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(Icons.send_rounded, size: 14, color: Colors.black),
                      label: const Text(
                        'Post on X',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final msg = '⚡ Just settled a ₹${order.totalAmount.toStringAsFixed(0)} bill with ₹0 MDR using SplitPe!\n'
                            'Saved ₹${order.mdrSavings.toStringAsFixed(2)} in gateway fees.\n'
                            'Check out SplitPe!';
                        SharePlus.instance.share(ShareParams(text: msg));
                      },
                      icon: const Icon(Icons.share_rounded, size: 14, color: Colors.black),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
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
