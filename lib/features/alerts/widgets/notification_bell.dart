import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alert_providers.dart';
import '../screens/alerts_screen.dart';

class NotificationBell extends ConsumerWidget {
  final Color? iconColor;
  final double iconSize;
  final BoxDecoration? containerDecoration;
  final EdgeInsetsGeometry? padding;
  final IconData icon;

  const NotificationBell({
    super.key,
    this.iconColor,
    this.iconSize = 28,
    this.containerDecoration,
    this.padding,
    this.icon = Icons.notifications_none,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadAlertCountProvider);

    final semanticLabel = unreadCount > 0
        ? 'Notifications, $unreadCount unread'
        : 'Notifications';

    final String badgeText = unreadCount >= 10 ? '9+' : '$unreadCount';

    Widget iconWidget = Icon(
      icon,
      color: iconColor ?? Theme.of(context).iconTheme.color,
      size: iconSize,
    );

    Widget content = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        if (unreadCount > 0)
          Positioned(
            top: -4,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444), // Bright red
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                badgeText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
          ),
      ],
    );

    Widget bellButton;
    if (containerDecoration != null) {
      bellButton = Container(
        padding: padding ?? const EdgeInsets.all(12),
        decoration: containerDecoration,
        child: content,
      );
    } else {
      bellButton = Padding(
        padding: padding ?? const EdgeInsets.all(8.0),
        child: content,
      );
    }

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Tooltip(
        message: semanticLabel,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AlertsScreen()),
            );
          },
          child: bellButton,
        ),
      ),
    );
  }
}
