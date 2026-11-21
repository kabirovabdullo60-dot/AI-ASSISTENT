import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/app_language.dart';
import '../core/constants/brand.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../widgets/brand_mark.dart';
import '../widgets/motion/photo_slideshow.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const BrandMark(size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(AppBrand.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      DropdownButton<AppLanguage>(
                        key: const Key('login-language'),
                        value: settings.language,
                        underline: const SizedBox.shrink(),
                        items: [for (final l in AppLanguage.values) DropdownMenuItem(value: l, child: Text(l.short))],
                        onChanged: (l) => l == null ? null : settings.setLanguage(l),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Text(
                    _register ? tr.registerTitle : tr.loginTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.6,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _register ? tr.registerSubtitle : tr.loginSubtitle,
                    style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.45),
                  ),
                  const SizedBox(height: 28),
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
                    decoration: InputDecoration(labelText: tr.emailLabel, prefixIcon: const Icon(Icons.mail_outline)),
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
                        tooltip: _showPassword ? tr.hidePassword : tr.showPassword,
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
                      decoration: BoxDecoration(color: AppColors.redSoft, borderRadius: BorderRadius.circular(6)),
                      child: Text(_error!, style: TextStyle(color: AppColors.red)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    key: const Key('login-submit'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
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
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, c) => c.maxWidth < 900
            // Phones: the form on the page ground, nothing in front of it.
            ? SafeArea(child: form)
            : Row(
                children: [
                  const Expanded(flex: 11, child: _LoginHero()),
                  Expanded(flex: 9, child: form),
                ],
              ),
      ),
    );
  }
}

/// Left side of the wide login: one real photograph of a cosmetics shop, full height, shown as
/// it is. A neutral scrim sits only under the words at the bottom; the credit is set small.
class _LoginHero extends StatelessWidget {
  const _LoginHero();

  static const photo = 'assets/images/cosmetics_shop.jpg';

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    return Stack(
      fit: StackFit.expand,
      children: [
        const PhotoSlideshow(images: [photo], hold: Duration(seconds: 20), zoom: 0.04),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 360,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xB3000000)],
              ),
            ),
          ),
        ),
        Positioned(
          left: 48,
          right: 48,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  tr.loginHeadline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.9,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Text(
                  tr.loginHeroBody,
                  style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 28),
              const Text('Photo: Ela De Pure · Unsplash', style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
