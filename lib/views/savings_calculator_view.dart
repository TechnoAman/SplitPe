import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/neopop_components.dart';

class SavingsCalculatorView extends StatefulWidget {
  const SavingsCalculatorView({super.key});

  @override
  State<SavingsCalculatorView> createState() => _SavingsCalculatorViewState();
}

class _SavingsCalculatorViewState extends State<SavingsCalculatorView> {
  double _monthlyTurnover = 1500000; // 15 Lakhs
  double _avgBillSize = 4500;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  // MDR math: 0.4% on transactions > 2000
  double get _monthlyMdrLoss {
    if (_avgBillSize <= 2000) return 0.0;
    return _monthlyTurnover * 0.004;
  }

  double get _annualMdrLoss => _monthlyMdrLoss * 12;

  String get _roastCommentary {
    if (_annualMdrLoss >= 100000) {
      return '💸 You are losing ₹${_currencyFormat.format(_annualMdrLoss)}/yr! That is literally a brand new M3 MacBook Pro or a Bali trip funded for payment gateways.';
    } else if (_annualMdrLoss >= 30000) {
      return '☕ You are losing ₹${_currencyFormat.format(_annualMdrLoss)}/yr! That is 1,500 cups of premium filter coffee down the drain.';
    } else {
      return '🛡️ SplitPe shields every single rupee with compliant sub-₹2,000 tranche routing.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // CRED NeoPOP Viral Header
          NeoPopSurfaceCard(
            backgroundColor: const Color(0xFF1B112C),
            borderColor: AppColors.electricPurple,
            depth: 4.0,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    NeoPopPillBadge(
                      label: '0.4% MDR ROAST 🔥',
                      color: AppColors.alertRed,
                      textColor: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Arbitrage Engine',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'HOW MUCH DOES THE NEW MDR COST YOUR BUSINESS?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Sliders & Controls (CRED NeoPOP Card)
          NeoPopSurfaceCard(
            backgroundColor: const Color(0xFF101012),
            borderColor: AppColors.neoBorder,
            depth: 4.0,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly Turnover Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MONTHLY UPI TURNOVER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(_monthlyTurnover),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.goldenYellow,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.goldenYellow,
                    thumbColor: AppColors.goldenYellow,
                    inactiveTrackColor: const Color(0xFF27272A),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _monthlyTurnover,
                    min: 100000,
                    max: 10000000,
                    divisions: 99,
                    onChanged: (val) {
                      setState(() {
                        _monthlyTurnover = val;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Average Bill Size Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AVERAGE TICKET / BILL SIZE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(_avgBillSize),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.neonCyan,
                    thumbColor: AppColors.neonCyan,
                    inactiveTrackColor: const Color(0xFF27272A),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _avgBillSize,
                    min: 500,
                    max: 50000,
                    divisions: 99,
                    onChanged: (val) {
                      setState(() {
                        _avgBillSize = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Output Numbers: Annual MDR Loss vs SplitPe Savings
          Row(
            children: [
              // Loss Box
              Expanded(
                child: NeoPopSurfaceCard(
                  backgroundColor: const Color(0xFF251016),
                  borderColor: AppColors.alertRed,
                  depth: 3.0,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ANNUAL GATEWAY LOSS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.alertRed,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _currencyFormat.format(_annualMdrLoss),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.alertRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Paid to banks/aggregators',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // SplitPe 0% MDR Box
              Expanded(
                child: NeoPopSurfaceCard(
                  backgroundColor: const Color(0xFF0C2417),
                  borderColor: AppColors.primaryGreen,
                  depth: 3.0,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SPLITPE SAVINGS',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _currencyFormat.format(_annualMdrLoss),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '100% Retained via 0% MDR',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Roast Commentary Box
          NeoPopSurfaceCard(
            backgroundColor: const Color(0xFF141416),
            borderColor: AppColors.goldenYellow,
            depth: 3.0,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ROAST OF THE DAY 🎙️',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: AppColors.goldenYellow,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _roastCommentary,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Viral Clout Share Button
          NeoPopActionButton(
            text: 'TWEET THIS MDR ROAST ON X 🔥',
            color: Colors.white,
            textColor: Colors.black,
            prefixIcon: const Icon(Icons.send_rounded, color: Colors.black, size: 16),
            onTap: () {
              final tweet = '🚨 I calculated how much the new 0.4% UPI MDR is costing my business:\n\n'
                  '💸 Lost: ${_currencyFormat.format(_annualMdrLoss)}/year to payment gateways!\n'
                  '🛡️ Saved with @SplitPe via sub-₹2,000 smart tranche routing.\n\n'
                  '#Fintech #UPI #SplitPe #MDR';
              final url = Uri.parse('https://twitter.com/intent/tweet?text=${Uri.encodeComponent(tweet)}');
              launchUrl(url, mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
    );
  }
}
