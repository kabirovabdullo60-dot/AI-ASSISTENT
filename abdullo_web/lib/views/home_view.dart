import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/responsive_layout.dart';
import 'assistant_view.dart';
import 'dashboard_view.dart';
import 'reports_view.dart';
import 'settings_view.dart';

class _Section {
  const _Section(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _sections = [
  _Section('Dashboard', Icons.dashboard_outlined, Icons.dashboard),
  _Section('Assistant', Icons.smart_toy_outlined, Icons.smart_toy),
  _Section('Reports', Icons.bar_chart_outlined, Icons.bar_chart),
  _Section('Settings', Icons.settings_outlined, Icons.settings),
];

/// App shell: bottom bar on mobile, side rail on tablet/desktop.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  Widget _page(int index) => switch (index) {
    0 => const DashboardView(),
    1 => const AssistantView(),
    2 => const ReportsView(),
    _ => const SettingsView(),
  };

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final title = context.select<SettingsViewModel, String>((s) => s.businessName);
    final body = KeyedSubtree(key: ValueKey(vm.selectedIndex), child: _page(vm.selectedIndex));

    return ResponsiveLayout(
      mobile: (_) => Scaffold(
        appBar: AppBar(title: _AppTitle(title)),
        body: SafeArea(child: body),
        bottomNavigationBar: NavigationBar(
          selectedIndex: vm.selectedIndex,
          onDestinationSelected: vm.select,
          destinations: [
            for (final s in _sections)
              NavigationDestination(icon: Icon(s.icon), selectedIcon: Icon(s.selectedIcon), label: s.label),
          ],
        ),
      ),
      tablet: (_) => _WideScaffold(vm: vm, title: title, extended: false, body: body),
      desktop: (_) => _WideScaffold(vm: vm, title: title, extended: true, body: body),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle(this.businessName);

  final String businessName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(businessName, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _WideScaffold extends StatelessWidget {
  const _WideScaffold({required this.vm, required this.title, required this.extended, required this.body});

  final HomeViewModel vm;
  final String title;
  final bool extended;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: _AppTitle('$title · AI Business Assistant')),
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            labelType: extended ? null : NavigationRailLabelType.all,
            selectedIndex: vm.selectedIndex,
            onDestinationSelected: vm.select,
            destinations: [
              for (final s in _sections)
                NavigationRailDestination(
                  icon: Icon(s.icon),
                  selectedIcon: Icon(s.selectedIcon),
                  label: Text(s.label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
