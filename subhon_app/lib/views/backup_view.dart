import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/storage/debt_storage.dart';
import '../core/storage/personal_finance_storage.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../services/file_pick_service.dart';
import '../services/file_share_service.dart';
import '../viewmodels/backup_view_model.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';

/// "Резервная копия": save what is kept only on the phone to a file, or
/// bring it back from one. [onRestored]: the screens reload it.
class BackupView extends StatelessWidget {
  const BackupView({required this.onRestored, super.key});

  final VoidCallback onRestored;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (c) => BackupViewModel(
      c.read<PersonalFinanceStorage>(),
      c.read<DebtStorage>(),
      c.read<FileShareService>(),
      c.read<FilePickService>(),
      c.read<SessionViewModel>().user?.id,
    ),
    child: _Backup(onRestored: onRestored),
  );
}

class _Backup extends StatelessWidget {
  const _Backup({required this.onRestored});

  final VoidCallback onRestored;

  Future<void> _restore(BuildContext context) async {
    final vm = context.read<BackupViewModel>();
    final l10n = context.l10n;
    final feedback = AppSnackbar.of(context);
    final backup = await vm.pick();
    if (backup == null) {
      if (vm.badFile) feedback.showError(l10n.bkBadFile);
      return;
    }
    if (!context.mounted) return;
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.bkConfirmTitle,
      message: l10n.bkConfirmMessage(
        context.formatDate(backup.createdAt),
        backup.personal.accounts.length,
        backup.personal.transactions.length,
        backup.debts.length,
      ),
      confirmLabel: l10n.bkRestoreAction,
    );
    if (!confirmed) return;
    await vm.restore(backup);
    onRestored();
    feedback.showSuccess(l10n.bkRestored);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<BackupViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bkTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Icon(Icons.cloud_upload_outlined, size: 56, color: p.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.bkAbout,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.bkSave,
            icon: Icons.save_alt_rounded,
            onPressed: vm.isBusy ? null : vm.export,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.bkRestore,
            icon: Icons.restore_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: vm.isBusy ? null : () => _restore(context),
          ),
        ],
      ),
    );
  }
}
