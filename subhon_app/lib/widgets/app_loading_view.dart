import 'package:flutter/material.dart';

import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      liveRegion: true,
      label: message ?? context.l10n.commonLoading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox.square(
            dimension: 32,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(message!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    ),
  );
}
