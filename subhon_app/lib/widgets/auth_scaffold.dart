import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import 'ofar_logo.dart';

/// Shared layout of all auth screens: back button, logo, title, subtitle,
/// scrollable form and a footer pinned to the bottom when space allows.
/// Content is capped at 480 pt so it reads well on tablets.
const double _maxContentWidth = 480;

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.children,
    this.subtitle,
    this.footer,
    this.showLogo = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? footer;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppBar(backgroundColor: p.surface, toolbarHeight: 48),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            // Centers a 480 pt column on wide screens without loosening the
            // min-height constraint the footer relies on.
            padding: EdgeInsets.symmetric(
              horizontal: math.max(
                AppSpacing.screen,
                (constraints.maxWidth - _maxContentWidth) / 2,
              ),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showLogo) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: OfarLogo(size: 44),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                    Semantics(
                      header: true,
                      child: Text(title, style: theme.textTheme.headlineMedium),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    ...children,
                    const Spacer(),
                    if (footer != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.xxl,
                          bottom: AppSpacing.lg,
                        ),
                        child: footer,
                      )
                    else
                      const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Нет аккаунта? Зарегистрироваться" style footer.
/// Horizontal rule with a centered label ("или").
