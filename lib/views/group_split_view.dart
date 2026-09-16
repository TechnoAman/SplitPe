import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/split_order.dart';
import '../models/tranche.dart';
import '../services/split_engine.dart';
import '../theme/app_theme.dart';
import '../widgets/qr_tranche_card.dart';

class GroupSplitView extends StatefulWidget {
  const GroupSplitView({super.key});

  @override
  State<GroupSplitView> createState() => _GroupSplitViewState();
}

class _GroupSplitViewState extends State<GroupSplitView> {
  final _amountController = TextEditingController(text: '6800');
  int _peopleCount = 4;
  final List<String> _friendNames = ['You', 'Rohit', 'Sneha', 'Vikram'];
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.group_rounded, color: AppColors.neonCyan, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'GROUP BILL SPLIT (ZERO MDR)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amount
                Row(
                  children: [
                    const Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.neonCyan,
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
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                        ),
                        onChanged: (_) => _recalculateGroup(),
                      ),
                    ),
                  ],
                ),

                const Divider(color: AppColors.cardBorder, height: 24),

                // People selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Number of Friends',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _peopleCount > 2
                              ? () {
                                  setState(() {
                                    _peopleCount--;
                                    _recalculateGroup();
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                          color: AppColors.textSecondary,
                        ),
                        Text(
                          '$_peopleCount',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        IconButton(
                          onPressed: _peopleCount < 8
                              ? () {
                                  setState(() {
                                    _peopleCount++;
                                    if (_friendNames.length < _peopleCount) {
                                      _friendNames.add('Friend #$_peopleCount');
                                    }
                                    _recalculateGroup();
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          color: AppColors.primaryGreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Share group link button
          ElevatedButton.icon(
            onPressed: _shareAllViaWhatsApp,
            icon: const Icon(Icons.send_rounded, color: Colors.black, size: 18),
            label: const Text('Share Split Link on WhatsApp 💬'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),

          const SizedBox(height: 20),

          // Individual Friend Tranches
          if (order != null) ...[
            Text(
              'INDIVIDUAL SHARES (${order.tranches.length})',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.tranches.length,
              itemBuilder: (context, index) {
                final tranche = order.tranches[index];
                return QrTrancheCard(
                  tranche: tranche,
                  totalTranches: order.tranches.length,
                  isCurrentActive: !tranche.isPaid,
                  onSimulatePayment: () {
                    setState(() {
                      tranche.status = TrancheStatus.paid;
                    });
                  },
                );
              },
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
