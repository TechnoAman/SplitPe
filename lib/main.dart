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
    final isMobile = screenSize.width < 520;

    if (isMobile) {
      // True mobile phone viewport: 100% full screen & edge-to-edge
      return Container(
        color: AppColors.bg(context),
        child: child,
      );
    }

    // Wide screen / Desktop viewport: Showcase interactive smartphone chassis
    return Container(
      color: isDark ? const Color(0xFF08090C) : const Color(0xFFE2E8F0),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mobile-first Badge
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF14151B) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2B2E3B) : const Color(0xFFCBD5E1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 80 : 15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SPLITPE · DESIGNED FOR PHONES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),

              // Phone Device Chassis
              Container(
                width: 412,
                height: 840,
                decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: BorderRadius.circular(44),
                  border: Border.all(
                    color: isDark ? const Color(0xFF262833) : const Color(0xFF0F172A),
                    width: 7.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 200 : 35),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: AppColors.primaryBlue.withAlpha(isDark ? 25 : 12),
                      blurRadius: 60,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // Main app content
                    Positioned.fill(
                      top: 34,
                      bottom: 14,
                      child: child,
                    ),

                    // Phone Status Bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 34,
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
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.text(context),
                                letterSpacing: 0.2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black : const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt, color: AppColors.goldenYellow, size: 10),
                                  SizedBox(width: 4),
                                  Text(
                                    '0% MDR',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.signal_cellular_alt, size: 12, color: AppColors.text(context)),
                                const SizedBox(width: 4),
                                Icon(Icons.wifi, size: 12, color: AppColors.text(context)),
                                const SizedBox(width: 4),
                                Icon(Icons.battery_full, size: 14, color: AppColors.text(context)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Phone Home Bar Indicator
                    Positioned(
                      bottom: 4,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 120,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white30 : Colors.black26,
                            borderRadius: BorderRadius.circular(2),
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
