import 'package:flutter_test/flutter_test.dart';
import 'package:truecash/main.dart';
import 'package:truecash/screens/intro_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TrueCashApp(home: IntroScreen()));
    await tester.pumpAndSettle();

    // Verify that the intro title is present
    expect(find.text('Track Your Wealth'), findsOneWidget);
  });
}
