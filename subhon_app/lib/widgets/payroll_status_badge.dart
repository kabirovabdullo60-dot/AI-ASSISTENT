import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/l10n.dart';
import '../models/payroll_status.dart';
import 'status_badge.dart';

/// Выплачено · Частично · Не выплачено.
class PayrollStatusBadge extends StatelessWidget {
  const PayrollStatusBadge({required this.status, super.key});

  final PayrollStatus status;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final l10n = context.l10n;
    final (label, color, background) = switch (status) {
      PayrollStatus.paid => (l10n.payrollPaid, p.success, p.successLight),
      PayrollStatus.partial => (
        l10n.payrollPartial,
        p.warningText,
        p.warningLight,
      ),
      PayrollStatus.unpaid => (l10n.payrollUnpaid, p.error, p.errorLight),
    };
    return StatusBadge(label: label, color: color, background: background);
  }
}
