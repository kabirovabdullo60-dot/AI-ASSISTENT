import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/l10n.dart';
import 'app_message_view.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    this.icon = Icons.inbox_outlined,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => AppMessageView(
    icon: icon,
    iconColor: context.palette.primary,
    iconBackground: context.palette.primaryLight,
    title: title ?? context.l10n.commonEmptyTitle,
    message: message,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}
