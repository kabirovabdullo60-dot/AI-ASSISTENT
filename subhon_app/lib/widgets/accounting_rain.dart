import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'accounting_rain_drop.dart';
import 'accounting_rain_painter.dart';

/// A slow rain of 3D-looking accountant's things (calculators, notebooks,
/// coins, receipts, pencils) behind the login and register forms.
///
/// Decorative: ignores taps and screen readers. With "reduce motion" on the
/// items stand still where they are.
class AccountingRain extends StatefulWidget {
  const AccountingRain({super.key});

  @override
  State<AccountingRain> createState() => _AccountingRainState();
}

class _AccountingRainState extends State<AccountingRain>
    with SingleTickerProviderStateMixin {
  static final List<AccountingRainDrop> _drops = AccountingRainDrop.generate();

  final ValueNotifier<double> _time = ValueNotifier(0);
  late final Ticker _ticker = createTicker(
    (elapsed) => _time.value = elapsed.inMicroseconds / 1e6,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still && _ticker.isActive) _ticker.stop();
    if (!still && !_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: AccountingRainPainter(time: _time, drops: _drops),
        ),
      ),
    ),
  );
}
