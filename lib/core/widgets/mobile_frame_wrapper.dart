import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A wrapper widget that enforces a 390x884 mobile viewport view
/// when running on desktop / wide web browsers, while rendering full-screen
/// on actual mobile devices.
class MobileFrameWrapper extends StatelessWidget {
  final Widget? child;

  const MobileFrameWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (child == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // If on a wide screen (desktop/laptop/tablet web browser)
        if (screenWidth > 450) {
          const double targetWidth = 390.0;
          const double targetHeight = 884.0;

          // Fit height dynamically if browser window height is smaller than targetHeight + padding
          final double availableHeight = math.max(0.0, screenHeight - 32.0);
          final double actualHeight = math.min(targetHeight, availableHeight);

          // Calculate scale factor if screen height is very small
          final double scale = actualHeight < targetHeight
              ? actualHeight / targetHeight
              : 1.0;
          final double actualWidth = targetWidth * scale;

          return Scaffold(
            backgroundColor: const Color(0xFF0F172A), // Dark slate background for desktop
            body: Stack(
              children: [
                // Subtle desktop background graphic / branding
                Center(
                  child: Container(
                    width: actualWidth + 20,
                    height: actualHeight + 20,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(36 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 40,
                          spreadRadius: 10,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                          blurRadius: 60,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: actualWidth,
                    height: actualHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(32 * scale),
                      border: Border.all(
                        color: const Color(0xFF1E293B),
                        width: math.max(2.0, 6.0 * scale),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26 * scale),
                      child: MediaQuery(
                        // Provide target mobile screen dimensions (390x884) to child widgets
                        data: MediaQuery.of(context).copyWith(
                          size: Size(targetWidth, targetHeight),
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: targetWidth,
                            height: targetHeight,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // On native mobile viewports (<= 450px)
        return child!;
      },
    );
  }
}
