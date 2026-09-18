import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import '../theme/app_theme.dart';
import '../widgets/splitpe_logo.dart';
import 'group_split_view.dart';
import 'ledger_view.dart';
import 'pos_checkout_view.dart';
import 'profile_settings_view.dart';
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
      const LedgerView(),
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
        titleSpacing: 14,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SplitPeLogo(size: 22),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withAlpha(isDark ? 30 : 20),
                border: Border.all(
                  color: const Color(0xFF00E676).withAlpha(150),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🟢', style: TextStyle(fontSize: 6)),
                  SizedBox(width: 4),
                  Text(
                    '0% MDR',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: Color(0xFF00E676),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: NeoPopButton(
              color: isDark ? const Color(0xFF16171E) : const Color(0xFFEFF6FF),
              border: Border.all(
                color: AppColors.primaryBlue.withAlpha(150),
                width: 1.2,
              ),
              depth: 2,
              onTapUp: _handleTopBarScan,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppColors.primaryBlue,
                      size: 15,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'SCAN',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                  size: 20,
                ),
                tooltip: dark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileSettingsView()),
              );
            },
            icon: const Icon(
              Icons.account_circle_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            tooltip: 'User Profile Settings',
          ),
          IconButton(
            onPressed: () => _showAboutMdrDialog(context),
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            tooltip: 'MDR Rules & Guide',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1014) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF22242C) : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildNavTab(
                index: 0,
                label: 'POS SPLIT',
                icon: Icons.point_of_sale_rounded,
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildNavTab(
                index: 1,
                label: 'GROUP BILL',
                icon: Icons.groups_rounded,
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildNavTab(
                index: 2,
                label: 'MDR ROAST',
                icon: Icons.local_fire_department_rounded,
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              _buildNavTab(
                index: 3,
                label: 'LEDGER',
                icon: Icons.receipt_long_rounded,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab({
    required int index,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: NeoPopButton(
        color: isSelected
            ? AppColors.primaryBlue
            : (isDark ? const Color(0xFF16171D) : const Color(0xFFF1F5F9)),
        border: Border.all(
          color: isSelected
              ? Colors.black
              : (isDark ? const Color(0xFF282A36) : const Color(0xFFCBD5E1)),
          width: 1.2,
        ),
        depth: isSelected ? 2.5 : 0.0,
        onTapUp: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.textSecondary : const Color(0xFF64748B)),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
