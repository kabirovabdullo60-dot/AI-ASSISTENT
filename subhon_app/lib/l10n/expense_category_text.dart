import '../models/expense_category.dart';
import 'generated/app_localizations.dart';

/// The translated name of an expense category.
String expenseCategoryText(AppLocalizations l10n, ExpenseCategory category) =>
    switch (category) {
      ExpenseCategory.rent => l10n.expenseCategoryRent,
      ExpenseCategory.utilities => l10n.expenseCategoryUtilities,
      ExpenseCategory.delivery => l10n.expenseCategoryDelivery,
      ExpenseCategory.supplies => l10n.expenseCategorySupplies,
      ExpenseCategory.marketing => l10n.expenseCategoryMarketing,
      ExpenseCategory.taxes => l10n.expenseCategoryTaxes,
      ExpenseCategory.other => l10n.expenseCategoryOther,
    };
