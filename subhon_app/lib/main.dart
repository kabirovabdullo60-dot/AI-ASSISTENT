import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/locale_storage.dart';
import 'core/storage/secure_locale_storage.dart';
import 'core/storage/secure_token_storage.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'l10n/fallback_localizations_delegate.dart';
import 'l10n/l10n.dart';
import 'services/activity_service.dart';
import 'services/assistant_service.dart';
import 'services/auth_service.dart';
import 'services/device_voice_service.dart';
import 'services/employee_service.dart';
import 'services/expense_service.dart';
import 'services/notification_service.dart';
import 'services/payroll_service.dart';
import 'services/profile_service.dart';
import 'services/reports_service.dart';
import 'services/sales_service.dart';
import 'services/store_service.dart';
import 'services/voice_service.dart';
import 'services/target_service.dart';
import 'viewmodels/locale_view_model.dart';
import 'viewmodels/session_view_model.dart';
import 'views/session_gate_view.dart';
import 'widgets/intro_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(const MobileApp());
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
      Provider<VoiceService>(
        create: (_) => widget.voice ?? DeviceVoiceService(),
      ),
      Provider(create: (_) => ReportsService(_api)),
      ChangeNotifierProvider(
        create: (_) => SessionViewModel(_auth, _api)..restore(),
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
            return IntroOverlay(title: context.l10n.introTitle, child: child!);
          },
          home: const SessionGateView(),
        );
      },
    ),
  );
}
