import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/assistant_service.dart';
import 'services/dashboard_service.dart';
import 'services/employee_service.dart';
import 'services/payroll_service.dart';
import 'services/profile_service.dart';
import 'services/sales_service.dart';
import 'services/store_service.dart';
import 'viewmodels/assistant_view_model.dart';
import 'viewmodels/dashboard_view_model.dart';
import 'viewmodels/employees_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/payroll_view_model.dart';
import 'viewmodels/profile_view_model.dart';
import 'viewmodels/sales_view_model.dart';
import 'viewmodels/settings_view_model.dart';
import 'viewmodels/stores_view_model.dart';
import 'views/home_view.dart';

void main() {
  runApp(const WebApp());
}

class WebApp extends StatelessWidget {
  const WebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel(ProfileService())..load()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel(DashboardService())..load()),
        ChangeNotifierProvider(create: (_) => StoresViewModel(StoreService())..load()),
        ChangeNotifierProvider(create: (_) => SalesViewModel(SalesService())..load()),
        ChangeNotifierProvider(create: (_) => EmployeesViewModel(EmployeeService())..load()),
        ChangeNotifierProvider(create: (_) => PayrollViewModel(PayrollService())..load()),
        ChangeNotifierProvider(create: (_) => AssistantViewModel(AssistantService())),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          title: context.select<SettingsViewModel, String>((s) => s.businessName),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const HomeView(),
        ),
      ),
    );
  }
}
