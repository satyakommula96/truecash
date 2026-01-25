import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:truecash/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test - verifies app launches', (tester) async {
    await app.main();
    
    // Poll for up to 10 seconds for the app to settle on a known screen
    // This is faster than a hard wait if the app loads quickly.
    bool found = false;
    for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 100)); // 100ms * 100 = 10s max
        
        final finder = find.byWidgetPredicate((widget) {
        if (widget is Text) {
          final data = widget.data;
          // Check for Title of Intro OR Dashboard OR specific failure/loading states that indicate app is alive
          return data == 'Track Your Wealth' || // Intro Title
              data == 'Dashboard' ||           // Dashboard Title (might be different? "TrueCash" is app title)
              data == 'Smart Budgeting' ||     // Intro Page 2
              data == 'ANALYSIS & BUDGETS' ||  // Analysis Screen
              data == 'TrueCash';              // App Bar Title?
        }
        return false;
      });
      
      if (finder.evaluate().isNotEmpty) {
          found = true;
          break;
      }
    }

    if (!found) {
        debugPrint('Test timed out waiting for app to load. Dumping widget tree:');
        debugDumpApp();
        fail("App did not load Intro or Dashboard within 10 seconds");
    }
    
    expect(found, isTrue);
  });
}
