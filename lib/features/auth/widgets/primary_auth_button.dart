import 'package:flutter/material.dart';

/// A reusable, full-width, pill-shaped primary button for authentication screens.
class PrimaryAuthButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  const PrimaryAuthButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  static const Color _primaryGreen = Color(0xFF006B33);

  @override
  Widget build(BuildContext context) {
    final bool isEffectivelyDisabled = isDisabled || isLoading || onPressed == null;

    return SizedBox(
      width: double.infinity,
      height: 56.0,
      child: ElevatedButton(
        onPressed: isEffectivelyDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryGreen.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white70,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0), // Pill shape
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8.0),
                    Icon(icon, size: 20.0),
                  ],
                ],
              ),
      ),
    );
  }
}
