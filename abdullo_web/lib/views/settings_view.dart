import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../core/l10n/app_language.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_palette.dart';
import '../widgets/palette_swatch.dart';
import '../core/navigation/app_section.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/currency.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/dashboard_view_model.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../widgets/page_body.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<SettingsViewModel>();
    final business = context.select<AuthViewModel, String>((a) => a.user?.businessName ?? '');
    final online = context.select<DashboardViewModel, bool?>((d) => d.apiOnline);

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
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.storefront_outlined),
                        title: Text(tr.businessName),
                        subtitle: Text(business),
                        trailing: TextButton(
                          onPressed: () => context.read<HomeViewModel>().select(AppSection.profile),
                          child: Text(tr.edit),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(tr.currency, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                      const SizedBox(height: 16),
                      Text(tr.themeLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final p in AppPalette.values)
                            PaletteCard(palette: p, selected: vm.palette == p, onTap: () => vm.setPalette(p)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: tr.backendConnection,
                  badge: online == null
                      ? null
                      : StatusBadge(
                          online ? tr.apiOnline : tr.apiOffline,
                          tone: online ? BadgeTone.positive : BadgeTone.negative,
                          dot: true,
                        ),
                  subtitle: '${tr.apiServer}: ${ApiConstants.baseUrl}\n${tr.openDocs}: ${ApiConstants.docsUrl}',
                  child: Column(
                    children: [
                      for (final (method, path, purpose) in ApiConstants.endpointList)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 104,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: StatusBadge(
                                    method,
                                    tone: method == 'GET' ? BadgeTone.info : BadgeTone.warning,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(path, style: const TextStyle(fontSize: 12))),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  purpose,
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: AppColors.muted),
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
