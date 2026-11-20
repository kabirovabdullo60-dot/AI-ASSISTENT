import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/motion/motion.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/auth_view_model.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/brand_mark.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/voice_status_pill.dart';
import 'app_top_bar_view.dart';
import 'assistant_view.dart';
import 'dashboard_view.dart';
import 'employees_view.dart';
import 'expenses_view.dart';
import 'profile_view.dart';
import 'reports_view.dart';
import 'salaries_view.dart';
import 'sales_view.dart';
import 'settings_view.dart';
import 'stores_view.dart';

/// App shell. Desktop: wide navy sidebar. Tablet: compact sidebar. Phone: bottom bar + "More".
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Widget _page(AppSection section) => switch (section) {
    AppSection.dashboard => const DashboardView(),
    AppSection.stores => const StoresView(),
    AppSection.sales => const SalesView(),
    AppSection.employees => const EmployeesView(),
    AppSection.salaries => const SalariesView(),
    AppSection.expenses => const ExpensesView(),
    AppSection.reports => const ReportsView(),
    AppSection.assistant => const AssistantView(),
    AppSection.profile => const ProfileView(),
    AppSection.settings => const SettingsView(),
  };

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeViewModel>();
    final brand = context.select<AuthViewModel, String>((a) => a.user?.businessName ?? 'Apex Suite');
    // Page switch: the new page fades in while rising 8px (old one fades out quickly).
    // Page switch: Material fade-through (package:animations) — the old page fades out
    // quickly, the new one fades in while settling from 0.92 scale. Reduced motion: instant.
    final page = PageTransitionSwitcher(
      duration: Motion.reduced(context) ? Duration.zero : const Duration(milliseconds: 300),
      transitionBuilder: (child, primary, secondary) => FadeThroughTransition(
        animation: primary,
        secondaryAnimation: secondary,
        fillColor: Colors.transparent,
        child: child,
      ),
      child: KeyedSubtree(key: ValueKey(home.section), child: _page(home.section)),
    );

    Widget wide(bool extended) => Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selected: home.section,
            onSelect: home.select,
            extended: extended && !home.sidebarCollapsed,
            brandName: brand,
            onToggle: extended ? home.toggleSidebar : null,
          ),
          Expanded(
            child: Column(
              children: [
                const AppTopBarView(),
                Expanded(child: page),
              ],
            ),
          ),
        ],
      ),
    );

    final layout = ResponsiveLayout(
      mobile: (_) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          scrolledUnderElevation: 0,
          titleSpacing: 16,
          title: Row(
            children: [
              const BrandMark(size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            const AppTopBarView(compact: true),
            Expanded(child: page),
          ],
        ),
        bottomNavigationBar: _MobileNavBar(section: home.section, onSelect: home.select),
      ),
      tablet: (_) => wide(false),
      desktop: (_) => wide(true),
    );

    // Voice pill floats over every page, just under the top edge.
    return Stack(
      children: [
        Positioned.fill(child: layout),
        const Positioned(
          left: 0,
          right: 0,
          top: 12,
          child: SafeArea(bottom: false, child: Center(child: VoiceStatusPill())),
        ),
      ],
    );
  }
}

class _MobileNavBar extends StatelessWidget {
  const _MobileNavBar({required this.section, required this.onSelect});

  final AppSection section;
  final ValueChanged<AppSection> onSelect;

  static const _moreIndex = 4;

  void _openMore(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final s in AppSection.values)
              if (!AppSection.mobileBar.contains(s))
                ListTile(
                  key: Key('more-${s.name}'),
                  leading: Icon(s == section ? s.selectedIcon : s.icon),
                  title: Text(context.l10n.section(s)),
                  selected: s == section,
                  selectedColor: AppColors.accentText,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    onSelect(s);
                  },
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final index = AppSection.mobileBar.indexOf(section);
    // A plain bar on the bottom edge with one hairline above it (no floating pill, no shadow).
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.zero,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.zero,
            child: NavigationBar(
              height: 66,
              selectedIndex: index < 0 ? _moreIndex : index,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (i) => i == _moreIndex ? _openMore(context) : onSelect(AppSection.mobileBar[i]),
              destinations: [
                for (final s in AppSection.mobileBar)
                  NavigationDestination(
                    icon: Icon(s.icon),
                    selectedIcon: Icon(s.selectedIcon),
                    label: s == AppSection.assistant ? tr.navAssistantShort : tr.section(s),
                  ),
                NavigationDestination(icon: Icon(Icons.more_horiz), label: tr.navMore),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
