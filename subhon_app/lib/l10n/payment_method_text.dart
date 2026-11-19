import '../models/payment_method.dart';
import 'generated/app_localizations.dart';

/// The translated name of a sale's payment method (`null`: not specified).
String paymentMethodText(AppLocalizations l10n, PaymentMethod? method) =>
    switch (method) {
      PaymentMethod.cash => l10n.paymentCash,
      PaymentMethod.card => l10n.paymentCard,
      PaymentMethod.qr => l10n.paymentQr,
      PaymentMethod.mixed => l10n.paymentMixed,
      null => l10n.paymentNotSet,
    };
