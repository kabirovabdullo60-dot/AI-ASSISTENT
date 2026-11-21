import 'package:subhon_app/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';

void main() {
  testWidgets('shows home', (tester) async {
    // The first screen of the app: with no saved session it is the login
    // screen (the placeholder "App home" was replaced by the real app).
    FlutterSecureStorage.setMockInitialValues({});
    reduceMotion(tester);
    await tester.pumpWidget(const MobileApp());
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsWidgets);
  });
}
