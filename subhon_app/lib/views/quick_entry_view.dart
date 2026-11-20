import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_dimensions.dart';
import '../core/utils/quick_entry_parser.dart';
import '../l10n/l10n.dart';
import '../l10n/money_text.dart';
import '../models/money_transaction_kind.dart';
import '../models/quick_entry_model.dart';
import '../services/voice_service.dart';
import '../viewmodels/personal_finance_view_model.dart';
import '../widgets/app_button.dart';
import '../widgets/app_feedback.dart';
import 'money_transaction_form_view.dart';

/// "Быстрая запись": say or type "такси 50" and the operation is
/// understood (amount, income or expense, category, account) — write it
/// at once or open it in the form to change something.
class QuickEntryView extends StatefulWidget {
  const QuickEntryView({this.listenAtStart = false, super.key});

  /// Start the microphone right away (opened from the mic button).
  final bool listenAtStart;

  @override
  State<QuickEntryView> createState() => _QuickEntryViewState();
}

class _QuickEntryViewState extends State<QuickEntryView> {
  final _text = TextEditingController();
  bool _listening = false;
  QuickEntryModel? _entry;

  @override
  void initState() {
    super.initState();
    _text.addListener(_parse);
    if (widget.listenAtStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _listen());
    }
  }

  @override
  void dispose() {
    if (_listening) _voice?.stopListening();
    _text.dispose();
    super.dispose();
  }

  VoiceService? get _voice {
    try {
      return context.read<VoiceService>();
    } on ProviderNotFoundException {
      return null;
    }
  }

  void _parse() {
    final vm = context.read<PersonalFinanceViewModel>();
    setState(() => _entry = QuickEntryParser.parse(_text.text, vm.accounts));
  }

  Future<void> _listen() async {
    final voice = _voice;
    if (voice == null || !mounted) return;
    if (_listening) {
      await voice.stopListening();
      setState(() => _listening = false);
      return;
    }
    final feedback = AppSnackbar.of(context);
    final failed = context.l10n.qeMicFailed;
    final language = Localizations.localeOf(context).languageCode;
    setState(() => _listening = true);
    final ok = await voice.listen(
      language: language,
      onWords: (words, done) {
        if (!mounted) return;
        _text.text = words;
        if (done) setState(() => _listening = false);
      },
      onStop: (didFail) {
        if (!mounted) return;
        setState(() => _listening = false);
        if (didFail) feedback.showError(failed);
      },
    );
    if (!ok && mounted) {
      setState(() => _listening = false);
      feedback.showError(failed);
    }
  }

  Future<void> _write() async {
    final entry = _entry;
    final vm = context.read<PersonalFinanceViewModel>();
    final account = entry?.accountId ?? vm.accounts.firstOrNull?.id;
    if (entry == null || !entry.isComplete || account == null) return;
    final navigator = Navigator.of(context);
    final feedback = AppSnackbar.of(context);
    final saved = context.l10n.pfSaved;
    await vm.addTransaction(
      kind: entry.kind,
      amount: entry.amount!,
      accountId: account,
      category: entry.category,
      note: entry.note,
    );
    feedback.showSuccess(saved);
    navigator.pop();
  }

  Future<void> _edit() async {
    final vm = context.read<PersonalFinanceViewModel>();
    final navigator = Navigator.of(context);
    await navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: MoneyTransactionFormView(draft: _entry),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final theme = Theme.of(context);
    final vm = context.watch<PersonalFinanceViewModel>();
    final entry = _entry;
    final account = vm.account(entry?.accountId ?? vm.accounts.firstOrNull?.id);
    final income = entry?.kind == MoneyTransactionKind.income;
    final color = income ? p.success : p.error;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.qeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          Text(l10n.qeHelp, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _text,
            autofocus: !widget.listenAtStart,
            textCapitalization: TextCapitalization.sentences,
            style: theme.textTheme.titleMedium,
            decoration: InputDecoration(
              hintText: _listening ? l10n.qeListening : l10n.qeHint,
              suffixIcon: _voice == null
                  ? null
                  : IconButton(
                      tooltip: l10n.qeSpeak,
                      onPressed: _listen,
                      icon: Icon(
                        _listening
                            ? Icons.stop_circle_rounded
                            : Icons.mic_rounded,
                        color: _listening ? p.error : p.primary,
                      ),
                    ),
            ),
            onSubmitted: (_) => _write(),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entry != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: AppRadius.lgAll,
                border: Border.all(color: p.border),
              ),
              child: entry.amount == null
                  ? Text(
                      l10n.qeNoAmount,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: p.error,
                      ),
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(
                            entry.category == null
                                ? Icons.help_outline_rounded
                                : moneyCategoryIcon(entry.category!),
                            color: color,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.category == null
                                    ? l10n.qeNoCategory
                                    : moneyCategoryText(l10n, entry.category!),
                                style: theme.textTheme.titleSmall,
                              ),
                              Text(
                                '${income ? l10n.pfIncome : l10n.pfExpense}'
                                ' · ${account?.name ?? ''}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          context.money(
                            income ? entry.amount! : -entry.amount!,
                            signed: true,
                            currency: account?.currency ?? 'TJS',
                          ),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: income ? p.success : p.textPrimary,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.qeWrite,
              icon: Icons.check_rounded,
              onPressed: entry.isComplete ? _write : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.qeEdit,
              variant: AppButtonVariant.secondary,
              onPressed: _edit,
            ),
          ],
        ],
      ),
    );
  }
}
