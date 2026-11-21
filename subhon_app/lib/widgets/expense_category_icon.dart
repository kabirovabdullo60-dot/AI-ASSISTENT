import 'package:flutter/material.dart';

import '../models/expense_category.dart';

/// The icon of an expense category.
IconData expenseCategoryIcon(ExpenseCategory category) => switch (category) {
  ExpenseCategory.rent => Icons.home_work_outlined,
  ExpenseCategory.utilities => Icons.bolt_outlined,
  ExpenseCategory.delivery => Icons.local_shipping_outlined,
  ExpenseCategory.supplies => Icons.inventory_2_outlined,
  ExpenseCategory.marketing => Icons.campaign_outlined,
  ExpenseCategory.taxes => Icons.account_balance_outlined,
  ExpenseCategory.other => Icons.receipt_long_outlined,
};
