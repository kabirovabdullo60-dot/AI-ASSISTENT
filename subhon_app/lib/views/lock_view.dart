import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';
import '../models/biometric_kind.dart';
import '../viewmodels/app_lock_view_model.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/jelly_blob.dart';

/// The app is locked: the jelly mascot with closed eyes, "Разблокировать"
/// (Face ID / fingerprint, asked at once when shown), or sign out.
class LockView extends StatefulWidget {
  const LockView({super.key});

  @override
  State<LockView> createState() => _LockViewState();
}

class _LockViewState extends State<LockView> {
  final _lookAt = ValueNotifier<Offset?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _unlock();
    });
  }

  @override
  void dispose() {
    _lookAt.dispose();
    super.dispose();
  }

  Future<void> _unlock() =>
      context.read<AppLockViewModel>().unlock(context.l10n.lockReasonOpen);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<AppLockViewModel>();
    return Scaffold(
      backgroundColor: p.surface,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            children: [
              const Spacer(),
              JellyBlob(lookAt: _lookAt, eyesClosed: true, size: 150),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.lockTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.lockMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.textSecondary,
                ),
              ),
              const Spacer(),
              AppButton(
                label: l10n.lockUnlock,
                icon: vm.kind == BiometricKind.face
                    ? Icons.face_retouching_natural
                    : Icons.fingerprint_rounded,
                isLoading: vm.isAuthenticating,
                onPressed: _unlock,
              ),
              TextButton(
                onPressed: vm.isAuthenticating
                    ? null
                    : () => context.read<SessionViewModel>().logout(),
                child: Text(l10n.authSignOut),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
