import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_auth_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  static const Color _primaryGreen = Color.fromARGB(255, 26, 152, 9);
  static const Color _backgroundColor = Color(0xFFF6F9F6);
  static const Color _textColor = Color(0xFF1A1A1A);
  static const Color _subtitleColor = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(authProvider.notifier).resetForgotPasswordFlow();
      }
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _getPhase(AuthState state) {
    if (state.canResetPassword) return 3;
    if (state.hasRequestedForgotPasswordOtp) return 2;
    return 1;
  }

  Future<void> _handleSendOtp() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final success = await ref
          .read(authProvider.notifier)
          .sendForgotPasswordOtp(_identifierController.text.trim());
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully!'),
            backgroundColor: _primaryGreen,
          ),
        );
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      await ref
          .read(authProvider.notifier)
          .verifyForgotPasswordOtp(_otpController.text.trim());
    }
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.passwordsDoNotMatch ?? 'Passwords do not match',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      FocusScope.of(context).unfocus();
      final success = await ref
          .read(authProvider.notifier)
          .resetPassword(_newPasswordController.text);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.passwordResetSuccess ??
                  'Password reset successfully! Please login with your new password.',
            ),
            backgroundColor: _primaryGreen,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final phase = _getPhase(authState);
    final displayError = authState.error;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _textColor, size: 20),
          onPressed: () {
            ref.read(authProvider.notifier).resetForgotPasswordFlow();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset, color: _primaryGreen, size: 56.0),
                const SizedBox(height: 16.0),
                Text(
                  l10n.forgotPasswordTitle,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    phase == 1
                        ? l10n.forgotPasswordSubtitle
                        : phase == 2
                            ? 'Enter the verification code sent to ${authState.forgotPasswordIdentifier ?? ''}'
                            : 'Enter your new password below to complete password reset.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14.0, color: _subtitleColor),
                  ),
                ),
                const SizedBox(height: 32.0),

                // Card Container
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: Colors.black12, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      // PHASE 1: ENTER REGISTERED IDENTIFIER
                      if (phase == 1) ...[
                        AuthTextField(
                          controller: _identifierController,
                          hintText: 'Email or Mobile Number',
                          prefixIcon: Icons.badge_outlined,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.enterRegisteredIdentifier;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),
                      ],

                      // PHASE 2: ENTER OTP
                      if (phase == 2) ...[
                        AuthTextField(
                          controller: _otpController,
                          hintText: l10n.enterOtp,
                          prefixIcon: Icons.pin_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the OTP';
                            }
                            if (value.trim().length != 6) {
                              return 'OTP must be 6 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: authState.isForgotPasswordSendingOtp
                                ? null
                                : () async {
                                    final success = await ref
                                        .read(authProvider.notifier)
                                        .sendForgotPasswordOtp(
                                          _identifierController.text.trim(),
                                        );
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('OTP resent successfully!'),
                                          backgroundColor: _primaryGreen,
                                        ),
                                      );
                                    }
                                  },
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                color: _primaryGreen,
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],

                      // PHASE 3: RESET PASSWORD
                      if (phase == 3) ...[
                        AuthTextField(
                          controller: _newPasswordController,
                          hintText: l10n.newPassword,
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        AuthTextField(
                          controller: _confirmPasswordController,
                          hintText: l10n.confirmNewPassword,
                          prefixIcon: Icons.lock_clock_outlined,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your new password';
                            }
                            if (value != _newPasswordController.text) {
                              return l10n.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24.0),
                      ],

                      // ERROR BANNER
                      if (displayError != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  displayError,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ACTION BUTTON
                      if (phase == 1)
                        PrimaryAuthButton(
                          text: authState.isForgotPasswordSendingOtp
                              ? l10n.sendingOtp
                              : l10n.sendOtp,
                          isLoading: authState.isForgotPasswordSendingOtp,
                          onPressed: authState.isForgotPasswordSendingOtp
                              ? null
                              : _handleSendOtp,
                        ),

                      if (phase == 2)
                        PrimaryAuthButton(
                          text: authState.isForgotPasswordVerifyingOtp
                              ? l10n.verifyingOtp
                              : l10n.verifyOtp,
                          isLoading: authState.isForgotPasswordVerifyingOtp,
                          onPressed: authState.isForgotPasswordVerifyingOtp
                              ? null
                              : _handleVerifyOtp,
                        ),

                      if (phase == 3)
                        PrimaryAuthButton(
                          text: authState.isResettingPassword
                              ? l10n.resettingPassword
                              : l10n.resetPassword,
                          isLoading: authState.isResettingPassword,
                          onPressed: authState.isResettingPassword
                              ? null
                              : _handleResetPassword,
                        ),
                    ],
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
