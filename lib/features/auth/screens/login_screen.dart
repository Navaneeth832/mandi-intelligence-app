import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mandi_intelligence_app/l10n/app_localizations.dart';
import 'package:mandi_intelligence_app/main_screen.dart';
import 'forgot_password_screen.dart';
import 'onboarding_screen.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_auth_button.dart';
import 'signup_screen.dart';
import '../providers/auth_provider.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  static const Color _primaryGreen = Color.fromARGB(255, 26, 152, 9);
  static const Color _backgroundColor = Color(0xFFF6F9F6);
  static const Color _textColor = Color(0xFF1A1A1A);
  static const Color _subtitleColor = Color(0xFF666666);

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(authProvider.notifier).clearError();
      }
    });
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final displayError = authState.error;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.agriculture, color: _primaryGreen, size: 32.0),
                    SizedBox(width: 8.0),
                    Text(
                      'Mandi Intelligence',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        color: _primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Smart decisions for better harvests',
                  style: TextStyle(fontSize: 14.0, color: _subtitleColor),
                ),
                const SizedBox(height: 40.0),
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: Colors.black12, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      AuthTextField(
                        controller: _identifierController,
                        hintText: 'Email or Mobile Number',
                        prefixIcon: Icons.badge_outlined,
                        keyboardType: TextInputType.text,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                          AutofillHints.telephoneNumber,
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter your email or mobile number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24.0),
                      AuthTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        autofillHints: const [AutofillHints.password],
                        validator: (value) {

                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }

                        return null;

                      }
                                            ),
                      const SizedBox(height: 12.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ref.read(authProvider.notifier).clearError();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: Text(
                            AppLocalizations.of(context)?.forgotPassword ?? 'Forgot Password?',
                            style: const TextStyle(
                              color: _primaryGreen,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),

                      if (displayError!= null) ...[
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
                                  displayError!,
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
                    PrimaryAuthButton(
                      text: authState.isLoginLoading
                          ? AppLocalizations.of(context)!.loggingIn
                          : AppLocalizations.of(context)!.login,
                      onPressed: authState.isLoginLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context).unfocus();

                                TextInput.finishAutofillContext();

                                final user = await ref.read(authProvider.notifier).login(
                                      _identifierController.text.trim(),
                                      _passwordController.text,
                                    );

                                if (!mounted || user == null) {
                                  return;
                                }

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => user.hasCompletedProfile
                                        ? const MainScreen()
                                        : const OnboardingScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                    ),
                    ],
                  ),
                ),
                const SizedBox(height: 48.0),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [

                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 14,
                        color: _subtitleColor,
                      ),
                    ),

                    TextButton(
                      onPressed: _navigateToSignup,
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: _primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
