import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import '../theme/app_theme.dart';
import '../widgets/neopop_components.dart';
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
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryGreen,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Text(
                'SPLIT',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.5,
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
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const NeoPopPillBadge(
              label: '0% MDR',
              color: Color(0xFF1E1E22),
              textColor: AppColors.primaryGreen,
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
          color: Color(0xFF0D0D0D),
          border: Border(
            top: BorderSide(color: AppColors.neoBorder, width: 1.5),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  label: 'POS Split',
                  icon: Icons.point_of_sale_rounded,
                  activeColor: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                _buildNavItem(
                  index: 1,
                  label: 'Group Split',
                  icon: Icons.groups_rounded,
                  activeColor: AppColors.neonCyan,
                ),
                const SizedBox(width: 8),
                _buildNavItem(
                  index: 2,
                  label: 'MDR Roast',
                  icon: Icons.calculate_rounded,
                  activeColor: AppColors.goldenYellow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: NeoPopButton(
        color: isSelected ? activeColor : const Color(0xFF141416),
        bottomShadowColor: Colors.black,
        rightShadowColor: Colors.black,
        depth: isSelected ? 3.0 : 1.0,
        border: Border.all(
          color: isSelected ? Colors.black : AppColors.cardBorder,
          width: 1.2,
        ),
        onTapUp: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.black : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.black : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutMdrDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: NeoPopSurfaceCard(
          backgroundColor: const Color(0xFF101012),
          borderColor: AppColors.primaryGreen,
          depth: 5.0,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.gavel_rounded, color: AppColors.primaryGreen),
                  SizedBox(width: 8),
                  Text(
                    'THE MDR ARBITRAGE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'WHY DOES SPLITPE EXIST?',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.0,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'NPCI / Govt charges 0.4% MDR on UPI transactions exceeding ₹2,000.\n\n'
                'Transactions under ₹2,000 remain 100% FREE.\n\n'
                'SplitPe automatically breaks large bills into sub-₹2,000 tranches so you keep 100% of your money legally.',
                style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              NeoPopActionButton(
                text: 'GOT IT, LET\'S SAVE 🚀',
                color: AppColors.primaryGreen,
                textColor: Colors.black,
                depth: 3.0,
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
