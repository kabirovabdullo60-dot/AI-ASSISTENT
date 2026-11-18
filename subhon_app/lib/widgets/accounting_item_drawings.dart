import 'package:flutter/painting.dart';

import 'accounting_item_kind.dart';

/// Draws the accountant's things of the falling rain, centred on (0, 0) in
/// a box of side `s`. Each looks solid: a darker "thickness" behind the
/// face, gradients for light and a gloss highlight.
abstract final class AccountingItemDrawings {
  static final Paint _paint = Paint()..isAntiAlias = true;

  static void draw(Canvas canvas, AccountingItemKind kind, double s) {
    switch (kind) {
      case AccountingItemKind.calculator:
        _calculator(canvas, s);
      case AccountingItemKind.notebook:
        _notebook(canvas, s);
      case AccountingItemKind.coin:
        _coin(canvas, s);
      case AccountingItemKind.receipt:
        _receipt(canvas, s);
      case AccountingItemKind.pencil:
        _pencil(canvas, s);
    }
  }

  static Paint _fill(Color color) => _paint
    ..shader = null
    ..style = PaintingStyle.fill
    ..color = color;

  static Paint _gradient(
    Rect rect,
    List<Color> colors, {
    List<double>? stops,
  }) => _paint
    ..style = PaintingStyle.fill
    ..color = const Color(0xFFFFFFFF)
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
      stops: stops,
    ).createShader(rect);

  static void _gloss(Canvas canvas, RRect face) {
    canvas.save();
    canvas.clipRRect(face);
    final r = face.outerRect;
    canvas.drawOval(
      Rect.fromLTWH(
        r.left - r.width * 0.3,
        r.top - r.height * 0.45,
        r.width * 1.1,
        r.height * 0.8,
      ),
      _fill(const Color(0x1FFFFFFF)),
    );
    canvas.restore();
  }

  static void _calculator(Canvas canvas, double s) {
    final w = s * 0.7;
    final h = s;
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final radius = Radius.circular(s * 0.1);
    final face = RRect.fromRectAndRadius(rect, radius);
    canvas.drawRRect(
      face.shift(Offset(s * 0.04, s * 0.06)),
      _fill(const Color(0xFF14112A)),
    );
    canvas.drawRRect(
      face,
      _gradient(rect, const [Color(0xFF5A5288), Color(0xFF26213F)]),
    );
    // Screen with digits.
    final screen = Rect.fromLTWH(
      rect.left + s * 0.08,
      rect.top + s * 0.09,
      w - s * 0.16,
      s * 0.2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, Radius.circular(s * 0.04)),
      _gradient(screen, const [Color(0xFFB8F7D4), Color(0xFF63D39F)]),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            screen.right - s * (0.08 + i * 0.09),
            screen.top + s * 0.06,
            s * 0.06,
            s * 0.09,
          ),
          Radius.circular(s * 0.012),
        ),
        _fill(const Color(0xFF1F5A40)),
      );
    }
    // 4 × 4 keys; the last column purple, "=" orange.
    final top = rect.top + s * 0.36;
    final cellW = (w - s * 0.16) / 4;
    final cellH = (rect.bottom - s * 0.08 - top) / 4;
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 4; col++) {
        final key = Rect.fromLTWH(
          rect.left + s * 0.08 + col * cellW + cellW * 0.12,
          top + row * cellH + cellH * 0.14,
          cellW * 0.76,
          cellH * 0.72,
        );
        final color = col == 3 && row == 3
            ? const Color(0xFFFF9F43)
            : col == 3
            ? const Color(0xFF9B7BFF)
            : const Color(0xFFE4DEFA);
        canvas.drawRRect(
          RRect.fromRectAndRadius(key, Radius.circular(s * 0.025)),
          _fill(color),
        );
      }
    }
    _gloss(canvas, face);
  }

  static void _notebook(Canvas canvas, double s) {
    final w = s * 0.74;
    final h = s;
    final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
    final face = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.06));
    // The pages, seen as a white edge behind the cover.
    canvas.drawRRect(
      face.shift(Offset(s * 0.05, s * 0.05)),
      _fill(const Color(0xFFD9D3F2)),
    );
    canvas.drawRRect(
      face.shift(Offset(s * 0.025, s * 0.025)),
      _fill(const Color(0xFFF7F5FF)),
    );
    canvas.drawRRect(
      face,
      _gradient(rect, const [Color(0xFFA486FF), Color(0xFF5634CF)]),
    );
    // Spine and spiral rings.
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, s * 0.13, h),
      _fill(const Color(0x33000000)),
    );
    final ring = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.028
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFEDEAF7);
    for (var i = 0; i < 6; i++) {
      final y = rect.top + s * 0.1 + i * (h - s * 0.2) / 5;
      canvas.drawLine(
        Offset(rect.left - s * 0.03, y),
        Offset(rect.left + s * 0.08, y),
        ring,
      );
    }
    // Label.
    final label = Rect.fromCenter(
      center: Offset(s * 0.06, -s * 0.2),
      width: s * 0.4,
      height: s * 0.17,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(label, Radius.circular(s * 0.03)),
      _fill(const Color(0xFFF7F5FF)),
    );
    for (var i = 0; i < 2; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            label.left + s * 0.05,
            label.top + s * (0.045 + i * 0.05),
            s * (i == 0 ? 0.28 : 0.18),
            s * 0.025,
          ),
          Radius.circular(s * 0.012),
        ),
        _fill(const Color(0xFFB3A8DA)),
      );
    }
    _gloss(canvas, face);
  }

  static TextPainter? _coinMark;

  static void _coin(Canvas canvas, double s) {
    final r = s * 0.42;
    // The rim (thickness), then the face.
    canvas.drawCircle(Offset(0, s * 0.08), r, _fill(const Color(0xFFA86F00)));
    canvas.drawRect(
      Rect.fromLTRB(-r, 0, r, s * 0.08),
      _fill(const Color(0xFFA86F00)),
    );
    final face = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawCircle(
      Offset.zero,
      r,
      _paint
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFFFFFFF)
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.4),
          radius: 1.0,
          colors: [Color(0xFFFFF0B8), Color(0xFFF7BC1C), Color(0xFFCC8A00)],
          stops: [0, 0.55, 1],
        ).createShader(face),
    );
    canvas.drawCircle(
      Offset.zero,
      r * 0.74,
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.035
        ..color = const Color(0x99FFF4C9),
    );
    final mark = _coinMark ??= TextPainter(
      text: const TextSpan(
        text: r'$',
        style: TextStyle(
          color: Color(0xFFB57A00),
          fontSize: 100,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    final scale = s * 0.5 / mark.height;
    canvas.scale(scale);
    mark.paint(canvas, Offset(-mark.width / 2, -mark.height / 2));
    canvas.restore();
  }

  static void _receipt(Canvas canvas, double s) {
    final w = s * 0.62;
    final h = s;
    final left = -w / 2;
    final top = -h / 2;
    const teeth = 6;
    final tooth = w / teeth;
    final path = Path()
      ..moveTo(left, top)
      ..lineTo(left + w, top)
      ..lineTo(left + w, top + h);
    for (var i = teeth - 1; i >= 0; i--) {
      path
        ..lineTo(left + i * tooth + tooth / 2, top + h - s * 0.06)
        ..lineTo(left + i * tooth, top + h);
    }
    path.close();
    canvas.drawPath(
      path.shift(Offset(s * 0.04, s * 0.05)),
      _fill(const Color(0x40000000)),
    );
    final rect = Rect.fromLTWH(left, top, w, h);
    canvas.drawPath(
      path,
      _gradient(rect, const [Color(0xFFE9E4FA), Color(0xFFC9C0EA)]),
    );
    canvas.drawCircle(
      Offset(0, top + s * 0.11),
      s * 0.05,
      _fill(const Color(0xFF9B7BFF)),
    );
    const widths = [0.42, 0.3, 0.38, 0.24];
    for (var i = 0; i < widths.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left + s * 0.08,
            top + s * (0.24 + i * 0.11),
            s * widths[i],
            s * 0.035,
          ),
          Radius.circular(s * 0.015),
        ),
        _fill(const Color(0xFFC4BCDF)),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + s * 0.08, top + s * 0.73, w - s * 0.16, s * 0.06),
        Radius.circular(s * 0.02),
      ),
      _fill(const Color(0xFF7048E8)),
    );
  }

  static void _pencil(Canvas canvas, double s) {
    final t = s * 0.16;
    // Shadow side (thickness).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          -s * 0.54,
          -t / 2,
          s * 0.3,
          t / 2,
        ).shift(Offset(s * 0.02, s * 0.04)),
        Radius.circular(t * 0.3),
      ),
      _fill(const Color(0x40000000)),
    );
    // Body, shaded like a cylinder.
    final body = Rect.fromLTRB(-s * 0.38, -t / 2, s * 0.28, t / 2);
    canvas.drawRect(
      body,
      _paint
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFFFFFFF)
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE08A), Color(0xFFF5A623), Color(0xFFB86E00)],
          stops: [0, 0.5, 1],
        ).createShader(body),
    );
    for (final y in [-t * 0.17, t * 0.17]) {
      canvas.drawLine(
        Offset(body.left, y),
        Offset(body.right, y),
        Paint()
          ..strokeWidth = s * 0.008
          ..color = const Color(0x55A35F00),
      );
    }
    // Metal band and eraser.
    final band = Rect.fromLTRB(-s * 0.46, -t / 2, -s * 0.38, t / 2);
    canvas.drawRect(
      band,
      _paint
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFFFFFFF)
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF2F2F2), Color(0xFF9E9E9E)],
        ).createShader(band),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(-s * 0.54, -t / 2, -s * 0.46, t / 2),
        topLeft: Radius.circular(t * 0.4),
        bottomLeft: Radius.circular(t * 0.4),
      ),
      _fill(const Color(0xFFFF8FA3)),
    );
    // Sharpened wood and graphite.
    final wood = Path()
      ..moveTo(s * 0.28, -t / 2)
      ..lineTo(s * 0.48, 0)
      ..lineTo(s * 0.28, t / 2)
      ..close();
    canvas.drawPath(wood, _fill(const Color(0xFFF0CFA0)));
    final lead = Path()
      ..moveTo(s * 0.41, -t * 0.17)
      ..lineTo(s * 0.48, 0)
      ..lineTo(s * 0.41, t * 0.17)
      ..close();
    canvas.drawPath(lead, _fill(const Color(0xFF35304A)));
  }
}
