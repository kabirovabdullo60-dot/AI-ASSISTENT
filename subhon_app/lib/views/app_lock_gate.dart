import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/app_lock_view_model.dart';
import '../viewmodels/session_view_model.dart';
import 'lock_view.dart';

/// Covers the whole app (every open page) with [LockView] while the
/// biometric lock is on and the app is locked; locks again when the app
/// goes to the background.
class AppLockGate extends StatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> {
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onPause: () => context.read<AppLockViewModel>().lock(),
  );

  @override
  void initState() {
    super.initState();
    _lifecycle; // start listening
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signedIn =
        context.watch<SessionViewModel>().status == SessionStatus.signedIn;
    final locked = context.watch<AppLockViewModel>().locked;
    return Stack(
      children: [
        widget.child,
        if (signedIn && locked) const Positioned.fill(child: LockView()),
      ],
    );
  }
}
