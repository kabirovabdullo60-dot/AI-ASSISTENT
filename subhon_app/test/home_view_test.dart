import 'package:subhon_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows home', (tester) async {
    await tester.pumpWidget(const MobileApp());
    expect(find.text('App home'), findsOneWidget);
  });
}
