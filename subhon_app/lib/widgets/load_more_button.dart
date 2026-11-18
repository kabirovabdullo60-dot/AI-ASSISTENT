import 'package:flutter/material.dart';

import '../core/theme/app_dimensions.dart';
import 'app_button.dart';

/// "Show more" under a paged list.
class LoadMoreButton extends StatelessWidget {
  const LoadMoreButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.md),
    child: AppButton(
      label: label,
      variant: AppButtonVariant.text,
      size: AppButtonSize.medium,
      isLoading: isLoading,
      onPressed: onPressed,
    ),
  );
}
