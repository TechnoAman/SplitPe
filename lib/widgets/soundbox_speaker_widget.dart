import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SoundboxSpeakerWidget extends StatefulWidget {
  final String? announcementText;
  final bool isPlaying;

  const SoundboxSpeakerWidget({
    super.key,
    this.announcementText,
    this.isPlaying = false,
  });

  @override
  State<SoundboxSpeakerWidget> createState() => _SoundboxSpeakerWidgetState();
}

class _SoundboxSpeakerWidgetState extends State<SoundboxSpeakerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasAnnouncement =
        widget.announcementText != null && widget.announcementText!.isNotEmpty;
    final isDark = ThemeController.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141417) : AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAnnouncement
              ? AppColors.primaryBlue.withAlpha(120)
              : AppColors.border(context),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(80)
                : Colors.black.withAlpha(15),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Speaker Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasAnnouncement
                  ? (isDark
                      ? AppColors.blueSurface
                      : const Color(0xFFE8F0FE))
                  : (isDark
                      ? const Color(0xFF1E1E24)
                      : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasAnnouncement
                  ? Icons.volume_up_rounded
                  : Icons.speaker_outlined,
              color: hasAnnouncement
                  ? AppColors.primaryBlue
                  : AppColors.textSub(context),
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // Voice / Announcement Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'DIGITAL SOUNDBOX',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (hasAnnouncement)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hasAnnouncement
                      ? widget.announcementText!
                      : 'Audio confirmation will broadcast here upon tranche clearance.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: hasAnnouncement
                        ? AppColors.text(context)
                        : AppColors.textSub(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Equalizer Bars animation when playing
          if (hasAnnouncement)
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Row(
                  children: [
                    _buildBar(14 * _animController.value + 4),
                    const SizedBox(width: 3),
                    _buildBar(18 * (1.0 - _animController.value) + 4),
                    const SizedBox(width: 3),
                    _buildBar(16 * _animController.value + 4),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 2.5,
      height: height.clamp(4.0, 20.0),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
