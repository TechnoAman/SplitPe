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
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasAnnouncement = widget.announcementText != null && widget.announcementText!.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: hasAnnouncement
            ? AppColors.primaryGreen.withAlpha(25)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAnnouncement ? AppColors.primaryGreen : AppColors.cardBorder,
          width: hasAnnouncement ? 1.5 : 1,
        ),
        boxShadow: hasAnnouncement
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withAlpha(50),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          // Animated Speaker Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasAnnouncement ? AppColors.primaryGreen : AppColors.surfaceElevated,
            ),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Transform.scale(
                  scale: hasAnnouncement ? 1.0 + (_animController.value * 0.2) : 1.0,
                  child: Icon(
                    hasAnnouncement ? Icons.volume_up_rounded : Icons.speaker_phone_rounded,
                    color: hasAnnouncement ? Colors.black : AppColors.textSecondary,
                    size: 20,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Announcement Text / Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'SPLITPE SOUNDBOX',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: hasAnnouncement
                            ? AppColors.primaryGreen
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasAnnouncement ? AppColors.primaryGreen : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  hasAnnouncement
                      ? widget.announcementText!
                      : 'Audio confirmation active • Zero-MDR certified',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: hasAnnouncement ? FontWeight.w700 : FontWeight.w500,
                    color: hasAnnouncement ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
