import 'package:flutter/material.dart';
import 'package:neopop/neopop.dart';
import '../models/user_profile.dart';
import '../services/user_profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/splitpe_logo.dart';

class OnboardingView extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingView({super.key, this.onComplete});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _upiController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final profile = UserProfile(
      name: _nameController.text.trim(),
      upiId: _upiController.text.trim(),
    );

    await UserProfileService.instance.saveProfile(profile);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeController.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and badge
                  Center(
                    child: Column(
                      children: [
                        const SplitPeLogo(size: 40),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withAlpha(isDark ? 30 : 20),
                            border: Border.all(
                              color: const Color(0xFF00E676).withAlpha(150),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🟢', style: TextStyle(fontSize: 8)),
                              SizedBox(width: 6),
                              Text(
                                '0% MDR UPI ENGINE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF00E676),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Header
                  Text(
                    'Welcome to SplitPe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set up your sender profile once to enable sub-₹2,000 MDR-free UPI payments and transaction tracking.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.textSub(context),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF262833) : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 50 : 8),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Label
                        Text(
                          'YOUR FULL NAME',
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
                            hintText: 'e.g. Vikram Sharma',
                            hintStyle: TextStyle(
                              color: AppColors.textSub(context).withAlpha(120),
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
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

                        // UPI ID Label
                        Text(
                          'YOUR SENDER UPI ID (VPA)',
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
                            hintText: 'e.g. 9876543210@paytm or name@oksbi',
                            hintStyle: TextStyle(
                              color: AppColors.textSub(context).withAlpha(120),
                              fontSize: 13,
                            ),
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
                              return 'UPI ID must contain "@" (e.g. username@upi)';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Privacy Note
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withAlpha(isDark ? 20 : 12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryBlue.withAlpha(isDark ? 60 : 40),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your profile is saved locally for convenience. In accordance with zero-trust privacy, transaction ledgers are strictly session-only and cleared on restart.',
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

                  // Submit Button
                  NeoPopButton(
                    color: AppColors.primaryBlue,
                    bottomShadowColor: const Color(0xFF000000),
                    rightShadowColor: const Color(0xFF000000),
                    depth: 3.0,
                    border: Border.all(color: Colors.black, width: 1.5),
                    onTapUp: _isSaving ? () {} : _submit,
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
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'CONTINUE TO SPLITPE',
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
      ),
    );
  }
}
