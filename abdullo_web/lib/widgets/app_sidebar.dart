import 'package:flutter/material.dart';

import '../core/l10n/l10n.dart';
import '../core/navigation/app_section.dart';
import '../core/motion/motion.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'brand_mark.dart';

/// Side menu: white panel with a hairline edge; the current page is a soft teal pill.
/// [extended] = desktop (icons + labels), otherwise tablet (compact).
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.extended,
    required this.brandName,
  });

  static const extendedWidth = 236.0;
  static const compactWidth = 88.0;

  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  final bool extended;
  final String brandName;

  @override
  Widget build(BuildContext context) {
    Widget group(List<AppSection> sections) =>
        _NavGroup(sections: sections, selected: selected, extended: extended, onSelect: onSelect);

    // A floating panel: inset from the window edges, rounded, lifted off the page.
    return Container(
      key: const Key('app-sidebar'),
      width: extended ? extendedWidth : compactWidth,
      margin: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: AppColors.isDark ? Border.all(color: AppColors.border) : null,
        boxShadow: AppColors.isDark
            ? null
            : [BoxShadow(color: AppColors.navy.withValues(alpha: 0.08), blurRadius: 28, offset: const Offset(0, 10))],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _Brand(name: brandName, extended: extended),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: group(AppSection.main),
              ),
            ),
            Divider(color: AppColors.border, height: 1, indent: 14, endIndent: 14),
            Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 12), child: group(AppSection.footer)),
          ],
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.name, required this.extended});

  final String name;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final logo = const BrandMark();
    return Padding(
      padding: EdgeInsets.fromLTRB(extended ? 20 : 0, 20, extended ? 16 : 0, 20),
      child: extended
          ? Row(
              children: [
                logo,
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.display,
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Tooltip(message: name, child: logo),
            ),
    );
  }
}

/// A list of menu items with ONE selection pill that slides to the chosen item
/// (one object moves, instead of one item fading out while another fades in).
class _NavGroup extends StatelessWidget {
  const _NavGroup({required this.sections, required this.selected, required this.extended, required this.onSelect});

  static const extendedItem = 44.0;
  static const compactItem = 58.0;
  static const gap = 4.0; // 2px above + 2px below each item

  final List<AppSection> sections;
  final AppSection selected;
  final bool extended;
  final ValueChanged<AppSection> onSelect;

  @override
  Widget build(BuildContext context) {
    final itemH = extended ? extendedItem : compactItem;
    final index = sections.indexOf(selected);
    final reduced = Motion.reduced(context);
    return Stack(
      children: [
        // Moves with a transform (no layout work), 240ms, and retargets mid-flight.
        Positioned(
          top: gap / 2,
          left: 0,
          right: 0,
          height: itemH,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: (index < 0 ? 0 : index) * (itemH + gap)),
            duration: reduced ? Duration.zero : const Duration(milliseconds: 240),
            curve: Motion.easeInOut,
            builder: (context, y, child) => Transform.translate(offset: Offset(0, y), child: child),
            child: AnimatedOpacity(
              duration: Motion.fast,
              opacity: index < 0 ? 0 : 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.teal.withValues(alpha: 0.38),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Column(
          children: [
            for (final s in sections)
              _SidebarItem(section: s, selected: s == selected, extended: extended, onTap: () => onSelect(s)),
          ],
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.section, required this.selected, required this.extended, required this.onTap});

  final AppSection section;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : AppColors.muted;
    final icon = Icon(selected ? section.selectedIcon : section.icon, size: 19, color: color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: extended ? _NavGroup.extendedItem : _NavGroup.compactItem,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: Key('nav-${section.name}'),
            borderRadius: BorderRadius.circular(12),
            hoverColor: AppColors.ink.withValues(alpha: 0.04),
            onTap: onTap,
            child: Semantics(
              selected: selected,
              button: true,
              label: context.l10n.section(section),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: extended ? 12 : 4, vertical: extended ? 11 : 9),
                child: extended
                    ? Row(
                        children: [
                          icon,
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              context.l10n.section(section),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: color,
                                fontSize: 14,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          icon,
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.section(section),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: color, fontSize: 10.5),
                          ),
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
