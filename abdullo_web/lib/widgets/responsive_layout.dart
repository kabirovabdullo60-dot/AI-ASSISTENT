import 'package:flutter/widgets.dart';

import '../core/responsive/breakpoints.dart';

/// Picks a builder by the available width. `tablet` falls back to `desktop`.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.mobile, this.tablet, required this.desktop});

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (Breakpoints.of(constraints.maxWidth)) {
          case ScreenType.mobile:
            return mobile(context);
          case ScreenType.tablet:
            return (tablet ?? desktop)(context);
          case ScreenType.desktop:
            return desktop(context);
        }
      },
    );
  }
}
