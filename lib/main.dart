import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/user_profile_service.dart';
import 'theme/app_theme.dart';
import 'views/home_screen.dart';
import 'views/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await UserProfileService.instance.loadProfile();
  runApp(const SplitPeApp());
}

class SplitPeApp extends StatelessWidget {
  const SplitPeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, currentMode, _) {
        return ListenableBuilder(
          listenable: UserProfileService.instance,
          builder: (context, _) {
            final hasProfile = UserProfileService.instance.hasProfile;
            return MaterialApp(
              title: 'SplitPe · 0% MDR UPI Engine',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentMode,
              builder: (context, child) {
                return PhoneMockupWrapper(child: child ?? const SizedBox.shrink());
              },
              home: hasProfile ? const HomeScreen() : const OnboardingView(),
            );
          },
        );
      },
    );
  }
}

class PhoneMockupWrapper extends StatelessWidget {
  final Widget child;
  const PhoneMockupWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isDark = ThemeController.isDark(context);
    final isMobile = screenSize.width < 540;

    if (isMobile) {
      // True mobile phone viewport: 100% full screen & edge-to-edge
      return Container(
        color: AppColors.bg(context),
        child: child,
      );
    }

    // Wide screen / Desktop viewport: Showcase interactive smartphone chassis in a studio showcase
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF07080B) : const Color(0xFFE9EEF5),
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: isDark
              ? [
                  const Color(0xFF10131E),
                  const Color(0xFF07080B),
                ]
              : [
                  const Color(0xFFFFFFFF),
                  const Color(0xFFDCE4EE),
                ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Studio Showcase Top Pill
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF12141C) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF262938) : const Color(0xFFCBD5E1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 90 : 18),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x9900E676),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SPLITPE · MOBILE FINTECH ENGINE (0% MDR)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),

              // Phone Device Chassis
              Container(
                width: 412,
                height: 844,
                decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: BorderRadius.circular(46),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2B2E3D) : const Color(0xFF1E293B),
                    width: 7.0,
                  ),
                  boxShadow: [
                    // Deep ambient drop shadow
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 230 : 45),
                      blurRadius: 48,
                      offset: const Offset(0, 22),
                    ),
                    // High-tech electric blue aura
                    BoxShadow(
                      color: AppColors.primaryBlue.withAlpha(isDark ? 35 : 18),
                      blurRadius: 80,
                      spreadRadius: -8,
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // Main app content
                    Positioned.fill(
                      top: 36,
                      bottom: 16,
                      child: child,
                    ),

                    // Phone Status Bar with Dynamic Island
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 36,
                      child: Container(
                        color: AppColors.bg(context),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '9:41',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text(context),
                                letterSpacing: -0.2,
                              ),
                            ),
                            // Dynamic Island Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primaryBlue.withAlpha(isDark ? 80 : 40),
                                  width: 0.8,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt, color: AppColors.goldenYellow, size: 10.5),
                                  SizedBox(width: 4),
                                  Text(
                                    '0% MDR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.signal_cellular_alt_rounded, size: 12.5, color: AppColors.text(context)),
                                const SizedBox(width: 4),
                                Icon(Icons.wifi_rounded, size: 12.5, color: AppColors.text(context)),
                                const SizedBox(width: 4),
                                Icon(Icons.battery_full_rounded, size: 14.5, color: AppColors.text(context)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Phone Home Indicator Bar
                    Positioned(
                      bottom: 5,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 128,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white38 : Colors.black38,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
