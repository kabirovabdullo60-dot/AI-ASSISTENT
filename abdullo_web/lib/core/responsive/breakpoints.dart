enum ScreenType { mobile, tablet, desktop }

/// Width breakpoints for the web. Resize the browser to see the layout change.
class Breakpoints {
  Breakpoints._();

  static const double tablet = 600;
  static const double desktop = 1024;

  static ScreenType of(double width) {
    if (width < tablet) return ScreenType.mobile;
    if (width < desktop) return ScreenType.tablet;
    return ScreenType.desktop;
  }
}
