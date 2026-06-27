import 'package:flutter/material.dart';

/// A reusable header for Auth screens containing the Logo, Help Icon, Title, and Subtitle.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onHelpPressed;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onHelpPressed,
  });

  static const Color _primaryGreen = Color(0xFF006B33);
  static const Color _textColor = Color(0xFF1A1A1A);
  static const Color _subtitleColor = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Top Header Row (Logo & Help Icon)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // App Logo Placeholder (Tree/Hexagon icon)
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
              onPressed: onHelpPressed,
              icon: const Icon(
                Icons.help_outline,
                color: _subtitleColor,
              ),
              tooltip: 'Help',
              splashRadius: 24.0,
            ),
          ],
        ),
        
        const SizedBox(height: 48.0),

        // Screen Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        
        const SizedBox(height: 12.0),

        // Screen Subtitle
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: _subtitleColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}