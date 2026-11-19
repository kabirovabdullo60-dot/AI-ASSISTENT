import 'package:flutter/material.dart';

/// Every page of the web, in sidebar order.
enum AppSection {
  dashboard('Dashboard', Icons.grid_view_outlined, Icons.grid_view_rounded),
  stores('Stores', Icons.storefront_outlined, Icons.storefront),
  sales('Sales', Icons.receipt_long_outlined, Icons.receipt_long),
  employees('Employees', Icons.groups_outlined, Icons.groups),
  salaries('Salaries', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet),
  expenses('Expenses', Icons.request_quote_outlined, Icons.request_quote),
  reports('Reports', Icons.bar_chart_outlined, Icons.bar_chart),
  assistant('AI Assistant', Icons.auto_awesome_outlined, Icons.auto_awesome),
  profile('Profile', Icons.account_circle_outlined, Icons.account_circle),
  settings('Settings', Icons.settings_outlined, Icons.settings);

  const AppSection(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;

  /// Top part of the sidebar.
  static const main = [dashboard, stores, sales, employees, salaries, expenses, reports, assistant];

  /// Bottom part of the sidebar.
  static const footer = [profile, settings];

  /// Phone bottom bar (the rest is under "More").
  static const mobileBar = [dashboard, stores, sales, assistant];
}
