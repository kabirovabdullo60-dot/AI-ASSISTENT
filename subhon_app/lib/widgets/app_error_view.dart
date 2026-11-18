import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import 'app_message_view.dart';

/// A failed load: the translated reason and "Try again".
class AppErrorView extends StatelessWidget {
  const AppErrorView({required this.error, this.onRetry, super.key});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => AppMessageView(
    icon: Icons.error_outline_rounded,
    iconColor: context.palette.error,
    iconBackground: context.palette.errorLight,
    title: context.l10n.commonErrorTitle,
    message: errorText(context.l10n, error),
    actionLabel: onRetry == null ? null : context.l10n.commonRetry,
    onAction: onRetry,
  );
}
