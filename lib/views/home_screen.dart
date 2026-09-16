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
    final isDark = ThemeController.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        title: const SplitPeLogo(size: 24),
        actions: [
          IconButton(
            onPressed: _handleTopBarScan,
            icon: Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.text(context),
              size: 22,
            ),
            tooltip: 'Scan Merchant QR',
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final dark = mode == ThemeMode.dark;
              return IconButton(
                onPressed: ThemeController.toggleTheme,
                icon: Icon(
                  dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: dark ? AppColors.goldenYellow : AppColors.primaryBlueDark,
                  size: 22,
                ),
                tooltip: dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              );
            },
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
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F0F12) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF202024) : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: isDark ? AppColors.blueSurface : const Color(0xFFE8F0FE),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.point_of_sale_outlined,
                color: AppColors.textSub(context),
              ),
              selectedIcon: const Icon(
                Icons.point_of_sale_rounded,
                color: AppColors.primaryBlue,
              ),
              label: 'POS Split',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.group_outlined,
                color: AppColors.textSub(context),
              ),
              selectedIcon: const Icon(
                Icons.group_rounded,
                color: AppColors.primaryBlue,
              ),
              label: 'Group Split',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.calculate_outlined,
                color: AppColors.textSub(context),
              ),
              selectedIcon: const Icon(
                Icons.calculate_rounded,
                color: AppColors.primaryBlue,
              ),
              label: 'MDR Roast',
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutMdrDialog(BuildContext context) {
    final isDark = ThemeController.isDark(context);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.cardBg(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withAlpha(150) : Colors.black.withAlpha(25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_rounded, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'The 0% MDR Arbitrage',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.text(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '• NPCI guidelines mandate interchange fees on merchant transactions exceeding ₹2,000.\n'
                '• Transactions of ₹2,000 or under remain 0% MDR compliant.\n'
                '• SplitPe demonstrates algorithmic bill tranching to simulate surcharge-free transactions.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textSub(context),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1A14) : const Color(0xFFFEF3C7),
                  border: Border.all(
                    color: isDark ? const Color(0xFF5A4418) : const Color(0xFFF59E0B),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚖️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'DISCLAIMER: This application is designed strictly for educational, academic demonstration, and algorithmic simulation purposes.',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'I UNDERSTAND',
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
