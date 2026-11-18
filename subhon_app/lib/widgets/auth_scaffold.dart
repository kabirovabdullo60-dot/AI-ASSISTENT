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
    this.hero,
    this.centerTitle = false,
    this.background,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? footer;
  final bool showLogo;

  /// Shown centred instead of the logo (the mascot).
  final Widget? hero;

  /// Centres the title and the subtitle.
  final bool centerTitle;

  /// Painted behind the whole screen instead of the plain surface colour
  /// (the dark register screen).
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final barColor = background == null ? p.surface : Colors.transparent;
    final scaffold = Scaffold(
      backgroundColor: barColor,
      appBar: AppBar(backgroundColor: barColor, toolbarHeight: 48),
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
                    if (hero != null) ...[
                      Center(child: hero),
                      const SizedBox(height: AppSpacing.md),
                    ] else if (showLogo) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: OfarLogo(size: 44),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: theme.textTheme.headlineMedium,
                        textAlign: centerTitle
                            ? TextAlign.center
                            : TextAlign.start,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        subtitle!,
                        textAlign: centerTitle
                            ? TextAlign.center
                            : TextAlign.start,
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
    if (background == null) return scaffold;
    return Stack(
      children: [
        Positioned.fill(child: background!),
        scaffold,
      ],
    );
  }
}

/// "Нет аккаунта? Зарегистрироваться" style footer.
/// Horizontal rule with a centered label ("или").
