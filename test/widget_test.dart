// Basic Flutter widget test for BioLens.
//
// Note: Full UI tests require running build_runner first for Isar code generation.

import 'package:flutter_test/flutter_test.dart';
import 'package:biolens/main.dart';

void main() {
  testWidgets('BioLens app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BioLensApp());

    // Verify that the app loads (Herbier screen title should appear)
    expect(find.text('Mon Herbier'), findsOneWidget);
  });
}
