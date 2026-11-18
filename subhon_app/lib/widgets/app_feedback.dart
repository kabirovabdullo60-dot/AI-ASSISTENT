import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import 'app_button.dart';

enum _SnackKind { success, error, info }

/// Short, non-blocking feedback after an action.
///
/// Use [AppSnackbar.of] to capture the messenger *before* an `await` when the
/// screen may be replaced by navigation (e.g. after sign-in); the snackbar is
/// then shown on whichever screen is current.
class AppSnackbar {
  AppSnackbar.of(BuildContext context)
    : _messenger = ScaffoldMessenger.of(context),
      _palette = context.palette;

  final ScaffoldMessengerState _messenger;
  final AppPalette _palette;

  static void success(BuildContext context, String message) =>
      AppSnackbar.of(context).showSuccess(message);

  static void error(BuildContext context, String message) =>
      AppSnackbar.of(context).showError(message);

  static void info(BuildContext context, String message) =>
      AppSnackbar.of(context).showInfo(message);

  void showSuccess(String message) => _show(message, _SnackKind.success);
  void showError(String message) => _show(message, _SnackKind.error);
  void showInfo(String message) => _show(message, _SnackKind.info);

  void _show(String message, _SnackKind kind) {
    final (icon, color) = switch (kind) {
      _SnackKind.success => (Icons.check_circle_rounded, _palette.success),
      _SnackKind.error => (Icons.error_rounded, _palette.error),
      _SnackKind.info => (Icons.info_rounded, _palette.secondary),
    };
    _messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }
}

/// Confirmation for important or irreversible actions.
/// Resolves to `true` only when the user confirms.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: cancelLabel ?? l10n.commonCancel,
                variant: AppButtonVariant.outline,
                size: AppButtonSize.medium,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppButton(
                label: confirmLabel ?? l10n.commonConfirm,
                variant: destructive
                    ? AppButtonVariant.destructive
                    : AppButtonVariant.primary,
                size: AppButtonSize.medium,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Modal bottom sheet with a drag handle and an optional title.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.palette.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.lg,
                  AppSpacing.screen,
                  0,
                ),
                child: Text(title, style: theme.textTheme.titleLarge),
              ),
            Flexible(child: builder(context)),
          ],
        ),
      ),
    );
  },
);
