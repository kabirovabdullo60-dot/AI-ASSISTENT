import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../core/storage/debt_storage.dart';
import '../core/storage/personal_finance_storage.dart';
import '../models/backup_model.dart';
import '../services/file_pick_service.dart';
import '../services/file_share_service.dart';

/// Saving everything kept only on the phone to a file, and bringing it
/// back (on a new phone, after reinstalling).
class BackupViewModel extends ChangeNotifier {
  BackupViewModel(
    this._personal,
    this._debts,
    this._share,
    this._pick,
    this._userId, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final PersonalFinanceStorage _personal;
  final DebtStorage _debts;
  final FileShareService _share;
  final FilePickService _pick;
  final String? _userId;
  final DateTime Function() _clock;

  bool _busy = false;
  bool _badFile = false;

  bool get isBusy => _busy;

  /// The last picked file wasn't a backup of this app.
  bool get badFile => _badFile;

  /// The backup file goes to the share sheet (Files, Telegram, e-mail).
  Future<void> export() async {
    final user = _userId;
    if (user == null || _busy) return;
    _set(busy: true);
    try {
      final now = _clock();
      final backup = BackupModel(
        personal: await _personal.read(user),
        debts: await _debts.read(user),
        createdAt: now,
      );
      final day =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      await _share.share(
        bytes: Uint8List.fromList(utf8.encode(jsonEncode(backup.toJson()))),
        fileName: 'ai-accountant-backup-$day.json',
        mimeType: 'application/json',
      );
    } finally {
      _set(busy: false);
    }
  }

  /// Picks a backup file; `null` when cancelled or not a backup
  /// ([badFile]).
  Future<BackupModel?> pick() async {
    _set(bad: false);
    final bytes = await _pick.pickJson();
    if (bytes == null) return null;
    try {
      return BackupModel.fromJson(
        jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
      );
    } on Object {
      _set(bad: true);
      return null;
    }
  }

  /// Replaces what is on the phone with [backup].
  Future<void> restore(BackupModel backup) async {
    final user = _userId;
    if (user == null) return;
    _set(busy: true);
    try {
      await _personal.write(user, backup.personal);
      await _debts.write(user, backup.debts);
    } finally {
      _set(busy: false);
    }
  }

  void _set({bool? busy, bool? bad}) {
    _busy = busy ?? _busy;
    _badFile = bad ?? _badFile;
    notifyListeners();
  }
}
