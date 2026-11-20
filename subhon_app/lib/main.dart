import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/app_lock_storage.dart';
import 'core/storage/chat_history_storage.dart';
import 'core/storage/debt_storage.dart';
import 'core/storage/intro_storage.dart';
import 'core/storage/personal_finance_storage.dart';
import 'core/storage/locale_storage.dart';
import 'core/storage/secure_app_lock_storage.dart';
import 'core/storage/secure_chat_history_storage.dart';
import 'core/storage/secure_debt_storage.dart';
import 'core/storage/secure_personal_finance_storage.dart';
import 'core/storage/secure_statement_history_storage.dart';
import 'core/storage/statement_history_storage.dart';
import 'core/storage/secure_locale_storage.dart';
import 'core/storage/secure_token_storage.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'l10n/fallback_localizations_delegate.dart';
import 'l10n/l10n.dart';
import 'services/activity_service.dart';
import 'services/assistant_service.dart';
import 'services/auth_service.dart';
import 'services/biometric_service.dart';
import 'services/device_biometric_service.dart';
import 'services/device_file_share_service.dart';
import 'services/device_voice_service.dart';
import 'services/employee_service.dart';
import 'services/expense_service.dart';
import 'services/market_service.dart';
import 'services/file_share_service.dart';
import 'services/notification_service.dart';
import 'services/payroll_service.dart';
import 'services/profile_service.dart';
import 'services/reports_service.dart';
import 'services/sales_service.dart';
import 'services/statement_service.dart';
import 'services/store_service.dart';
import 'services/voice_service.dart';
import 'services/target_service.dart';
import 'viewmodels/app_lock_view_model.dart';
import 'viewmodels/locale_view_model.dart';
import 'viewmodels/session_view_model.dart';
import 'views/app_lock_gate.dart';
import 'views/session_gate_view.dart';
import 'widgets/intro_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final intro = await const IntroStorage().firstLaunch();
  runApp(MobileApp(showIntro: intro));
}

/// The app root: services (one [ApiClient] for all), the session and the
/// language, OFAR's theme, and the login / main screen by session.
class MobileApp extends StatefulWidget {
  const MobileApp({
    this.httpClient,
    this.tokens,
    this.localeStorage,
    this.locale,
    this.voice,
    this.chatHistory,
    this.statementHistory,
    this.fileShare,
    this.biometric,
    this.appLock,
    this.market,
    this.debts,
    this.personal,
    this.showIntro = false,
    super.key,
  });

  /// Tests pass a `MockClient`; the app uses a real one.
  final http.Client? httpClient;
  final TokenStorage? tokens;
  final LocaleStorage? localeStorage;

  /// Forces a language (tests).
  final Locale? locale;

  /// Speech in and out; tests pass a fake, the app uses the phone's.
  final VoiceService? voice;

  /// Where AI chats are kept; tests pass one in memory.
  final ChatHistoryStorage? chatHistory;

  /// "Мои выписки" and the share sheet; tests pass fakes.
  final StatementHistoryStorage? statementHistory;
  final FileShareService? fileShare;

  /// Face ID / fingerprint and whether the lock is on; tests pass fakes.
  final BiometricService? biometric;
  final AppLockStorage? appLock;

  /// Public exchange rates and crypto prices; tests pass a fake backend.
  final MarketService? market;

  /// Debts kept on the phone; tests pass one in memory.
  final DebtStorage? debts;

  /// The personal accountant's data; tests pass one in memory.
  final PersonalFinanceStorage? personal;

  /// The launch intro plays only the first time the app is opened.
  final bool showIntro;

  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  late final TokenStorage _tokens = widget.tokens ?? const SecureTokenStorage();
  late final ApiClient _api = ApiClient(
    tokens: _tokens,
    client: widget.httpClient,
  );
  late final AuthService _auth = AuthService(_api, _tokens);

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider.value(value: _api),
      Provider.value(value: _auth),
      Provider(create: (_) => ProfileService(_api)),
      Provider(create: (_) => StoreService(_api)),
      Provider(create: (_) => SalesService(_api)),
      Provider(create: (_) => EmployeeService(_api)),
      Provider(create: (_) => PayrollService(_api)),
      Provider(create: (_) => ExpenseService(_api)),
      Provider(create: (_) => TargetService(_api)),
      Provider(create: (_) => ActivityService(_api)),
      Provider(create: (_) => NotificationService(_api)),
      Provider(create: (_) => AssistantService(_api)),
      // Before StatementService, which reads it.
      Provider(create: (_) => ReportsService(_api)),
      Provider(
        create: (c) => StatementService(
          c.read<SalesService>(),
          c.read<ExpenseService>(),
          c.read<PayrollService>(),
          c.read<ActivityService>(),
          c.read<ReportsService>(),
        ),
      ),
      Provider<StatementHistoryStorage>(
        create: (_) =>
            widget.statementHistory ?? const SecureStatementHistoryStorage(),
      ),
      Provider<FileShareService>(
        create: (_) => widget.fileShare ?? DeviceFileShareService(),
      ),
      Provider(create: (_) => widget.market ?? MarketService()),
      Provider<PersonalFinanceStorage>(
        create: (_) => widget.personal ?? const SecurePersonalFinanceStorage(),
      ),
      Provider<DebtStorage>(
        create: (_) => widget.debts ?? const SecureDebtStorage(),
      ),
      Provider<ChatHistoryStorage>(
        create: (_) => widget.chatHistory ?? const SecureChatHistoryStorage(),
      ),
      Provider<VoiceService>(
        create: (_) => widget.voice ?? DeviceVoiceService(),
      ),
      ChangeNotifierProvider(
        create: (_) => SessionViewModel(_auth, _api)..restore(),
      ),
      ChangeNotifierProvider(
        create: (_) => AppLockViewModel(
          widget.appLock ?? const SecureAppLockStorage(),
          widget.biometric ?? DeviceBiometricService(),
        )..load(),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            LocaleViewModel(widget.localeStorage ?? const SecureLocaleStorage())
              ..load(),
      ),
    ],
    child: Consumer<LocaleViewModel>(
      builder: (context, language, _) {
        final code = language.code;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => context.l10n.appTitle,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: widget.locale ?? (code == null ? null : Locale(code)),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FallbackLocalizationsDelegate<MaterialLocalizations>(
              GlobalMaterialLocalizations.delegate,
            ),
            FallbackLocalizationsDelegate<CupertinoLocalizations>(
              GlobalCupertinoLocalizations.delegate,
            ),
          ],
          builder: (context, child) {
            // Accept-Language follows the language on screen.
            final language = Localizations.localeOf(context).languageCode;
            _api.language = () => language;
            return AppLockGate(
              child: widget.showIntro
                  ? IntroOverlay(title: context.l10n.introTitle, child: child!)
                  : child!,
            );
          },
          home: const SessionGateView(),
        );
      },
    ),
  );
}
