import 'package:flutter/material.dart';

import '../core/l10n/l10n.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';

/// Dark navy side menu from the Figma design.
/// [extended] = desktop (icons + labels), otherwise tablet (compact).
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.extended,
    required this.brandName,
  });

  static const extendedWidth = 232.0;
  static const compactWidth = 88.0;

  final AppSection selected;
  final ValueChanged<AppSection> onSelect;
  final bool extended;
  final String brandName;

  @override
  Widget build(BuildContext context) {
    Widget item(AppSection s) =>
        _SidebarItem(section: s, selected: s == selected, extended: extended, onTap: () => onSelect(s));

    return Container(
      key: const Key('app-sidebar'),
      width: extended ? extendedWidth : compactWidth,
      color: AppColors.navy,
      child: SafeArea(
        child: Column(
          children: [
            _Brand(name: brandName, extended: extended),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [for (final s in AppSection.main) item(s)],
              ),
            ),
            const Divider(color: AppColors.navyLight, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
              child: Column(children: [for (final s in AppSection.footer) item(s)]),
            ),
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
    final logo = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
    );
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
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
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

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.section, required this.selected, required this.extended, required this.onTap});

  final AppSection section;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.white.withValues(alpha: 0.66);
    final icon = Icon(selected ? section.selectedIcon : section.icon, size: 19, color: color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? AppColors.orange : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: Key('nav-${section.name}'),
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.white.withValues(alpha: 0.06),
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
    );
  }
}
