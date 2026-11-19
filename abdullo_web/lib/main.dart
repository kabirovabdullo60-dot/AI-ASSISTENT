import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/l10n/l10n.dart';
import 'core/network/api_client.dart';
import 'core/network/token_storage.dart';
import 'core/theme/app_palette.dart';
import 'core/theme/app_theme.dart';
import 'services/activity_service.dart';
import 'services/assistant_service.dart';
import 'services/auth_service.dart';
import 'services/employee_service.dart';
import 'services/expense_service.dart';
import 'services/notification_service.dart';
import 'services/payroll_service.dart';
import 'services/preferences_service.dart';
import 'services/profile_service.dart';
import 'services/reports_service.dart';
import 'services/sales_service.dart';
import 'services/store_service.dart';
import 'services/target_service.dart';
import 'viewmodels/assistant_view_model.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/dashboard_view_model.dart';
import 'viewmodels/employees_view_model.dart';
import 'viewmodels/expenses_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/notifications_view_model.dart';
import 'viewmodels/payroll_view_model.dart';
import 'viewmodels/reports_view_model.dart';
import 'viewmodels/sales_view_model.dart';
import 'viewmodels/settings_view_model.dart';
import 'viewmodels/stores_view_model.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';
import 'views/splash_view.dart';

void main() {
  runApp(const WebApp());
}

class WebApp extends StatefulWidget {
  /// [httpClient] can be replaced in tests with a fake backend.
  const WebApp({super.key, this.httpClient, this.splashDuration = const Duration(seconds: 5)});

  final http.Client? httpClient;

  /// The splash stays at least this long on every visit (its animation plays in full),
  /// and longer if the session check is still running. Tests pass [Duration.zero].
  final Duration splashDuration;

  @override
  State<WebApp> createState() => _WebAppState();
}

class _WebAppState extends State<WebApp> {
  late final ApiClient _api = ApiClient(client: widget.httpClient, tokens: TokenStorage());
  late final AuthViewModel _auth = AuthViewModel(AuthService(_api), ProfileService(_api))..restore();

  late bool _splashDone = widget.splashDuration == Duration.zero;
  AuthStatus? _lastStatus;
  int _generation = 0;
  GlobalKey _appKey = GlobalKey();
  (AppPalette, int)? _appKeyTag;

  /// One global key per (palette, sign-in generation): the same key moves the app without
  /// rebuilding it; a new palette or a sign-out gets a new key and so a fresh app.
  GlobalKey _appKeyFor(AppPalette palette) {
    final tag = (palette, _generation);
    if (tag != _appKeyTag) {
      _appKeyTag = tag;
      _appKey = GlobalKey();
    }
    return _appKey;
  }
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _api.onSessionExpired = _auth.sessionExpired;
    if (!_splashDone) {
      _splashTimer = Timer(widget.splashDuration, () {
        if (mounted) setState(() => _splashDone = true);
      });
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _api),
        Provider(create: (_) => ReportsService(_api)),
        ChangeNotifierProvider.value(value: _auth),
        ChangeNotifierProvider(
          create: (_) => SettingsViewModel(
            PreferencesService(),
            systemLanguage: WidgetsBinding.instance.platformDispatcher.locale.languageCode,
            api: _api,
          )..load(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final status = context.select<AuthViewModel, AuthStatus>((a) => a.status);
          // A new palette remounts the app below the providers so every color repaints
          // (data and the open page stay — they live in the providers above).
          final palette = context.select<SettingsViewModel, AppPalette>((s) => s.palette);
          // Signing out starts a fresh app (the signed-in pages must not outlive their data).
          if (status == AuthStatus.signedOut && _lastStatus == AuthStatus.signedIn) _generation++;
          _lastStatus = status;
          final app = MaterialApp(
            // Global key: moving under the signed-in providers keeps the app (and the running splash)
            // alive instead of rebuilding it; a new palette still rebuilds it.
            key: _appKeyFor(palette),
            title: context.select<AuthViewModel, String?>((a) => a.user?.businessName) ?? 'Apex Suite',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: Locale(context.select<SettingsViewModel, String>((s) => s.language.name)),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: appLocalizationsDelegates,
            // Splash → login / app cross-fades instead of cutting.
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 520),
              switchInCurve: Curves.easeOut,
              child: !_splashDone || status == AuthStatus.checking
                  ? SplashView(key: const ValueKey('splash'), duration: widget.splashDuration)
                  : status == AuthStatus.signedOut
                  ? const LoginView(key: ValueKey('login'))
                  : const HomeView(key: ValueKey('home')),
            ),
          );
          // Data providers sit ABOVE MaterialApp so dialogs (which open on the root navigator) see them too.
          if (status != AuthStatus.signedIn) return app;
          return _SignedIn(key: ValueKey(context.read<AuthViewModel>().user?.id), api: _api, child: app);
        },
      ),
    );
  }
}

/// Data ViewModels live only while signed in, so logging out clears every page.
class _SignedIn extends StatefulWidget {
  const _SignedIn({super.key, required this.api, required this.child});

  final ApiClient api;
  final Widget child;

  @override
  State<_SignedIn> createState() => _SignedInState();
}

class _SignedInState extends State<_SignedIn> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsViewModel>().loadRates();
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.api;
    final reports = context.read<ReportsService>();
    final sales = SalesService(api);
    final payroll = PayrollService(api);
    final employees = EmployeeService(api);
    return MultiProvider(
      providers: [
        Provider.value(value: sales),
        Provider.value(value: employees),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel(NotificationService(api))..load()),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(reports, sales, payroll, ActivityService(api), TargetService(api))..load(),
        ),
        ChangeNotifierProvider(create: (_) => StoresViewModel(StoreService(api), sales, reports)..load()),
        ChangeNotifierProvider(create: (_) => SalesViewModel(sales)..load()),
        ChangeNotifierProvider(create: (_) => EmployeesViewModel(employees, reports)..load()),
        ChangeNotifierProvider(create: (_) => PayrollViewModel(payroll)..load()),
        ChangeNotifierProvider(create: (_) => ExpensesViewModel(ExpenseService(api), reports)..load()),
        ChangeNotifierProvider(create: (_) => ReportsViewModel(reports)..load()),
        ChangeNotifierProvider(create: (_) => AssistantViewModel(AssistantService(api, reports))),
      ],
      child: widget.child,
    );
  }
}
