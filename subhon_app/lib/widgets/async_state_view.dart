import 'package:flutter/material.dart';

import 'app_empty_view.dart';
import 'app_error_view.dart';
import 'app_loading_view.dart';

/// The standard loading / error / empty / data states of a screen, read
/// from its ViewModel. While data is already shown, a reload keeps it on
/// screen (pull-to-refresh shows its own indicator).
class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    required this.isLoading,
    required this.error,
    required this.hasData,
    required this.builder,
    this.isEmpty = false,
    this.empty,
    this.onRetry,
    super.key,
  });

  final bool isLoading;
  final Object? error;
  final bool hasData;
  final bool isEmpty;
  final Widget? empty;
  final VoidCallback? onRetry;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    if (!hasData) {
      if (error != null) return AppErrorView(error: error!, onRetry: onRetry);
      return const AppLoadingView();
    }
    if (isEmpty) return empty ?? const AppEmptyView();
    return builder(context);
  }
}
