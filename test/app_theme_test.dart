import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitpe/theme/app_theme.dart';

void main() {
  testWidgets('AppColors.card matches cardBg in dark theme', (tester) async {
    late Color card;
    late Color cardBg;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Builder(
          builder: (context) {
            card = AppColors.card(context);
            cardBg = AppColors.cardBg(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(card, cardBg);
  });

  testWidgets('AppColors.card matches cardBg in light theme', (tester) async {
    late Color card;
    late Color cardBg;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: Builder(
          builder: (context) {
            card = AppColors.card(context);
            cardBg = AppColors.cardBg(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(card, cardBg);
  });
}
