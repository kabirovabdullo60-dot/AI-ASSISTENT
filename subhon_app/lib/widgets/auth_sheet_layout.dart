import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';

/// Auth screen laid out as a [hero] header on top and a white sheet with
/// rounded top corners under it: title, subtitle, the form ([children]) and
/// a [footer] pinned to the bottom when there is room. The sheet scrolls
/// over the header when the keyboard needs the space. A back button shows
/// when the screen can go back.
class AuthSheetLayout extends StatelessWidget {
  const AuthSheetLayout({
    required this.hero,
    required this.title,
    required this.children,
    this.subtitle,
    this.footer,
    super.key,
  });

  final Widget hero;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? footer;

  /// The sheet's corner radius; it overlaps the header by this much.
  static const double _radius = 28;
  static const double _maxContentWidth = 480;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    // Fields on the white sheet are softly tinted, as on the design.
    final sheetTheme = theme.copyWith(
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        fillColor: p.surfaceMuted,
      ),
    );
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    return Scaffold(
      backgroundColor: p.surface,
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = (constraints.maxHeight * 0.38).clamp(240.0, 360.0);
          final side = math.max(
            AppSpacing.screen,
            (constraints.maxWidth - _maxContentWidth) / 2,
          );
          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: heroHeight + _radius,
                child: hero,
              ),
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: heroHeight),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - heroHeight,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: p.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(_radius),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              side,
                              AppSpacing.xxl,
                              side,
                              0,
                            ),
                            child: Theme(
                              data: sheetTheme,
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Semantics(
                                      header: true,
                                      child: Text(
                                        title,
                                        style: theme.textTheme.headlineMedium,
                                      ),
                                    ),
                                    if (subtitle != null) ...[
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        subtitle!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: p.textSecondary),
                                      ),
                                    ],
                                    const SizedBox(height: AppSpacing.xl),
                                    ...children,
                                    const Spacer(),
                                    if (footer != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: AppSpacing.xl,
                                          bottom: AppSpacing.lg,
                                        ),
                                        child: footer,
                                      )
                                    else
                                      const SizedBox(height: AppSpacing.xl),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (canPop)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: BackButton(color: Colors.white),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
