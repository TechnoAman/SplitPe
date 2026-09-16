import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplitPeLogo extends StatelessWidget {
  final double size;
  final bool showBadge;
  final bool isCompact;

  const SplitPeLogo({
    super.key,
    this.size = 28,
    this.showBadge = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 3D NeoPOP High-Res Visual Logo Emblem
        Container(
          width: size + 6,
          height: size + 6,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primaryGreen, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x660084FF),
                offset: Offset(2.0, 2.0),
                blurRadius: 0,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  '₹',
                  style: TextStyle(
                    fontSize: size * 0.65,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlue,
                  ),
                ),
              );
            },
          ),
        ),

        if (!isCompact) ...[
          const SizedBox(width: 10),
          // Logotype
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SPLIT',
                style: TextStyle(
                  color: AppColors.text(context),
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.68,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'PE',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.68,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (showBadge) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.chipBg(context),
                border: Border.all(color: AppColors.primaryBlue, width: 1.0),
              ),
              child: const Text(
                '0% MDR',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
