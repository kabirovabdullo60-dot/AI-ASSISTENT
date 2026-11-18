import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/jelly_blob.dart';
import 'register_view.dart';

/// `POST /api/auth/login` (email + password).
///
/// A jelly mascot sits on top. Its eyes look where the screen is pressed
/// (finger or mouse click) and, a moment after it is released, look
/// straight ahead again. They follow
/// the text while the e-mail is typed and close while the password is.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _emailKey = GlobalKey();

  /// Where the mascot looks, in global coordinates.
  final _lookAt = ValueNotifier<Offset?>(null);

  /// After a touch ends, the eyes go back to looking around.
  Timer? _release;
  static const _releaseAfter = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _email.addListener(_lookAtEmailText);
    _emailFocus.addListener(_lookAtEmailText);
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _lookAt.dispose();
    _release?.cancel();
    super.dispose();
  }

  void _lookAtPointer(PointerEvent event) {
    _release?.cancel();
    _lookAt.value = event.position;
  }

  /// Released: keep looking there for a moment, then look ahead.
  void _touchEnded(PointerEvent event) {
    _release?.cancel();
    _release = Timer(_releaseAfter, () {
      if (mounted && !_emailFocus.hasFocus) _lookAt.value = null;
    });
  }

  /// While the e-mail is typed, look at the end of the text.
  void _lookAtEmailText() {
    if (!_emailFocus.hasFocus) return;
    final box = _emailKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final text = TextPainter(
      text: TextSpan(
        text: _email.text,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    const padding = AppSpacing.lg;
    final x = (padding + text.width).clamp(padding, box.size.width - padding);
    // The field is the lower part of the box (the label is above it).
    _lookAt.value = box.localToGlobal(Offset(x, box.size.height - 22));
    text.dispose();
  }

  Future<void> _signIn() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await context.read<SessionViewModel>().login(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.watch<SessionViewModel>();
    final busy = session.isSubmitting;
    final scaffold = AuthScaffold(
      title: l10n.authLoginTitle,
      hero: JellyBlob(lookAt: _lookAt, eyesClosed: _passwordFocus.hasFocus),
      footer: AuthFooterLink(
        question: l10n.authNoAccount,
        action: l10n.authCreateAccount,
        onPressed: () {
          session.clearError();
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const RegisterView()));
        },
      ),
      children: [
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  key: _emailKey,
                  controller: _email,
                  focusNode: _emailFocus,
                  compact: true,
                  label: l10n.fieldEmail,
                  hint: l10n.fieldEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  enabled: !busy,
                  validator: (v) => Validators.email(v, l10n),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  controller: _password,
                  focusNode: _passwordFocus,
                  compact: true,
                  label: l10n.authPasswordLabel,
                  hint: l10n.authPasswordHint,
                  obscureText: true,
                  enabled: !busy,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: (v) => Validators.required(v, l10n),
                  onSubmitted: (_) => _signIn(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (session.error != null) ...[
          AppInlineMessage(
            type: InlineMessageType.error,
            message: errorText(l10n, session.error!),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        AppButton(
          label: l10n.authSignInButton,
          isLoading: busy,
          onPressed: _signIn,
        ),
      ],
    );
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _lookAtPointer,
      onPointerMove: _lookAtPointer,
      onPointerUp: _touchEnded,
      onPointerCancel: _touchEnded,
      child: scaffold,
    );
  }
}
