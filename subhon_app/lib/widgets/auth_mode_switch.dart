import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../l10n/l10n.dart';

/// The "Регистрация | Вход" switch at the top of the auth sheets. The
/// current screen's tab is raised; tapping the other one calls
/// [onRegister] or [onLogin].
class AuthModeSwitch extends StatelessWidget {
  const AuthModeSwitch({
    required this.isLogin,
    this.onRegister,
    this.onLogin,
    super.key,
  });

  final bool isLogin;
  final VoidCallback? onRegister;
  final VoidCallback? onLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final style = Theme.of(context).textTheme.labelLarge;
    Widget tab(String label, {required bool selected, VoidCallback? onTap}) =>
        Expanded(
          child: Semantics(
            button: true,
            selected: selected,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: selected ? null : onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? p.surface : Colors.transparent,
                  borderRadius: AppRadius.smAll,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: p.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  style: style?.copyWith(
                    color: selected ? p.textPrimary : p.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: p.surfaceMuted,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        children: [
          tab(l10n.authRegisterTab, selected: !isLogin, onTap: onRegister),
          tab(l10n.authLoginTitle, selected: isLogin, onTap: onLogin),
        ],
      ),
    );
  }
}
