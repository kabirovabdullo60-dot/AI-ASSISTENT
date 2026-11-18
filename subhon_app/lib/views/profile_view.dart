import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../l10n/validators.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../viewmodels/locale_view_model.dart';
import '../viewmodels/profile_view_model.dart';
import '../viewmodels/session_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_feedback.dart';
import '../widgets/app_inline_message.dart';
import '../widgets/app_text_field.dart';
import '../widgets/async_state_view.dart';
import '../widgets/options_sheet.dart';
import '../widgets/section_header.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_row.dart';
import 'change_password_view.dart';

/// Profile and settings: `GET/PUT /api/profile`, the avatar
/// (`PATCH /api/profile/avatar`, field `file`), language, password.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) =>
        ProfileViewModel(context.read<ProfileService>())..load(),
    child: const _Profile(),
  );
}

class _Profile extends StatelessWidget {
  const _Profile();

  Future<void> _changeAvatar(BuildContext context) async {
    final l10n = context.l10n;
    final vm = context.read<ProfileViewModel>();
    final session = context.read<SessionViewModel>();
    final feedback = AppSnackbar.of(context);
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null) return;
    final updated = await vm.uploadAvatar(await file.readAsBytes(), file.name);
    if (updated != null) {
      session.updateUser(updated);
      feedback.showSuccess(l10n.profileAvatarSaved);
    } else if (vm.saveError != null) {
      feedback.showError(errorText(l10n, vm.saveError!));
    }
  }

  Future<void> _edit(BuildContext context, ProfileModel profile) async {
    final l10n = context.l10n;
    final vm = context.read<ProfileViewModel>();
    final session = context.read<SessionViewModel>();
    final feedback = AppSnackbar.of(context);
    final saved = await showAppBottomSheet<ProfileModel>(
      context,
      title: l10n.profileEdit,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: _EditSheet(profile: profile),
      ),
    );
    if (saved != null) {
      session.updateUser(saved);
      feedback.showSuccess(l10n.profileSaved);
    }
  }

  Future<void> _language(BuildContext context) async {
    final l10n = context.l10n;
    final language = context.read<LocaleViewModel>();
    final picked = await showOptionsSheet<String>(
      context,
      title: l10n.profileLanguage,
      selected: language.code ?? '',
      options: [
        ('', l10n.profileLanguageSystem),
        ('en', 'English'),
        ('ru', 'Русский'),
        ('tg', 'Тоҷикӣ'),
      ],
    );
    if (picked != null) await language.select(picked.isEmpty ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final p = context.palette;
    final vm = context.watch<ProfileViewModel>();
    final language = context.watch<LocaleViewModel>().code;
    String orNotSet(String? v) =>
        v == null || v.isEmpty ? l10n.profileNotSet : v;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: RefreshIndicator(
        onRefresh: vm.load,
        child: AsyncStateView(
          isLoading: vm.isLoading,
          error: vm.error,
          hasData: vm.hasData,
          onRetry: vm.load,
          builder: (context) {
            final profile = vm.profile!;
            final avatar = profile.avatar;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.xxxl,
              ),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: p.primaryLight,
                        foregroundImage: avatar == null
                            ? null
                            : NetworkImage(avatar),
                        child: Text(
                          profile.fullName.characters.firstOrNull ?? '',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: p.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.fullName,
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              profile.email,
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: vm.isSaving
                                  ? null
                                  : () => _changeAvatar(context),
                              child: Text(l10n.profileChangePhoto),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.profileEdit,
                        onPressed: () => _edit(context, profile),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(title: l10n.profileDetails),
                SettingsCard(
                  children: [
                    SettingsRow(
                      icon: Icons.storefront_outlined,
                      title: l10n.fieldBusinessName,
                      value: profile.business.name,
                      onTap: () => _edit(context, profile),
                    ),
                    SettingsRow(
                      icon: Icons.phone_outlined,
                      title: l10n.fieldPhone,
                      value: orNotSet(profile.phone),
                      onTap: () => _edit(context, profile),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(title: l10n.profileSettings),
                SettingsCard(
                  children: [
                    SettingsRow(
                      icon: Icons.payments_outlined,
                      title: l10n.profileCurrency,
                      value: 'TJS',
                    ),
                    SettingsRow(
                      icon: Icons.translate_rounded,
                      title: l10n.profileLanguage,
                      value: switch (language) {
                        'en' => 'English',
                        'ru' => 'Русский',
                        'tg' => 'Тоҷикӣ',
                        _ => l10n.profileLanguageSystem,
                      },
                      onTap: () => _language(context),
                    ),
                    SettingsRow(
                      icon: Icons.password_rounded,
                      title: l10n.passwordTitle,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ChangePasswordView(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Name, e-mail, phone and business name (`PUT /api/profile`).
class _EditSheet extends StatefulWidget {
  const _EditSheet({required this.profile});

  final ProfileModel profile;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.fullName);
  late final _email = TextEditingController(text: widget.profile.email);
  late final _phone = TextEditingController(text: widget.profile.phone);
  late final _business = TextEditingController(
    text: widget.profile.business.name,
  );

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _business]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(ProfileViewModel vm) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final navigator = Navigator.of(context);
    final saved = await vm.update(
      fullName: _name.text,
      email: _email.text,
      phone: _phone.text,
      businessName: _business.text,
    );
    if (saved != null) navigator.pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<ProfileViewModel>();
    const gap = SizedBox(height: AppSpacing.lg);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _name,
              label: l10n.fieldFullName,
              validator: (v) => Validators.required(v, l10n),
            ),
            gap,
            AppTextField(
              controller: _email,
              label: l10n.fieldEmail,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => Validators.email(v, l10n),
            ),
            gap,
            AppTextField(
              controller: _phone,
              label: l10n.fieldPhone,
              hint: l10n.fieldPhoneHint,
              keyboardType: TextInputType.phone,
              validator: (v) => Validators.phone(v, l10n),
            ),
            gap,
            AppTextField(
              controller: _business,
              label: l10n.fieldBusinessName,
              validator: (v) => Validators.required(v, l10n),
            ),
            if (vm.saveError != null) ...[
              gap,
              AppInlineMessage(
                type: InlineMessageType.error,
                message: errorText(l10n, vm.saveError!),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.commonSave,
              isLoading: vm.isSaving,
              onPressed: () => _save(vm),
            ),
          ],
        ),
      ),
    );
  }
}
