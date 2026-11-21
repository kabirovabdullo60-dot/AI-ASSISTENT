import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/auth_hero.dart';
import '../widgets/auth_mode_switch.dart';
import '../widgets/auth_sheet_layout.dart';
import '../widgets/jelly_blob.dart';
import '../widgets/look_at_pointer.dart';
import 'login_form_view.dart';
import 'register_form_view.dart';

/// Sign in and sign up on one page: a header with the jelly mascot and the
/// falling accountant's things, and a white sheet with the
/// "Регистрация | Вход" switch that swaps the form in place (no new page).
/// The header turns from lavender (sign in) to purple (sign up).
///
/// The mascot looks where the screen is pressed, follows the e-mail text
/// while signing in and closes its eyes while a password is typed.
class AuthView extends StatefulWidget {
  const AuthView({this.startWithRegister = false, super.key});

  /// Opens on the sign-up form instead of sign-in.
  final bool startWithRegister;

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  late bool _isLogin = !widget.startWithRegister;
  bool _passwordFocused = false;
  final _lookAt = ValueNotifier<Offset?>(null);

  @override
  void dispose() {
    _lookAt.dispose();
    super.dispose();
  }

  void _setMode({required bool login}) {
    if (login == _isLogin) return;
    FocusScope.of(context).unfocus();
    context.read<SessionViewModel>().clearError();
    setState(() {
      _isLogin = login;
      _passwordFocused = false;
    });
  }

  void _onPasswordFocus(bool focused) {
    if (mounted && focused != _passwordFocused) {
      setState(() => _passwordFocused = focused);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LookAtPointer(
      lookAt: _lookAt,
      child: AuthSheetLayout(
        title: _isLogin ? l10n.authLoginTitle : l10n.authRegisterTitle,
        subtitle: _isLogin ? null : l10n.authRegisterSubtitle,
        hero: AuthHero(
          light: _isLogin,
          child: JellyBlob(
            lookAt: _lookAt,
            eyesClosed: _passwordFocused,
            size: 150,
          ),
        ),
        top: AuthModeSwitch(
          isLogin: _isLogin,
          onRegister: () => _setMode(login: false),
          onLogin: () => _setMode(login: true),
        ),
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            layoutBuilder: (current, previous) => current ?? const SizedBox(),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _isLogin
                ? LoginFormView(
                    key: const ValueKey('login'),
                    lookAt: _lookAt,
                    onPasswordFocus: _onPasswordFocus,
                  )
                : RegisterFormView(
                    key: const ValueKey('register'),
                    onPasswordFocus: _onPasswordFocus,
                  ),
          ),
        ],
      ),
    );
  }
}
