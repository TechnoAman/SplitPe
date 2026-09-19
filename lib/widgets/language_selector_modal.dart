import 'package:flutter/material.dart';
import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Modal dialog allowing users to switch languages across 9 Indian languages.
class LanguageSelectorModal extends StatelessWidget {
  const LanguageSelectorModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const LanguageSelectorModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark(context);
    final activeLanguage = LocaleController.language;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.border(context),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(200) : Colors.black.withAlpha(30),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF333644) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.blueSurface : const Color(0xFFE8F0FE),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryBlue.withAlpha(120),
                      ),
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.selectLanguage,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: AppColors.text(context),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: AppColors.textSub(context), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Grid of Languages
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppLanguage.values.map((lang) {
              final isSelected = activeLanguage == lang;
              return InkWell(
                onTap: () {
                  LocaleController.setLanguage(lang);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: (MediaQuery.of(context).size.width - 56) / 2,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.blueSurface : const Color(0xFFEFF6FF))
                        : (isDark ? const Color(0xFF14151B) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.border(context),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(lang.flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.nativeName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.text(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              lang.englishName,
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textSub(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
