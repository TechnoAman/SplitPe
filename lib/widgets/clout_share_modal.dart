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

    final isDark = ThemeController.isDark(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cardBg(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border(context), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withAlpha(160) : Colors.black.withAlpha(25),
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
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.blueSurface : const Color(0xFFE8F0FE),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBlue.withAlpha(120),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        size: 15,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Zero-MDR Receipt',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text(context),
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

            const SizedBox(height: 18),

            // Receipt Container with Banknote Watermark
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1E) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Stack(
                children: [
                  // Subtle Banknote Background Watermark
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: IgnorePointer(
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return RadialGradient(
                            center: Alignment.center,
                            radius: 0.8,
                            colors: [
                              Colors.white.withOpacity(isDark ? 0.16 : 0.18),
                              Colors.transparent,
                            ],
                            stops: const [0.4, 1.0],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: Image.asset(
                          'assets/images/gandhi_currency.png',
                          width: 130,
                          height: 130,
                          color: isDark ? Colors.white : AppColors.primaryBlue,
                          colorBlendMode: BlendMode.srcIn,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  // Receipt Body
                  Padding(
                    padding: const EdgeInsets.all(16),
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
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text(context),
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
                                color: isDark ? AppColors.blueSurface : const Color(0xFFE8F0FE),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '100% Settled',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        Divider(color: AppColors.border(context), height: 1),
                        const SizedBox(height: 14),

                        // Amount Settled
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Settled',
                              style: TextStyle(fontSize: 12, color: AppColors.textSub(context), fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '₹${order.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text(context)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // MDR Saved Highlight
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.blueSurface : const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryBlue.withAlpha(60)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.bolt, color: AppColors.primaryBlue, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Gandhis Retained (MDR Saved)',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                                  ),
                                ],
                              ),
                              Text(
                                '+₹${order.mdrSavings.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '0% MDR Tranching Engine',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            const Text(
                              '0% MDR Certified',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                      icon: Icon(Icons.send_rounded, size: 14, color: isDark ? Colors.black : Colors.white),
                      label: Text(
                        'Post on X',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.black : Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
                        foregroundColor: isDark ? Colors.black : Colors.white,
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
                      icon: const Icon(Icons.share_rounded, size: 14, color: Colors.white),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
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
