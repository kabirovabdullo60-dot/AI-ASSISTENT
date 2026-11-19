import 'package:flutter/material.dart';

import '../core/responsive/breakpoints.dart';
import '../core/theme/app_colors.dart';

/// Scrollable page with the big title row ("Business Overview", "Stores", ...).
class PageBody extends StatelessWidget {
  const PageBody({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.eyebrow = const [],
    this.badge,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;

  /// Breadcrumb above the title, e.g. ['ENTERPRISE FLEET', 'STORE DIRECTORY']. Last part is orange.
  final List<String> eyebrow;
  final Widget? badge;
  final List<Widget> actions;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = Breakpoints.of(constraints.maxWidth) == ScreenType.mobile;
        return ListView(
          padding: EdgeInsets.all(mobile ? 16 : 28),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eyebrow.isNotEmpty) ...[
                      Text.rich(
                        TextSpan(
                          style: const TextStyle(
                            fontSize: 11.5,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                          children: [
                            for (var i = 0; i < eyebrow.length; i++) ...[
                              if (i > 0) const TextSpan(text: '  /  '),
                              TextSpan(
                                text: eyebrow[i],
                                style: i == eyebrow.length - 1 && eyebrow.length > 1
                                    ? const TextStyle(color: AppColors.orange)
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Wrap(
                      spacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: (mobile ? theme.textTheme.headlineSmall : theme.textTheme.headlineMedium)?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        ?badge,
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
                      ),
                    ],
                  ],
                ),
                if (actions.isNotEmpty)
                  Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: actions),
              ],
            ),
            SizedBox(height: mobile ? 16 : 24),
            ...children,
          ],
        );
      },
    );
  }
}
