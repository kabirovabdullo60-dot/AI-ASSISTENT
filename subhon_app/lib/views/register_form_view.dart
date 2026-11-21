import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../models/register_request_model.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/app_text_field.dart';

/// The sign-up form of [AuthView]: `POST /api/auth/register` with name,
/// work e-mail and password (the API's required fields). Phone and
/// business name are optional in the API and are filled in later in the
/// profile; the business is named after the owner until then.
///
/// After a successful sign-up the session opens the app by itself.
/// [onPasswordFocus] tells the page when the password field is focused.
class RegisterFormView extends StatefulWidget {
  const RegisterFormView({required this.onPasswordFocus, super.key});

  final ValueChanged<bool> onPasswordFocus;

  @override
  State<RegisterFormView> createState() => _RegisterFormViewState();
}

class _RegisterFormViewState extends State<RegisterFormView> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _passwordFocus.addListener(
      () => widget.onPasswordFocus(_passwordFocus.hasFocus),
    );
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _password]) {
      c.dispose();
    }
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await context.read<SessionViewModel>().register(
      RegisterRequestModel(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.watch<SessionViewModel>();
    final busy = session.isSubmitting;
    const gap = SizedBox(height: AppSpacing.lg);
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
                  controller: _name,
                  compact: true,
                  label: l10n.fieldFullName,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  enabled: !busy,
                  validator: (v) => Validators.required(v, l10n),
                ),
                gap,
                AppTextField(
                  controller: _email,
                  compact: true,
                  label: l10n.fieldWorkEmail,
                  hint: l10n.fieldEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  enabled: !busy,
                  validator: (v) => Validators.email(v, l10n),
                ),
                gap,
                AppTextField(
                  controller: _password,
                  focusNode: _passwordFocus,
                  compact: true,
                  label: l10n.authPasswordLabel,
                  hint: l10n.authPasswordMinHint,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  enabled: !busy,
                  validator: (v) => Validators.newPassword(v, l10n),
                  onSubmitted: (_) => _register(),
                ),
              ],
            ),
          ),
        ),
        gap,
        if (session.error != null) ...[
          AppInlineMessage(
            type: InlineMessageType.error,
            message: errorText(l10n, session.error!),
          ),
          gap,
        ],
        AppButton(
          label: l10n.authCreateAccount,
          isLoading: busy,
          onPressed: _register,
        ),
      ],
    );
  }
}
