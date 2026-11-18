import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/theme/app_theme.dart';
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
import '../widgets/jelly_blob.dart';
import '../widgets/look_at_pointer.dart';
import '../widgets/register_background.dart';

/// `POST /api/auth/register`: name, work e-mail and password (the API's
/// required fields). Phone and business name are optional in the API and
/// are filled in later in the profile; the business is named after the
/// owner until then.
///
/// A dark screen: the jelly mascot (looks where the screen is pressed,
/// closes its eyes while the password is typed) above the form.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();
  final _lookAt = ValueNotifier<Offset?>(null);

  @override
  void initState() {
    super.initState();
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _password]) {
      c.dispose();
    }
    _passwordFocus.dispose();
    _lookAt.dispose();
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
      ),
    );
    // Signed in: the app opens under this screen.
    if (ok && mounted) navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.dark,
    child: Builder(builder: _build),
  );

  Widget _build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.watch<SessionViewModel>();
    final busy = session.isSubmitting;
    const gap = SizedBox(height: AppSpacing.lg);
    final theme = Theme.of(context);
    // The button keeps the vivid brand purple with white text, as on the
    // design (the dark theme's accent is lighter, for text).
    final vivid = theme.copyWith(
      extensions: [
        context.palette.copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
        ),
      ],
    );
    return LookAtPointer(
      lookAt: _lookAt,
      child: AuthScaffold(
        background: const RegisterBackground(),
        title: l10n.authRegisterTitle,
        subtitle: l10n.authRegisterSubtitle,
        hero: JellyBlob(
          lookAt: _lookAt,
          eyesClosed: _passwordFocus.hasFocus,
          size: 150,
        ),
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
          Theme(
            data: vivid,
            child: AppButton(
              label: l10n.authCreateAccount,
              isLoading: busy,
              onPressed: _register,
            ),
          ),
        ],
      ),
    );
  }
}
