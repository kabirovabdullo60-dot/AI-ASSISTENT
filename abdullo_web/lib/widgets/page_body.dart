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
    this.entrance = false,
  });

  final String title;
  final String? subtitle;

  /// Breadcrumb above the title, e.g. ['ENTERPRISE FLEET', 'STORE DIRECTORY']. Last part is orange.
  final List<String> eyebrow;
  final Widget? badge;
  final List<Widget> actions;
  final List<Widget> children;

  /// Play the page's one entrance: the title (lead) rises 12px while fading in; the
  /// actions (decoration) only fade. Pages pass true just once per session.
  final bool entrance;

  /// App screens perform no entrance (the content is there when the page opens); kept so
  /// callers need not change.
  Widget _enter(Widget child, {double rise = 0}) => child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = Breakpoints.of(constraints.maxWidth) == ScreenType.mobile;
        return ListView(
          padding: EdgeInsets.fromLTRB(mobile ? 16 : 24, mobile ? 16 : 20, mobile ? 16 : 24, 32),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                _enter(
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            title,
                            // The screen's one h1: a noun at 24/600 (20 on a phone).
                            semanticsLabel: title,
                            style: (mobile ? theme.textTheme.headlineSmall : theme.textTheme.headlineMedium)?.copyWith(
                              fontWeight: FontWeight.w600,
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
                  rise: 12,
                ),
                if (actions.isNotEmpty)
                  _enter(
                    Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: actions),
                  ),
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
