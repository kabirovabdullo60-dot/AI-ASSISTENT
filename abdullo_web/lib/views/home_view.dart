import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/home_view_model.dart';
import '../widgets/responsive_layout.dart';

class _Section {
  const _Section(this.label, this.icon);
  final String label;
  final IconData icon;
}

const _sections = [
  _Section('Home', Icons.home_outlined),
  _Section('Assistant', Icons.smart_toy_outlined),
  _Section('Reports', Icons.bar_chart_outlined),
  _Section('Settings', Icons.settings_outlined),
];

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final body = _HomeBody(vm: vm);

    return ResponsiveLayout(
      mobile: (_) => Scaffold(
        appBar: AppBar(title: const Text('AI Business Assistant')),
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: vm.selectedIndex,
          onDestinationSelected: vm.select,
          destinations: [
            for (final s in _sections)
              NavigationDestination(icon: Icon(s.icon), label: s.label),
          ],
        ),
      ),
      tablet: (_) => _WideScaffold(vm: vm, extended: false, body: body),
      desktop: (_) => _WideScaffold(vm: vm, extended: true, body: body),
    );
  }
}

class _WideScaffold extends StatelessWidget {
  const _WideScaffold({required this.vm, required this.extended, required this.body});

  final HomeViewModel vm;
  final bool extended;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Business Assistant — Web')),
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            labelType: extended ? null : NavigationRailLabelType.all,
            selectedIndex: vm.selectedIndex,
            onDestinationSelected: vm.select,
            destinations: [
              for (final s in _sections)
                NavigationRailDestination(icon: Icon(s.icon), label: Text(s.label)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.vm});

  final HomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading) return const Center(child: CircularProgressIndicator());
    return Center(
      child: Text(
        vm.error ?? _sections[vm.selectedIndex].label,
        key: const Key('home-title'),
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
