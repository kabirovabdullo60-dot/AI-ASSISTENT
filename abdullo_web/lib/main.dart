import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/assistant_service.dart';
import 'services/dashboard_service.dart';
import 'viewmodels/assistant_view_model.dart';
import 'viewmodels/dashboard_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/settings_view_model.dart';
import 'views/home_view.dart';

void main() {
  runApp(const WebApp());
}

class WebApp extends StatelessWidget {
  /// Services can be replaced in tests.
  const WebApp({super.key, this.dashboardService, this.assistantService});

  final DashboardService? dashboardService;
  final AssistantService? assistantService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel(dashboardService ?? DashboardService())..load(),
        ),
        ChangeNotifierProvider(create: (_) => AssistantViewModel(assistantService ?? AssistantService())),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) => MaterialApp(
          title: 'AI Business Assistant',
          debugShowCheckedModeBanner: false,
          themeMode: settings.themeMode,
          theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          home: const HomeView(),
        ),
      ),
    );
  }
}
