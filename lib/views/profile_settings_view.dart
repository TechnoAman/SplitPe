import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../theme/app_theme.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _upiController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = UserProfileService.instance.profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _upiController = TextEditingController(text: profile?.upiId ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final updated = UserProfile(
      name: _nameController.text.trim(),
      upiId: _upiController.text.trim(),
    );

    await UserProfileService.instance.saveProfile(updated);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Profile saved successfully!'),
            ],
          ),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.text(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.text(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF262833) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryBlue.withAlpha(isDark ? 50 : 25),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryBlue,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              UserProfileService.instance.profile?.name ?? 'Anonymous Payer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              UserProfileService.instance.profile?.upiId ?? 'No UPI ID configured',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSub(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Edit Fields Container
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.card(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF262833) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FULL NAME',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.textSub(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text(context),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Your name',
                          prefixIcon: Icon(
                            Icons.badge_outlined,
                            size: 18,
                            color: AppColors.textSub(context),
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF14151B) : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF2E303E) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF2E303E) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      Text(
                        'SENDER UPI ID (VPA)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppColors.textSub(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _upiController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text(context),
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 9876543210@paytm or name@okhdfcbank',
                          prefixIcon: Icon(
                            Icons.alternate_email_rounded,
                            size: 18,
                            color: AppColors.textSub(context),
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF14151B) : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF2E303E) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: isDark ? const Color(0xFF2E303E) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your UPI ID';
                          }
                          if (!val.trim().contains('@')) {
                            return 'UPI ID must contain "@"';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Persistence Note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withAlpha(isDark ? 20 : 12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryBlue.withAlpha(isDark ? 60 : 40),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your profile is the ONLY data that survives app restarts. All transaction ledgers remain strictly in-memory per session.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.35,
                            color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                NeoPopButton(
                  color: AppColors.primaryBlue,
                  bottomShadowColor: const Color(0xFF000000),
                  rightShadowColor: const Color(0xFF000000),
                  depth: 3.0,
                  border: Border.all(color: Colors.black, width: 1.5),
                  onTapUp: _isSaving ? () {} : _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'SAVE PROFILE',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
