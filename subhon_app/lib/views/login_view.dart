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
import 'register_view.dart';

/// `POST /api/auth/login` (email + password).
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
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
    return AuthScaffold(
      title: l10n.authLoginTitle,
      subtitle: l10n.authLoginSubtitle,
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
                  controller: _email,
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
  }
}
