import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../viewmodels/personal_finance_view_model.dart';

/// The personal accountant when the screen is inside the app's shell;
/// `null` elsewhere.
PersonalFinanceViewModel? personalOrNull(BuildContext context) {
  try {
    return Provider.of<PersonalFinanceViewModel>(context, listen: false);
  } on ProviderNotFoundException {
    return null;
  }
}
