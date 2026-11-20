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
    this.onToggle,
  });

  static const extendedWidth = 236.0;
  static const compactWidth = 88.0;

  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  final bool extended;
  final String brandName;

  /// Desktop only: folds / unfolds the menu. Null → no button (tablet is always compact).
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    Widget content(bool wide) => SafeArea(
      child: Column(
        children: [
          _Brand(name: brandName, extended: wide, onToggle: onToggle),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _NavGroup(sections: AppSection.main, selected: selected, extended: wide, onSelect: onSelect),
            ),
          ),
          Divider(color: AppColors.border, height: 1, indent: 14, endIndent: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            child: _NavGroup(sections: AppSection.footer, selected: selected, extended: wide, onSelect: onSelect),
          ),
        ],
      ),
    );

    // Folding / unfolding: the panel width slides (280ms); each layout keeps its own width and is
    // clipped by the panel, and at the halfway point the wide and compact layouts crossfade.
    return TweenAnimationBuilder<double>(
      tween: Tween(end: extended ? extendedWidth : compactWidth),
      duration: Motion.reduced(context) ? Duration.zero : const Duration(milliseconds: 280),
      curve: Motion.easeInOut,
      builder: (context, width, _) {
        final wide = width > (extendedWidth + compactWidth) / 2;
        // Open plane: the sidebar sits on the page ground, split from the canvas by one hairline.
        return Container(
          key: const Key('app-sidebar'),
          width: width,
          margin: const EdgeInsets.only(left: 12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: AnimatedSwitcher(
            duration: Motion.fast,
            child: OverflowBox(
              key: ValueKey(wide),
              alignment: wide ? Alignment.topLeft : Alignment.topCenter,
              minWidth: wide ? extendedWidth : compactWidth,
              maxWidth: wide ? extendedWidth : compactWidth,
              child: content(wide),
            ),
          ),
        );
      },
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.name, required this.extended, this.onToggle});

  final String name;
  final bool extended;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final logo = const BrandMark();
    final tr = context.l10n;
    Widget toggle(bool open) => IconButton(
      key: const Key('sidebar-toggle'),
      tooltip: open ? tr.collapseMenu : tr.expandMenu,
      onPressed: onToggle,
      visualDensity: VisualDensity.compact,
      icon: Icon(open ? Icons.menu_open : Icons.menu, color: AppColors.muted),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(extended ? 20 : 0, 20, extended ? (onToggle == null ? 16 : 6) : 0, 20),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (onToggle != null) toggle(true),
              ],
            )
          : Column(
              children: [
                Center(
                  child: Tooltip(message: name, child: logo),
                ),
                if (onToggle != null) ...[const SizedBox(height: 8), toggle(false)],
              ],
            ),
    );
  }
}

/// A list of menu items with ONE selection pill that slides to the chosen item
/// (one object moves, instead of one item fading out while another fades in).
class _NavGroup extends StatelessWidget {
  const _NavGroup({required this.sections, required this.selected, required this.extended, required this.onSelect});

  static const extendedItem = 36.0;
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
                  color: AppColors.isDark ? AppColors.surfaceSoft : const Color(0xFFE8E7E4),
                  borderRadius: BorderRadius.circular(AppTheme.radiusControl),
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
    final color = selected ? AppColors.ink : AppColors.muted;
    final icon = Icon(section.icon, size: 18, color: color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: extended ? _NavGroup.extendedItem : _NavGroup.compactItem,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: Key('nav-${section.name}'),
            borderRadius: BorderRadius.circular(AppTheme.radiusControl),
            hoverColor: AppColors.ink.withValues(alpha: 0.04),
            onTap: onTap,
            child: Semantics(
              selected: selected,
              button: true,
              label: context.l10n.section(section),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: extended ? 10 : 4, vertical: extended ? 8 : 9),
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
                                color: selected
                                    ? AppColors.ink
                                    : (AppColors.isDark ? AppColors.muted : const Color(0xFF4B4B4B)),
                                fontSize: 14,
                                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
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
                            style: TextStyle(color: color, fontSize: 11),
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
