import 'package:aiasistent/web/web_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WebApp shows web home', (tester) async {
    await tester.pumpWidget(const WebApp());
    expect(find.text('Web home'), findsOneWidget);
  });
}
