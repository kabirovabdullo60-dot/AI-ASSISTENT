import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/constants/api_constants.dart';
import '../core/l10n/app_language.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/page_body.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final TextEditingController _name = TextEditingController(text: context.read<SettingsViewModel>().businessName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<SettingsViewModel>();

    return PageBody(
      title: tr.navSettings,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionCard(
                  title: tr.business,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        key: const Key('business-name'),
                        controller: _name,
                        decoration: InputDecoration(
                          labelText: tr.businessName,
                          prefixIcon: Icon(Icons.storefront_outlined),
                        ),
                        onChanged: vm.setBusinessName,
                      ),
                      const SizedBox(height: 16),
                      Text(tr.currency, style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SegmentedButton<Currency>(
                        key: const Key('settings-currency'),
                        showSelectedIcon: false,
                        segments: [for (final c in Currency.values) ButtonSegment(value: c, label: Text(c.label))],
                        selected: {vm.currency},
                        onSelectionChanged: (s) => vm.setCurrency(s.first),
                      ),
                      const SizedBox(height: 16),
                      Text(tr.language, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SegmentedButton<AppLanguage>(
                        key: const Key('settings-language'),
                        showSelectedIcon: false,
                        segments: [
                          for (final l in AppLanguage.values) ButtonSegment(value: l, label: Text(l.nativeName)),
                        ],
                        selected: {vm.language},
                        onSelectionChanged: (s) => vm.setLanguage(s.first),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: tr.backendConnection,
                  badge: ApiConstants.useMock
                      ? StatusBadge(tr.demoData, tone: BadgeTone.warning, dot: true)
                      : const StatusBadge('API', tone: BadgeTone.positive, dot: true),
                  subtitle: ApiConstants.useMock ? tr.demoNote : ApiConstants.baseUrl,
                  child: Column(
                    children: [
                      for (final (method, path, purpose) in ApiConstants.endpointList)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 52,
                                child: StatusBadge(method, tone: method == 'GET' ? BadgeTone.info : BadgeTone.warning),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  path,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  purpose,
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
