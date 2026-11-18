import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../core/l10n/l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../models/profile_model.dart';
import '../viewmodels/auth_view_model.dart';
import '../widgets/page_body.dart';
import '../widgets/section_card.dart';
import '../widgets/status_badge.dart';

/// Profile — GET/PUT /api/profile, PATCH /api/profile/avatar, PATCH /api/profile/password.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final user = context.watch<AuthViewModel>().user;
    if (user == null) return const SizedBox.shrink();
    return PageBody(
      title: tr.navProfile,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                _Header(user: user),
                const SizedBox(height: 16),
                _EditCard(key: ValueKey('edit-${user.id}'), user: user),
                const SizedBox(height: 16),
                const _PasswordCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.user});

  final ProfileModel user;

  Future<void> _pickAvatar(BuildContext context) async {
    final tr = context.l10n;
    final auth = context.read<AuthViewModel>();
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (files.isEmpty) return;
    final file = files.first;
    final bytes = await file.readAsBytes();
    final error = await auth.uploadAvatar(bytes, file.name);
    if (context.mounted) showResult(context, error, success: tr.photoUpdated);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final avatar = user.avatar;
    final url = avatar == null ? null : (avatar.startsWith('http') ? avatar : '${ApiConstants.baseUrl}$avatar');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.orangeSoft,
                  foregroundImage: url == null ? null : NetworkImage(url),
                  child: Text(
                    initials(user.fullName),
                    style: const TextStyle(fontSize: 22, color: AppColors.orange, fontWeight: FontWeight.w700),
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: IconButton.filled(
                    key: const Key('change-photo'),
                    tooltip: tr.changePhoto,
                    iconSize: 14,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _pickAvatar(context),
                    icon: const Icon(Icons.photo_camera_outlined),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    key: const Key('profile-name'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(user.email, style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      StatusBadge(user.role, tone: BadgeTone.info),
                      StatusBadge(user.businessName, tone: BadgeTone.warning, icon: Icons.storefront_outlined),
                    ],
                  ),
                ],
              ),
            ),
            // Narrow phones: icon only, so long translations ("Баромадан") never overflow.
            if (MediaQuery.sizeOf(context).width < 480)
              IconButton.outlined(
                key: const Key('profile-logout'),
                tooltip: tr.signOut,
                onPressed: () => context.read<AuthViewModel>().logout(),
                icon: const Icon(Icons.logout, size: 18),
              )
            else
              OutlinedButton.icon(
                key: const Key('profile-logout'),
                onPressed: () => context.read<AuthViewModel>().logout(),
                icon: const Icon(Icons.logout, size: 18),
                label: Text(tr.signOut),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditCard extends StatefulWidget {
  const _EditCard({super.key, required this.user});

  final ProfileModel user;

  @override
  State<_EditCard> createState() => _EditCardState();
}

class _EditCardState extends State<_EditCard> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.fullName);
  late final _email = TextEditingController(text: widget.user.email);
  late final _phone = TextEditingController(text: widget.user.phone);
  late final _business = TextEditingController(text: widget.user.businessName);

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _business]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tr = context.l10n;
    final phone = _phone.text.replaceAll(RegExp(r'[\s\-()]'), '');
    final error = await context.read<AuthViewModel>().updateProfile(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      phone: phone.isEmpty ? null : phone,
      businessName: _business.text.trim(),
    );
    if (mounted) showResult(context, error, success: tr.profileSaved);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final busy = context.select<AuthViewModel, bool>((a) => a.isBusy);
    return SectionCard(
      title: tr.editProfile,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('profile-fullname'),
              controller: _name,
              decoration: InputDecoration(labelText: tr.fullName),
              validator: (v) => (v ?? '').trim().isEmpty ? tr.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(labelText: tr.emailLabel),
              validator: (v) => RegExp(r'^\S+@\S+\.\S+$').hasMatch((v ?? '').trim()) ? null : tr.invalidEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              decoration: InputDecoration(labelText: tr.phoneOptional, hintText: '+992901234567'),
              validator: (v) {
                final s = (v ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
                return s.isEmpty || RegExp(r'^\+?[0-9]{7,15}$').hasMatch(s) ? null : tr.invalidPhone;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('business-name'),
              controller: _business,
              decoration: InputDecoration(labelText: tr.businessName),
              validator: (v) => (v ?? '').trim().isEmpty ? tr.required : null,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                key: const Key('profile-save'),
                onPressed: busy ? null : _save,
                child: Text(tr.saveChanges),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordCard extends StatefulWidget {
  const _PasswordCard();

  @override
  State<_PasswordCard> createState() => _PasswordCardState();
}

class _PasswordCardState extends State<_PasswordCard> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final tr = context.l10n;
    final error = await context.read<AuthViewModel>().changePassword(_current.text, _next.text);
    if (!mounted) return;
    if (error == null) {
      _current.clear();
      _next.clear();
    }
    showResult(context, error, success: tr.passwordChanged);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.l10n;
    final busy = context.select<AuthViewModel, bool>((a) => a.isBusy);
    return SectionCard(
      title: tr.changePassword,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('current-password'),
              controller: _current,
              obscureText: true,
              decoration: InputDecoration(labelText: tr.currentPassword),
              validator: (v) => (v ?? '').isEmpty ? tr.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('new-password'),
              controller: _next,
              obscureText: true,
              decoration: InputDecoration(labelText: tr.newPassword),
              validator: (v) => (v ?? '').isEmpty ? tr.required : null,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                key: const Key('password-save'),
                onPressed: busy ? null : _save,
                child: Text(tr.changePassword),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
