import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'neopop_components.dart';

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
    final hasAnnouncement = widget.announcementText != null && widget.announcementText!.isNotEmpty;

    return NeoPopSurfaceCard(
      backgroundColor: hasAnnouncement ? const Color(0xFF0F1E15) : const Color(0xFF101012),
      borderColor: hasAnnouncement ? AppColors.primaryGreen : AppColors.neoBorder,
      depth: 3.0,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Animated Speaker Icon (CRED NeoPOP Square Box)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasAnnouncement ? AppColors.primaryGreen : const Color(0xFF1E1E22),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Transform.scale(
                  scale: hasAnnouncement ? (1.0 + _animController.value * 0.15) : 1.0,
                  child: Icon(
                    hasAnnouncement ? Icons.volume_up_rounded : Icons.speaker_rounded,
                    color: hasAnnouncement ? Colors.black : AppColors.textSecondary,
                    size: 18,
                  ),
                );
              },
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
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: hasAnnouncement ? AppColors.primaryGreen : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (hasAnnouncement)
                      const NeoPopPillBadge(
                        label: 'LIVE',
                        color: AppColors.primaryGreen,
                        textColor: Colors.black,
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  hasAnnouncement
                      ? widget.announcementText!
                      : 'Audio confirmation will broadcast here upon tranche clearance.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: hasAnnouncement ? AppColors.textPrimary : AppColors.textSecondary,
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
                    _buildBar(14 * _animController.value + 6),
                    const SizedBox(width: 3),
                    _buildBar(18 * (1.0 - _animController.value) + 6),
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
      width: 3,
      height: height.clamp(4.0, 24.0),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
