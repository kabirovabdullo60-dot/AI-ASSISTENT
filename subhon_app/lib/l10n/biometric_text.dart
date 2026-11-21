import '../models/biometric_kind.dart';
import 'generated/app_localizations.dart';

/// "Вход по Face ID" / "…по отпечатку пальца" / "…по биометрии".
String biometricTitle(AppLocalizations l10n, BiometricKind kind) =>
    switch (kind) {
      BiometricKind.face => l10n.lockFaceId,
      BiometricKind.fingerprint => l10n.lockFingerprint,
      _ => l10n.lockBiometric,
    };
