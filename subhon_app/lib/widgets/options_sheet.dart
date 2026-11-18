import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import 'app_feedback.dart';

/// A choice from a short list in OFAR's bottom sheet; the selected value
/// is marked. Resolves to the picked option, `null` when dismissed.
Future<T?> showOptionsSheet<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  T? selected,
}) => showAppBottomSheet<T>(
  context,
  title: title,
  builder: (sheet) => ListView(
    shrinkWrap: true,
    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
    children: [
      for (final (value, label) in options)
        ListTile(
          contentPadding: AppSpacing.screenPadding,
          title: Text(label),
          trailing: value == selected
              ? Icon(Icons.check_rounded, color: context.palette.primary)
              : null,
          onTap: () => Navigator.of(sheet).pop(value),
        ),
    ],
  ),
);
