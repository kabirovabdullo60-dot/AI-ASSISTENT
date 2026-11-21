import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../l10n/l10n.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/app_message_view.dart';
import '../widgets/ofar_logo.dart';
import 'auth_view.dart';
import 'shell_view.dart';

/// Splash while the saved session is checked, then the login screen or the
/// app. When the session ends (logout, expired), every opened screen is
/// closed and the login screen shows.
class SessionGateView extends StatefulWidget {
  const SessionGateView({super.key});

  @override
  State<SessionGateView> createState() => _SessionGateViewState();
}

class _SessionGateViewState extends State<SessionGateView> {
  SessionStatus? _previous;

  @override
  Widget build(BuildContext context) {
    final status = context.watch<SessionViewModel>().status;
    if (_previous == SessionStatus.signedIn &&
        status == SessionStatus.signedOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      });
    }
    _previous = status;
    return switch (status) {
      SessionStatus.unknown => Scaffold(
        backgroundColor: context.palette.surface,
        body: const Center(child: OfarLogo(size: 88)),
      ),
      SessionStatus.signedOut => const AuthView(),
      SessionStatus.offline => Scaffold(
        body: SafeArea(
          child: AppMessageView(
            icon: Icons.wifi_off_rounded,
            iconColor: context.palette.warning,
            iconBackground: context.palette.warningLight,
            title: context.l10n.sessionOfflineTitle,
            message: context.l10n.sessionOfflineMessage,
            actionLabel: context.l10n.commonRetry,
            onAction: context.read<SessionViewModel>().restore,
          ),
        ),
      ),
      SessionStatus.signedIn => const ShellView(),
    };
  }
}
