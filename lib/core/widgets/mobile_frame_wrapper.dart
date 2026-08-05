import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A wrapper widget that enforces an exact 390x884 mobile viewport view
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

          // Scale down proportionally if viewport height is smaller than targetHeight
          final double availableHeight = math.max(0.0, screenHeight - 32.0);
          final double scale = availableHeight < targetHeight
              ? availableHeight / targetHeight
              : 1.0;

          final double frameWidth = targetWidth * scale;
          final double frameHeight = targetHeight * scale;

          return Scaffold(
            backgroundColor: const Color(0xFF0F172A), // Dark slate background for desktop
            body: Center(
              child: Container(
                width: frameWidth,
                height: frameHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF7),
                  borderRadius: BorderRadius.circular(32 * scale),
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
                      size: const Size(targetWidth, targetHeight),
                    ),
                    child: Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
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
          );
        }

        // On native mobile viewports (<= 450px)
        return child!;
      },
    );
  }
}
