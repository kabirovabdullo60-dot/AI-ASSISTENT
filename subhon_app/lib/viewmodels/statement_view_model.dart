import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/storage/statement_history_storage.dart';
import '../core/utils/local_date.dart';
import '../models/statement_kind.dart';
import '../models/statement_model.dart';
import '../models/statement_request_model.dart';
import '../models/store_model.dart';
import '../services/file_share_service.dart';
import '../services/statement_service.dart';
import '../services/store_service.dart';
import 'statement_period.dart';

/// One statement or certificate: its period (and store), the lines and
/// totals, saved to "Мои выписки" when shown, and exported to Excel.
class StatementViewModel extends ChangeNotifier {
  StatementViewModel(
    this._service,
    this._stores,
    this._share, {
    required this.kind,
    this.history,
    this.userId,
    StatementRequestModel? initial,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    if (initial != null) {
      _period = StatementPeriod.custom;
      _start = initial.startDate;
      _end = initial.endDate;
      _storeId = initial.storeId;
      _storeName = initial.storeName;
    } else {
      _setPeriod(StatementPeriod.month);
    }
  }

  final StatementService _service;
  final StoreService _stores;
  final FileShareService _share;
  final StatementKind kind;
  final StatementHistoryStorage? history;
  final String? userId;
  final DateTime Function() _clock;

  StatementPeriod _period = StatementPeriod.month;
  DateTime? _start;
  DateTime? _end;
  String? _storeId;
  String? _storeName;
  List<StoreModel> _storeList = const [];
  StatementModel? _statement;
  bool _isLoading = false;
  bool _isExporting = false;
  Object? _error;

  StatementPeriod get period => _period;
  DateTime? get startDate => _start;
  DateTime? get endDate => _end;
  String? get storeId => _storeId;
  String? get storeName => _storeName;
  List<StoreModel> get stores => _storeList;
  StatementModel? get statement => _statement;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;
  Object? get error => _error;

  /// The store statement waits for a store.
  bool get needsStoreChoice => kind.needsStore && _storeId == null;

  DateTime get _today {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  void _setPeriod(StatementPeriod period) {
    _period = period;
    final today = _today;
    final (start, end) = switch (period) {
      StatementPeriod.today => (today, today),
      StatementPeriod.week => (today.subtract(const Duration(days: 6)), today),
      StatementPeriod.month => (DateTime(today.year, today.month), today),
      StatementPeriod.lastMonth => (
        DateTime(today.year, today.month - 1),
        DateTime(today.year, today.month, 0),
      ),
      StatementPeriod.custom => (_start, _end),
    };
    _start = start;
    _end = end;
  }

  /// Loads the stores to choose from (store statement), then the statement.
  Future<void> start() async {
    if (kind.needsStore) {
      try {
        _storeList = (await _stores.list(limit: 100)).items;
      } on ApiException catch (e) {
        _error = e;
        notifyListeners();
        return;
      }
    }
    await load();
  }

  Future<void> setPeriod(StatementPeriod period) {
    _setPeriod(period);
    return load();
  }

  Future<void> setDates(DateTime start, DateTime end) {
    _period = StatementPeriod.custom;
    _start = start;
    _end = end;
    return load();
  }

  Future<void> setStore(StoreModel store) {
    _storeId = store.id;
    _storeName = store.name;
    return load();
  }

  Future<void> load() async {
    if (needsStoreChoice) {
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _statement = await _service.build(
        kind,
        startDate: kind.hasPeriod ? _start : null,
        endDate: kind.hasPeriod ? _end : null,
        storeId: _storeId,
        storeName: _storeName,
      );
      await _remember();
    } on ApiException catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Puts this statement at the top of "Мои выписки" (20 kept).
  Future<void> _remember() async {
    final storage = history;
    final user = userId;
    if (storage == null || user == null) return;
    final request = StatementRequestModel(
      kind: kind,
      startDate: kind.hasPeriod ? _start : null,
      endDate: kind.hasPeriod ? _end : null,
      storeId: _storeId,
      storeName: _storeName,
      openedAt: _clock(),
    );
    final items = await storage.read(user);
    await storage.write(
      user,
      [
        request,
        for (final i in items)
          if (!i.sameAs(request)) i,
      ].take(20).toList(),
    );
  }

  /// The file name: e.g. `vypiska_cash_2026-11-01_2026-11-19.xlsx`.
  String get fileName {
    final parts = [
      'ofar',
      kind.name,
      if (kind.hasPeriod && _start != null) formatLocalDate(_start!),
      if (kind.hasPeriod && _end != null) formatLocalDate(_end!),
      if (!kind.hasPeriod) formatLocalDate(_today),
    ];
    return '${parts.join('_')}.xlsx';
  }

  /// Makes the Excel file with [toExcel] and hands it to the phone.
  Future<bool> export(Uint8List Function(StatementModel) toExcel) async {
    final s = _statement;
    if (s == null || _isExporting) return false;
    _isExporting = true;
    notifyListeners();
    try {
      await _share.share(
        bytes: toExcel(s),
        fileName: fileName,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      return true;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }
}
