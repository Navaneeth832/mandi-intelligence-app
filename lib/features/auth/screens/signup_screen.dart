import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_auth_button.dart';
import 'login_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _identityFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  Timer? _resendTimer;
  DateTime? _resendAvailableAt;

  static const Color _primaryGreen = Color.fromARGB(255, 26, 152, 9);
  static const Color _backgroundColor = Color(0xFFF8FAF8);
  static const Color _textColor = Color(0xFF1A1A1A);
  static const Color _subtitleColor = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(authProvider.notifier).resetSignupFlow();
      ref.read(authProvider.notifier).clearError();
      _stopResendTimer();
    });
  }

  @override
  void dispose() {
    _stopResendTimer();
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _stopResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }

  void _startResendTimer() {
    _stopResendTimer();
    _resendAvailableAt = DateTime.now().add(const Duration(minutes: 5));
    setState(() {});

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final availableAt = _resendAvailableAt;
      if (availableAt == null || DateTime.now().isAfter(availableAt)) {
        timer.cancel();
        setState(() {});
        return;
      }

      setState(() {});
    });
  }

  bool get _canResendOtp {
    final availableAt = _resendAvailableAt;
    if (availableAt == null) {
      return false;
    }
    return DateTime.now().isAfter(availableAt) || DateTime.now().isAtSameMomentAs(availableAt);
  }

  String _formatRemaining(Duration duration) {
    final totalSeconds = duration.inSeconds.clamp(0, 599);
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String? _sanitizeError(String? error) {
    if (error == null) {
      return null;
    }

    return error
        .replaceFirst('Exception: ', '')
        .replaceFirst('ClientException: ', '')
        .trim();
  }

  void _navigateToLogin() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _handleSendOtp() async {
    if (!_identityFormKey.currentState!.validate()) {
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.sendOtp(_identifierController.text.trim());

    if (!mounted) {
      return;
    }

    if (success) {
      final normalizedIdentifier = ref.read(authProvider).signupIdentifier;
      if (normalizedIdentifier != null && normalizedIdentifier.isNotEmpty) {
        _identifierController.value = TextEditingValue(
          text: normalizedIdentifier,
          selection: TextSelection.collapsed(offset: normalizedIdentifier.length),
        );
      }
      _otpController.clear();
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(authProvider).signupRegistrationMethod == 'phone'
                ? 'OTP sent to your mobile number'
                : 'OTP sent to your email address',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtp(_otpController.text.trim());

    if (!mounted) {
      return;
    }

    if (success) {
      _stopResendTimer();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP verified successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authProvider.notifier).register(
          _nameController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please log in.'),
          backgroundColor: Colors.green,
        ),
      );
      _navigateToLogin();
      return;
    }

    final error = _sanitizeError(ref.read(authProvider).error);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  void _resetIdentifierFlow() {
    ref.read(authProvider.notifier).resetSignupFlow();
    ref.read(authProvider.notifier).clearError();
    _otpController.clear();
    _stopResendTimer();
    setState(() {
      _resendAvailableAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final errorMessage = _sanitizeError(authState.error);
    final hasRequestedOtp = authState.hasRequestedOtp;
    final isOtpVerified = authState.otpVerified;
    final resendRemaining = _resendAvailableAt == null
        ? Duration.zero
        : _resendAvailableAt!.difference(DateTime.now());
    final canResend = hasRequestedOtp && !isOtpVerified && _canResendOtp;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.agriculture_outlined,
                        color: _primaryGreen,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40.0),
                const Text(
                  'Join Mandi Intelligence',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Create your account to access real-time market data and price insights across Kerala.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: _subtitleColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24.0),
                if (errorMessage != null) ...[
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
                            errorMessage,
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
                Form(
                  key: _identityFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthTextField(
                        controller: _nameController,
                        hintText: 'Full Name',
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.next,
                        enabled: !authState.isSendingOtp && !isOtpVerified && !authState.isRegistering,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      AuthTextField(
                        controller: _identifierController,
                        hintText: 'Email or Mobile Number',
                        prefixIcon: Icons.badge_outlined,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        enabled: !authState.isSendingOtp && !authState.isRegistering,
                        readOnly: hasRequestedOtp && !isOtpVerified,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email or mobile number';
                          }
                          return null;
                        },
                      ),
                      if (hasRequestedOtp && !isOtpVerified) ...[
                        const SizedBox(height: 12.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: authState.isSendingOtp || authState.isVerifyingOtp || authState.isRegistering
                                ? null
                                : _resetIdentifierFlow,
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Change identifier',
                              style: TextStyle(
                                color: _primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16.0),
                      PrimaryAuthButton(
                        text: authState.isSendingOtp
                            ? 'Sending OTP...'
                            : hasRequestedOtp && !isOtpVerified && !canResend
                                ? 'Resend in ${_formatRemaining(resendRemaining)}'
                                : hasRequestedOtp && !isOtpVerified
                                    ? 'Resend OTP'
                                    : 'Verify',
                        icon: authState.isSendingOtp
                            ? null
                            : hasRequestedOtp && !isOtpVerified && canResend
                                ? Icons.refresh
                                : Icons.verified_outlined,
                        isLoading: authState.isSendingOtp,
                        isDisabled: authState.isVerifyingOtp || authState.isRegistering || (hasRequestedOtp && !isOtpVerified && !canResend),
                        onPressed: hasRequestedOtp && !isOtpVerified && canResend ? _handleSendOtp : _handleSendOtp,
                      ),
                      if (hasRequestedOtp && !isOtpVerified) ...[
                        const SizedBox(height: 20.0),
                        AuthTextField(
                          controller: _otpController,
                          hintText: 'Enter OTP',
                          prefixIcon: Icons.pin_outlined,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          enabled: !authState.isVerifyingOtp && !authState.isRegistering,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the OTP';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14.0),
                        if (isOtpVerified)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified_rounded, color: Colors.green, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Phone or email verified',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryAuthButton(
                                  text: authState.isVerifyingOtp ? 'Verifying OTP...' : 'Verify OTP',
                                  icon: Icons.verified_user_outlined,
                                  isLoading: authState.isVerifyingOtp,
                                  isDisabled: !hasRequestedOtp || authState.isSendingOtp || authState.isRegistering,
                                  onPressed: _handleVerifyOtp,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Form(
                  key: _registerFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        enabled: !authState.isRegistering,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password',
                        prefixIcon: Icons.gpp_good_outlined,
                        isPassword: true,
                        enabled: !authState.isRegistering,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),
                      FormField<bool>(
                        initialValue: false,
                        validator: (value) => value == true ? null : 'You must accept terms',
                        builder: (FormFieldState<bool> field) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 24.0,
                                    width: 24.0,
                                    child: Checkbox(
                                      value: field.value,
                                      onChanged: authState.isRegistering
                                          ? null
                                          : (value) {
                                              field.didChange(value);
                                            },
                                      activeColor: _primaryGreen,
                                      side: const BorderSide(color: Colors.grey, width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  const Expanded(
                                    child: Text(
                                      'By signing up, I agree to the Terms of Service and Privacy Policy.',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: _subtitleColor,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (field.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, left: 36.0),
                                  child: Text(
                                    field.errorText!,
                                    style: const TextStyle(color: Colors.red, fontSize: 12.0),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24.0),
                      PrimaryAuthButton(
                        text: authState.isRegistering ? 'Creating Account...' : 'Register',
                        icon: Icons.arrow_forward,
                        isLoading: authState.isRegistering,
                        isDisabled: !authState.canRegister,
                        onPressed: _handleRegister,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28.0),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: _subtitleColor,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Log In',
                        style: const TextStyle(
                          color: _primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = _navigateToLogin,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
