import 'package:flutter/material.dart';

import '../models/money_account_kind.dart';
import '../models/money_category.dart';
import 'generated/app_localizations.dart';

String moneyCategoryText(AppLocalizations l10n, MoneyCategory c) => switch (c) {
  MoneyCategory.food => l10n.pfCatFood,
  MoneyCategory.cafe => l10n.pfCatCafe,
  MoneyCategory.transport => l10n.pfCatTransport,
  MoneyCategory.home => l10n.pfCatHome,
  MoneyCategory.utilities => l10n.pfCatUtilities,
  MoneyCategory.phone => l10n.pfCatPhone,
  MoneyCategory.health => l10n.pfCatHealth,
  MoneyCategory.clothes => l10n.pfCatClothes,
  MoneyCategory.education => l10n.pfCatEducation,
  MoneyCategory.fun => l10n.pfCatFun,
  MoneyCategory.gifts => l10n.pfCatGifts,
  MoneyCategory.family => l10n.pfCatFamily,
  MoneyCategory.debtOut => l10n.pfCatDebtOut,
  MoneyCategory.debtPay => l10n.pfCatDebtPay,
  MoneyCategory.otherExpense => l10n.pfCatOtherExpense,
  MoneyCategory.salary => l10n.pfCatSalary,
  MoneyCategory.business => l10n.pfCatBusiness,
  MoneyCategory.sideJob => l10n.pfCatSideJob,
  MoneyCategory.giftIn => l10n.pfCatGiftIn,
  MoneyCategory.refund => l10n.pfCatRefund,
  MoneyCategory.debtIn => l10n.pfCatDebtIn,
  MoneyCategory.debtBack => l10n.pfCatDebtBack,
  MoneyCategory.otherIncome => l10n.pfCatOtherIncome,
};

IconData moneyCategoryIcon(MoneyCategory c) => switch (c) {
  MoneyCategory.food => Icons.shopping_basket_outlined,
  MoneyCategory.cafe => Icons.restaurant_outlined,
  MoneyCategory.transport => Icons.directions_car_outlined,
  MoneyCategory.home => Icons.home_outlined,
  MoneyCategory.utilities => Icons.bolt_outlined,
  MoneyCategory.phone => Icons.wifi_rounded,
  MoneyCategory.health => Icons.favorite_outline_rounded,
  MoneyCategory.clothes => Icons.checkroom_outlined,
  MoneyCategory.education => Icons.school_outlined,
  MoneyCategory.fun => Icons.celebration_outlined,
  MoneyCategory.gifts => Icons.card_giftcard_outlined,
  MoneyCategory.family => Icons.family_restroom_outlined,
  MoneyCategory.debtOut => Icons.call_made_rounded,
  MoneyCategory.debtPay => Icons.credit_score_outlined,
  MoneyCategory.otherExpense => Icons.more_horiz_rounded,
  MoneyCategory.salary => Icons.work_outline_rounded,
  MoneyCategory.business => Icons.storefront_outlined,
  MoneyCategory.sideJob => Icons.handyman_outlined,
  MoneyCategory.giftIn => Icons.redeem_outlined,
  MoneyCategory.refund => Icons.undo_rounded,
  MoneyCategory.debtIn => Icons.call_received_rounded,
  MoneyCategory.debtBack => Icons.assignment_return_outlined,
  MoneyCategory.otherIncome => Icons.add_card_outlined,
};

String accountKindText(AppLocalizations l10n, MoneyAccountKind k) =>
    switch (k) {
      MoneyAccountKind.cash => l10n.pfKindCash,
      MoneyAccountKind.card => l10n.pfKindCard,
      MoneyAccountKind.bank => l10n.pfKindBank,
      MoneyAccountKind.savings => l10n.pfKindSavings,
      MoneyAccountKind.other => l10n.pfKindOther,
    };

IconData accountKindIcon(MoneyAccountKind k) => switch (k) {
  MoneyAccountKind.cash => Icons.payments_outlined,
  MoneyAccountKind.card => Icons.credit_card_rounded,
  MoneyAccountKind.bank => Icons.account_balance_outlined,
  MoneyAccountKind.savings => Icons.savings_outlined,
  MoneyAccountKind.other => Icons.account_balance_wallet_outlined,
};
