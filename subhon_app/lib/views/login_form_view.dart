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

/// The sign-in form of [AuthView]: `POST /api/auth/login` (email +
/// password).
///
/// While the e-mail is typed the mascot looks at the end of the text
/// ([lookAt]); [onPasswordFocus] tells the page when the password field is
/// focused, so the mascot closes its eyes.
class LoginFormView extends StatefulWidget {
  const LoginFormView({
    required this.lookAt,
    required this.onPasswordFocus,
    super.key,
  });

  final ValueNotifier<Offset?> lookAt;
  final ValueChanged<bool> onPasswordFocus;

  @override
  State<LoginFormView> createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<LoginFormView> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _emailKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _email.addListener(_lookAtEmailText);
    _emailFocus.addListener(_lookAtEmailText);
    _passwordFocus.addListener(
      () => widget.onPasswordFocus(_passwordFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
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
    widget.lookAt.value = box.localToGlobal(Offset(x, box.size.height - 22));
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        if (session.sessionTooOld && session.error == null) ...[
          AppInlineMessage(
            type: InlineMessageType.info,
            message: l10n.sessionTooOld,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
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
  }
}
