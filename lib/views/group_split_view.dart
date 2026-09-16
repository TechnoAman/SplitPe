import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import 'package:share_plus/share_plus.dart';
import '../models/split_order.dart';
import '../models/tranche.dart';
import '../services/split_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/neopop_components.dart';
import '../widgets/qr_tranche_card.dart';

class GroupSplitView extends StatefulWidget {
  const GroupSplitView({super.key});

  @override
  State<GroupSplitView> createState() => _GroupSplitViewState();
}

class _GroupSplitViewState extends State<GroupSplitView> {
  final _amountController = TextEditingController(text: '6800');
  int _peopleCount = 4;
  final List<String> _friendNames = ['You', 'Rohit', 'Sneha', 'Vikram', 'Pooja', 'Ananya', 'Aarav'];
  SplitOrder? _groupOrder;

  @override
  void initState() {
    super.initState();
    _recalculateGroup();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _recalculateGroup() {
    final amt = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amt <= 0) return;

    setState(() {
      _groupOrder = SplitEngine.createGroupSplitOrder(
        totalAmount: amt,
        numberOfPeople: _peopleCount,
        merchantVpa: 'restaurant@okhdfcbank',
        merchantName: 'Social Bistro',
        friendNames: _friendNames.take(_peopleCount).toList(),
      );
    });
  }

  void _shareAllViaWhatsApp() {
    if (_groupOrder == null) return;
    final perPerson = (_groupOrder!.totalAmount / _peopleCount).toStringAsFixed(2);
    final msg = '🍻 Dinner Bill Split on SplitPe (0% MDR)!\n'
        'Total: ₹${_groupOrder!.totalAmount.toStringAsFixed(0)} | Friends: $_peopleCount\n'
        'Share per person: ₹$perPerson\n\n'
        'Pay your share directly via UPI without any surcharge!';
    SharePlus.instance.share(ShareParams(text: msg));
  }

  @override
  Widget build(BuildContext context) {
    final order = _groupOrder;
    final isDark = ThemeController.isDark(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          NeoPopSurfaceCard(
            backgroundColor: AppColors.cardBg(context),
            borderColor: AppColors.border(context),
            depth: 4.0,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.groups_rounded, color: AppColors.primaryBlue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'GROUP BILL SPLIT (ZERO MDR)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amount
                Row(
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text(context),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: isDark ? const Color(0xFF383B46) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        onSubmitted: (_) => _recalculateGroup(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // People Count Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NUMBER OF FRIENDS:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.textSub(context),
                      ),
                    ),
                    Row(
                      children: [
                        NeoPopButton(
                          color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFE2E8F0),
                          bottomShadowColor: isDark ? Colors.black : const Color(0xFFCBD5E1),
                          rightShadowColor: isDark ? Colors.black : const Color(0xFFCBD5E1),
                          depth: 2.0,
                          border: Border.all(color: AppColors.border(context), width: 1.2),
                          onTapUp: () {
                            if (_peopleCount > 2) {
                              setState(() {
                                _peopleCount--;
                                _recalculateGroup();
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.remove, size: 16, color: AppColors.text(context)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF18181B) : const Color(0xFFF1F5F9),
                            border: Border.all(color: AppColors.border(context), width: 1.2),
                          ),
                          child: Text(
                            '$_peopleCount',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        NeoPopButton(
                          color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFE2E8F0),
                          bottomShadowColor: isDark ? Colors.black : const Color(0xFFCBD5E1),
                          rightShadowColor: isDark ? Colors.black : const Color(0xFFCBD5E1),
                          depth: 2.0,
                          border: Border.all(color: AppColors.border(context), width: 1.2),
                          onTapUp: () {
                            if (_peopleCount < 8) {
                              setState(() {
                                _peopleCount++;
                                _recalculateGroup();
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.add, size: 16, color: AppColors.text(context)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Quick Share WhatsApp Button
          NeoPopActionButton(
            text: 'SHARE SPLIT LINKS ON WHATSAPP 📲',
            color: AppColors.primaryBlue,
            textColor: Colors.white,
            prefixIcon: const Icon(Icons.share_rounded, color: Colors.white, size: 16),
            onTap: _shareAllViaWhatsApp,
          ),

          const SizedBox(height: 16),

          if (order != null) ...[
            Text(
              'INDIVIDUAL SHARES (${order.tranches.length})',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: AppColors.textSub(context),
              ),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.tranches.length,
              itemBuilder: (context, index) {
                final tranche = order.tranches[index];
                return QrTrancheCard(
                  tranche: tranche,
                  totalTranches: order.tranches.length,
                  isCurrentActive: !tranche.isPaid && index == 0,
                  onSimulatePayment: () {
                    setState(() {
                      tranche.status = TrancheStatus.paid;
                      tranche.paidAt = DateTime.now();
                    });
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
