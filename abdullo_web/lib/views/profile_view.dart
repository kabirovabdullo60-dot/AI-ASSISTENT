import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../viewmodels/profile_view_model.dart';
import '../widgets/async_content.dart';
import '../widgets/page_body.dart';
import '../widgets/status_badge.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final vm = context.watch<ProfileViewModel>();
    return AsyncContent(
      hasData: vm.profile != null,
      error: vm.error,
      onRetry: vm.load,
      builder: (_) {
        final p = vm.profile!;
        return PageBody(
          title: tr.navProfile,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.orangeSoft,
                              child: Text(
                                initials(p.name),
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    key: const Key('profile-name'),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  StatusBadge(p.role, tone: BadgeTone.info),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.mail_outline),
                          title: Text(tr.email),
                          subtitle: Text(p.email),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.phone_outlined),
                          title: Text(tr.phone),
                          subtitle: Text(p.phone),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(onPressed: null, child: Text(tr.signOut)),
                        const SizedBox(height: 6),
                        Text(tr.signOutNote, style: TextStyle(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
