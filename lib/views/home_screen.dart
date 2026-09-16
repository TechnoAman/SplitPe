import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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
        _currentIndex = 0; // Switch to POS tab
      });
      _posKey.currentState?.applyScannedData(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SPLIT',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'PE',
              style: TextStyle(
                color: AppColors.neonCyan,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Text(
                '0% MDR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _handleTopBarScan,
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryGreen),
            tooltip: 'Scan Merchant QR',
          ),
          IconButton(
            onPressed: () => _showAboutMdrDialog(context),
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
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
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primaryGreen.withAlpha(50),
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.point_of_sale_rounded, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.point_of_sale_rounded, color: AppColors.primaryGreen),
              label: 'POS Split',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_rounded, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.groups_rounded, color: AppColors.neonCyan),
              label: 'Group Split',
            ),
            NavigationDestination(
              icon: Icon(Icons.calculate_rounded, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.calculate_rounded, color: AppColors.goldenYellow),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.gavel_rounded, color: AppColors.primaryGreen),
            SizedBox(width: 8),
            Text('The MDR Arbitrage', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why does SplitPe exist?',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 6),
            const Text(
              'NPCI/Govt announced a 0.4% MDR on UPI transactions exceeding ₹2,000.\n\n'
              'Transactions under ₹2,000 remain 100% FREE.\n\n'
              'SplitPe automatically breaks large bills into sub-₹2,000 tranches so you keep 100% of your earnings legally.',
              style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '💡 Tip: Use for restaurant tabs, retail electronics, group outings & travel bills.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it 🚀', style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
