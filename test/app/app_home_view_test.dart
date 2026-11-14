import 'package:aiasistent/app/mobile_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MobileApp shows app home', (tester) async {
    await tester.pumpWidget(const MobileApp());
    expect(find.text('App home'), findsOneWidget);
  });
}
