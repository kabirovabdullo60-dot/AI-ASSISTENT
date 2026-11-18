import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_dimensions.dart';
import '../core/utils/phone.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../models/register_request_model.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_scaffold.dart';

/// `POST /api/auth/register`: the owner and the new business.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _business = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _business, _email, _phone, _password, _repeat]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final navigator = Navigator.of(context);
    final ok = await context.read<SessionViewModel>().register(
      RegisterRequestModel(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        phone: _phone.text.trim().isEmpty ? null : normalizePhone(_phone.text),
        businessName: _business.text.trim().isEmpty
            ? null
            : _business.text.trim(),
      ),
    );
    // Signed in: the app opens under this screen.
    if (ok && mounted) navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.watch<SessionViewModel>();
    final busy = session.isSubmitting;
    String? required(String? v) => Validators.required(v, l10n);
    const gap = SizedBox(height: AppSpacing.lg);
    return AuthScaffold(
      title: l10n.authRegisterTitle,
      subtitle: l10n.authRegisterSubtitle,
      footer: AuthFooterLink(
        question: l10n.authHaveAccount,
        action: l10n.authSignInButton,
        onPressed: () {
          session.clearError();
          Navigator.of(context).pop();
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
                  controller: _name,
                  label: l10n.fieldFullName,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  enabled: !busy,
                  validator: required,
                ),
                gap,
                AppTextField(
                  controller: _business,
                  label: l10n.fieldBusinessName,
                  hint: l10n.fieldOptional,
                  textInputAction: TextInputAction.next,
                  enabled: !busy,
                ),
                gap,
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
                gap,
                AppTextField(
                  controller: _phone,
                  label: l10n.fieldPhone,
                  hint: l10n.fieldPhoneHint,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  enabled: !busy,
                  validator: (v) => Validators.phone(v, l10n),
                ),
                gap,
                AppTextField(
                  controller: _password,
                  label: l10n.authPasswordLabel,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  enabled: !busy,
                  validator: required,
                ),
                gap,
                AppTextField(
                  controller: _repeat,
                  label: l10n.authPasswordRepeat,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  enabled: !busy,
                  validator: (v) => v != _password.text
                      ? l10n.validationPasswordsDiffer
                      : null,
                  onSubmitted: (_) => _register(),
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
          label: l10n.authCreateAccount,
          isLoading: busy,
          onPressed: _register,
        ),
      ],
    );
  }
}
