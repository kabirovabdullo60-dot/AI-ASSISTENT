import 'package:flutter/material.dart';

import '../core/motion/motion.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_palette.dart';

/// Display name of a palette (brand names, the same in every language).
String paletteName(AppPalette p) => switch (p) {
  AppPalette.ledger => 'Ledger',
  AppPalette.graphite => 'Graphite',
};

/// Three dots: the palette's background, accent and second accent.
class PaletteDots extends StatelessWidget {
  const PaletteDots(this.palette, {super.key, this.size = 14});

  final AppPalette palette;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = palette.colors;
    Widget dot(Color color) => Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(right: 3),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
      ),
    );
    return Row(mainAxisSize: MainAxisSize.min, children: [dot(c.background), dot(c.accent), dot(c.accent2)]);
  }
}

/// A selectable card for the Settings page: a tiny preview of the palette plus its name.
class PaletteCard extends StatelessWidget {
  const PaletteCard({super.key, required this.palette, required this.selected, required this.onTap});

  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = palette.colors;
    return AnimatedContainer(
      duration: Motion.base,
      curve: Motion.easeOut,
      width: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppColors.teal : AppColors.border, width: selected ? 2 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('settings-palette-${palette.name}'),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mini preview: page background, a card, an accent button.
              Container(
                height: 72,
                color: c.background,
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      width: 18,
                      decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: c.card,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: c.border),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Container(
                                width: 34,
                                height: 12,
                                decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(4)),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(color: c.accent2, shape: BoxShape.circle),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        paletteName(palette),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink),
                      ),
                    ),
                    if (selected) Icon(Icons.check_circle, size: 16, color: AppColors.teal),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
