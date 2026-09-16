import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/splitpe_logo.dart';
import 'group_split_view.dart';
import 'pos_checkout_view.dart';
import 'savings_calculator_view.dart';
import 'qr_scanner_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<PosCheckoutViewState> _posKey = GlobalKey<PosCheckoutViewState>();

  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _views = [
      PosCheckoutView(key: _posKey),
      const GroupSplitView(),
      const SavingsCalculatorView(),
    ];
  }

  Future<void> _handleTopBarScan() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerView()),
    );

    if (result != null && mounted) {
      setState(() {
        _currentIndex = 0;
      });
      _posKey.currentState?.applyScannedData(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const SplitPeLogo(size: 24),
        actions: [
          IconButton(
            onPressed: _handleTopBarScan,
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 22),
            tooltip: 'Scan Merchant QR',
          ),
          IconButton(
            onPressed: () => _showAboutMdrDialog(context),
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 22),
            tooltip: 'MDR Rules & Guide',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F12),
          border: Border(
            top: BorderSide(color: Color(0xFF202024), width: 1.0),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: const Color(0xFF1F2923),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.point_of_sale_rounded, color: AppColors.primaryGreen),
              label: 'POS Split',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.group_rounded, color: AppColors.primaryGreen),
              label: 'Group Split',
            ),
            NavigationDestination(
              icon: Icon(Icons.calculate_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.calculate_rounded, color: AppColors.primaryGreen),
              label: 'MDR Roast',
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutMdrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF141417),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF27272A)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_rounded, color: AppColors.primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'The 0% MDR Arbitrage',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'NPCI charges 0.4% MDR on single UPI transactions exceeding ₹2,000.\n\n'
                'Transactions of ₹2,000 or less remain 100% FREE.\n\n'
                'SplitPe automatically splits your bill into compliant sub-₹2,000 tranches so you keep 100% of your earnings.',
                style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
