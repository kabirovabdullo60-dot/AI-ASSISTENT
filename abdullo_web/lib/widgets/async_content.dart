import 'package:flutter/material.dart';

import 'error_retry.dart';

/// Spinner while the first load runs, error + retry if it fails, otherwise the page.
class AsyncContent extends StatelessWidget {
  const AsyncContent({
    super.key,
    required this.hasData,
    required this.error,
    required this.onRetry,
    required this.builder,
  });

  final bool hasData;
  final String? error;
  final VoidCallback onRetry;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    if (hasData) return builder(context);
    if (error != null) return ErrorRetry(message: error!, onRetry: onRetry);
    return const Center(child: CircularProgressIndicator());
  }
}
