import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../viewmodels/settings_view_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final TextEditingController _name = TextEditingController(
    text: context.read<SettingsViewModel>().businessName,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          key: const Key('settings-view'),
          padding: const EdgeInsets.all(16),
          children: [
            Text('Settings', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              key: const Key('business-name'),
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Business name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
              onChanged: vm.setBusinessName,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const Key('dark-mode'),
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark mode'),
              value: vm.isDark,
              onChanged: vm.setDark,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_outlined),
              title: const Text('Data source'),
              subtitle: Text(
                ApiConstants.useMock
                    ? 'Demo data — the backend is not connected yet'
                    : 'Backend: ${ApiConstants.baseUrl}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
