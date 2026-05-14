import 'package:flutter_test/flutter_test.dart';

import 'package:sidia_app/main.dart';

void main() {
  testWidgets('SIDIA app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const SidiaApp());
    // Verify the splash screen is shown
    expect(find.text('Sistem Diagnosis Diabetes'), findsOneWidget);
  });
}
