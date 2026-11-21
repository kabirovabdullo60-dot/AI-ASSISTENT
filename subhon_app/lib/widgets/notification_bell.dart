import 'package:flutter/material.dart';

/// The bell in the app bar, with the number of unread notifications.
class NotificationBell extends StatelessWidget {
  const NotificationBell({
    required this.unread,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final int unread;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Badge(
      isLabelVisible: unread > 0,
      label: Text(unread > 99 ? '99+' : '$unread'),
      child: Icon(
        unread > 0
            ? Icons.notifications_active_outlined
            : Icons.notifications_none_rounded,
      ),
    ),
  );
}
