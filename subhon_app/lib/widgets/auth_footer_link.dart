import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    required this.question,
    required this.action,
    required this.onPressed,
    super.key,
  });

  final String question;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        question,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: context.palette.textSecondary),
      ),
      TextButton(onPressed: onPressed, child: Text(action)),
    ],
  );
}
