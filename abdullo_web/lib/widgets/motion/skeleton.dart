import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/theme/app_colors.dart';

/// Loading placeholder shaped like a page (title, stat tiles, a big card) with a soft
/// shimmer sweeping across — the page feels like it is arriving, not stuck.
class PageSkeleton extends StatefulWidget {
  const PageSkeleton({super.key});

  @override
  State<PageSkeleton> createState() => _PageSkeletonState();
}

class _PageSkeletonState extends State<PageSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _box(double? w, double h, {double r = 10}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(color: AppColors.border.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(r)),
  );

  @override
  Widget build(BuildContext context) {
    final reduced = Motion.reduced(context);
    return LayoutBuilder(
      builder: (context, c) {
        final mobile = Breakpoints.of(c.maxWidth) == ScreenType.mobile;
        final tiles = mobile ? 2 : 4;
        final body = Padding(
          key: const Key('page-skeleton'),
          padding: EdgeInsets.all(mobile ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _box(220, 28),
              const SizedBox(height: 10),
              _box(320, 14),
              const SizedBox(height: 26),
              Row(
                children: [
                  for (var i = 0; i < tiles; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: _box(null, 120, r: 14)),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              _box(double.infinity, 260, r: 14),
            ],
          ),
        );
        if (reduced) return body;
        return AnimatedBuilder(
          animation: _c,
          child: body,
          builder: (context, child) => ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) {
              final x = -1.0 + 3.0 * _c.value;
              return LinearGradient(
                begin: Alignment(x - 1, -0.2),
                end: Alignment(x, 0.2),
                colors: [
                  Colors.white.withValues(alpha: 0),
                  Colors.white.withValues(alpha: 0.55),
                  Colors.white.withValues(alpha: 0),
                ],
              ).createShader(rect);
            },
            child: child,
          ),
        );
      },
    );
  }
}
