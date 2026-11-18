import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/app_language.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../widgets/brand_mark.dart';
import '../widgets/pamir_ridge.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/settings_view_model.dart';

/// Sign in / create account (POST /api/auth/login, /api/auth/register).
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _business = TextEditingController();
  bool _register = false;
  bool _showPassword = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_email, _password, _fullName, _phone, _business]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthViewModel>();
    final code = _register
        ? await auth.register(
            fullName: _fullName.text,
            email: _email.text,
            password: _password.text,
            phone: _phone.text.replaceAll(RegExp(r'[\s\-()]'), ''),
            businessName: _business.text,
          )
        : await auth.login(_email.text, _password.text);
    if (mounted) setState(() => _error = code == null ? null : context.l10n.error(code));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final busy = context.select<AuthViewModel, bool>((a) => a.isBusy);
    final settings = context.watch<SettingsViewModel>();

    final form = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const BrandMark(size: 40),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text('Apex Suite', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                          ),
                          DropdownButton<AppLanguage>(
                            key: const Key('login-language'),
                            value: settings.language,
                            underline: const SizedBox.shrink(),
                            items: [
                              for (final l in AppLanguage.values) DropdownMenuItem(value: l, child: Text(l.short)),
                            ],
                            onChanged: (l) => l == null ? null : settings.setLanguage(l),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _register ? tr.registerTitle : tr.loginTitle,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _register ? tr.registerSubtitle : tr.loginSubtitle,
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 20),
                      if (_register) ...[
                        TextFormField(
                          key: const Key('register-name'),
                          controller: _fullName,
                          autofillHints: const [AutofillHints.name],
                          decoration: InputDecoration(labelText: tr.fullName),
                          validator: (v) => (v ?? '').trim().isEmpty ? tr.required : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        key: const Key('login-email'),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          labelText: tr.emailLabel,
                          prefixIcon: const Icon(Icons.mail_outline),
                        ),
                        validator: (v) => RegExp(r'^\S+@\S+\.\S+$').hasMatch((v ?? '').trim()) ? null : tr.invalidEmail,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('login-password'),
                        controller: _password,
                        obscureText: !_showPassword,
                        autofillHints: [_register ? AutofillHints.newPassword : AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: tr.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _showPassword = !_showPassword),
                            icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                          ),
                        ),
                        validator: (v) => (v ?? '').isEmpty ? tr.required : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (_register) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(labelText: tr.phoneOptional, hintText: '+992901234567'),
                          validator: (v) {
                            final s = (v ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
                            return s.isEmpty || RegExp(r'^\+?[0-9]{7,15}$').hasMatch(s) ? null : tr.invalidPhone;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('register-business'),
                          controller: _business,
                          decoration: InputDecoration(labelText: tr.businessNameOptional),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        Container(
                          key: const Key('login-error'),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(8)),
                          child: Text(_error!, style: TextStyle(color: AppColors.red)),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        key: const Key('login-submit'),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: busy ? null : _submit,
                        child: busy
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(_register ? tr.createAccount : tr.signIn),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        key: const Key('login-toggle'),
                        onPressed: () => setState(() {
                          _register = !_register;
                          _error = null;
                        }),
                        child: Text(_register ? tr.haveAccount : tr.noAccount),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) => c.maxWidth < 900
            ? form
            : Row(
                children: [
                  const Expanded(flex: 5, child: _LoginHero()),
                  Expanded(flex: 6, child: form),
                ],
              ),
      ),
    );
  }
}

/// Left half of the wide login: ink panel, brand, one plain promise, and the Pamir
/// ridgelines drawing themselves along the bottom.
class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    const soft = Color(0xFFB9C6D3); // secondary text tinted from the ink surface
    return Container(
      color: AppColors.navy,
      child: Stack(
        children: [
          const Positioned(left: 0, right: 0, bottom: 0, height: 260, child: PamirRidges(color: Colors.white)),
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 44, 48, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    BrandMark(size: 36),
                    SizedBox(width: 12),
                    Text(
                      'Apex Suite',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const Spacer(flex: 2),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Text(
                    tr.loginHeadline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      height: 1.12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Text(tr.loginHeroBody, style: const TextStyle(color: soft, fontSize: 16, height: 1.5)),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
