import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/upi_service.dart';
import '../theme/app_theme.dart';

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
      return '💸 You are losing ₹${_currencyFormat.format(_annualMdrLoss)}/yr! That is literally a brand new MacBook Pro or a trip to Bali funded for payment gateways.';
    } else if (_annualMdrLoss >= 30000) {
      return '☕ You are losing ₹${_currencyFormat.format(_annualMdrLoss)}/yr! That is 1,500 cups of premium filter coffee down the drain.';
    } else {
      return '🛡️ SplitPe shields every single rupee with compliant sub-₹2,000 tranche routing.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Viral Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E1065), Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.electricPurple.withAlpha(120)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.alertRed.withAlpha(40),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.alertRed),
                      ),
                      child: const Text(
                        '0.4% MDR ROAST',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.alertRed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tax Arbitrage Engine',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'How Much Does The New MDR Cost Your Business?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sliders & Controls
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
                // Monthly Revenue
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Monthly UPI Turnover',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(_monthlyTurnover),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _monthlyTurnover,
                  min: 100000,
                  max: 10000000,
                  divisions: 99,
                  activeColor: AppColors.primaryGreen,
                  inactiveColor: AppColors.surfaceElevated,
                  onChanged: (val) {
                    setState(() {
                      _monthlyTurnover = val;
                    });
                  },
                ),

                const SizedBox(height: 8),

                // Average Bill Size
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Average Order Value (AOV)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      _currencyFormat.format(_avgBillSize),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _avgBillSize,
                  min: 500,
                  max: 25000,
                  divisions: 49,
                  activeColor: AppColors.neonCyan,
                  inactiveColor: AppColors.surfaceElevated,
                  onChanged: (val) {
                    setState(() {
                      _avgBillSize = val;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Savings Impact Grid
          Row(
            children: [
              // Monthly Loss
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.alertRed.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.alertRed.withAlpha(100)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MONTHLY TAX DRAIN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.alertRed,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _currencyFormat.format(_monthlyMdrLoss),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.alertRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Annual Savings with SplitPe
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryGreen.withAlpha(100)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SAVED / YR ON SPLITPE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
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
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Roast commentary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _roastCommentary,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tweet this calculation button
          ElevatedButton.icon(
            onPressed: () async {
              final tweetText = Uri.encodeComponent(
                'According to @SplitPe calculator, businesses doing ${_currencyFormat.format(_monthlyTurnover)}/mo are losing ${_currencyFormat.format(_annualMdrLoss)}/year to the new 0.4% UPI MDR! 🤯\n\n'
                'Bypassing it using sub-₹2,000 smart tranche splitting. 🚀\n#UPI #Fintech #SplitPe',
              );
              final url = 'https://twitter.com/intent/tweet?text=$tweetText';
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.share_rounded, color: Colors.black, size: 18),
            label: const Text('Tweet My Business Savings 🔥'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 24),

          // Developer SDK teaser
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DEVELOPER SDK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neonCyan,
                        letterSpacing: 1.0,
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        await UpiService.copyToClipboard('npm install @splitpe/sdk');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('SDK install command copied!')),
                          );
                        }
                      },
                      child: const Text(
                        'Copy 📋',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const SelectableText(
                  'npm install @splitpe/sdk\n\nconst split = await splitpe.createOrder({\n  amount: 8500,\n  maxTranche: 1999\n});',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
