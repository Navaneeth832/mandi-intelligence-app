import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_screen.dart';
import '../widgets/auth_text_field.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _termsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  static const Color _primaryGreen = Color.fromARGB(255, 26, 152, 9);
  static const Color _backgroundColor = Color(0xFFF8FAF8);
  static const Color _textColor = Color(0xFF1A1A1A);
  static const Color _subtitleColor = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      }
      if (!next.isLoading && previous?.isLoading == true && next.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully. Please login.'), backgroundColor: Colors.green),
        );
        _navigateToLogin();
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: _primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(
                          Icons.park_outlined,
                          color: _primaryGreen,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.help_outline,
                          color: _subtitleColor,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48.0),

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
                    'Create your official account to access real-time market data and price insights across Kerala.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: _subtitleColor,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 32.0),

                  AuthTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 16.0),
                  
                  AuthTextField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  
                  AuthTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 16.0),
                  
                  AuthTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    prefixIcon: Icons.gpp_good_outlined,
                    isPassword: true,
                    validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                  ),
                  
                  const SizedBox(height: 24.0),

                  FormField<bool>(
                    initialValue: _termsAccepted,
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
                                  onChanged: (value) {
                                    field.didChange(value);
                                    setState(() => _termsAccepted = value!);
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
                  
                  const SizedBox(height: 32.0),

                  SizedBox(
                    width: double.infinity,
                    height: 56.0,
                    child: ElevatedButton(
                      onPressed: authState.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                ref.read(authProvider.notifier).register(
                                      _nameController.text,
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            authState.isLoading ? 'Creating Account...' : 'Create Account',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          const Icon(Icons.arrow_forward, size: 20.0),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32.0),

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
      ),
    );
  }
}