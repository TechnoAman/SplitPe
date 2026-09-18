import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import 'package:share_plus/share_plus.dart';
import '../models/split_order.dart';
import '../models/tranche.dart';
import '../services/session_ledger_service.dart';
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
    SessionLedgerService.instance.registerOrder(_groupOrder!);
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
                        onChanged: (_) => _recalculateGroup(),
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
                      'SPLIT WITH FRIENDS:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.textSub(context),
                      ),
                    ),
                    Row(
                      children: [2, 3, 4, 5, 6].map((count) {
                        final isSel = _peopleCount == count;
                        return Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              setState(() {
                                _peopleCount = count;
                                _recalculateGroup();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? AppColors.primaryBlue
                                    : (isDark ? const Color(0xFF1B1D28) : const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSel
                                      ? AppColors.primaryBlue
                                      : (isDark ? const Color(0xFF2C3042) : const Color(0xFFCBD5E1)),
                                ),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: isSel ? Colors.white : AppColors.text(context),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Per-Person Summary Card
          if (order != null) ...[
            NeoPopSurfaceCard(
              backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFEFF6FF),
              borderColor: AppColors.primaryBlue,
              depth: 3.0,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EACH PERSON PAYS',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '₹${(order.totalAmount / _peopleCount).toStringAsFixed(0)} / person',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withAlpha(isDark ? 40 : 25),
                      border: Border.all(color: const Color(0xFF00E676), width: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '0% MDR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00E676),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Quick Share WhatsApp Button
          NeoPopActionButton(
            text: 'SHARE SPLIT LINKS ON WHATSAPP 📲',
            color: const Color(0xFF25D366),
            textColor: Colors.black,
            prefixIcon: const Icon(Icons.share_rounded, color: Colors.black, size: 16),
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
                      SessionLedgerService.instance.updateTrancheStatus(
                        trancheIndex: tranche.index,
                        billId: order.hashCode,
                        status: TrancheStatus.paid,
                        amount: tranche.amount,
                        receiverUpiId: order.merchantVpa,
                        note: 'Group Split: Tranche ${index + 1}/${order.tranches.length}',
                      );
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
