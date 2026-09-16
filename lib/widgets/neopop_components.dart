import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import '../theme/app_theme.dart';

/// CRED NeoPOP 3D Interactive Button
class NeoPopActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final Widget? prefixIcon;
  final double depth;
  final bool isFullWidth;

  const NeoPopActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color = AppColors.primaryGreen,
    this.textColor = Colors.black,
    this.prefixIcon,
    this.depth = 4.0,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return NeoPopButton(
      color: color,
      bottomShadowColor: color.withAlpha(120),
      rightShadowColor: color.withAlpha(120),
      depth: depth,
      onTapUp: onTap,
      border: Border.all(color: Colors.black, width: 1.5),
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 8)],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CRED NeoPOP 3D Elevated Card
class NeoPopSurfaceCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double depth;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const NeoPopSurfaceCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.depth = 4.0,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark(context);
    final bg = backgroundColor ?? AppColors.cardBg(context);
    final border = borderColor ?? AppColors.border(context);
    final shadow = shadowColor ??
        (isDark ? const Color(0xFF000000) : const Color(0xFFCBD5E1));

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 1.5),
        boxShadow: depth > 0
            ? [
                BoxShadow(
                  color: shadow,
                  offset: Offset(depth, depth),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: content);
    }
    return content;
  }
}

/// CRED NeoPOP Monospace Pill Badge
class NeoPopPillBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final Widget? icon;

  const NeoPopPillBadge({
    super.key,
    required this.label,
    this.color = AppColors.primaryGreen,
    this.textColor = Colors.black,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 4)],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
