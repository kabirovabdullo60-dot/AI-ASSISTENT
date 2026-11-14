import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'app/mobile_app.dart';
import 'web/web_app.dart';

/// Entry point. Owned by the Team Lead (edit only on `main`).
/// Web build  -> lib/web (Abdullo)
/// App build  -> lib/app (Subhon)
void main() {
  runApp(kIsWeb ? const WebApp() : const MobileApp());
}
