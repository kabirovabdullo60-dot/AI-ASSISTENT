import 'package:abdullo_web/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows home', (tester) async {
    await tester.pumpWidget(const WebApp());
    expect(find.text('Web home'), findsOneWidget);
  });
}
