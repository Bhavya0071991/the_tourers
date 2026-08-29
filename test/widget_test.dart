import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dummy_epod/features/home/presentation/widgets/custom_app_bar.dart';

void main() {
  testWidgets('CustomAppBar displays app logo', (WidgetTester tester) async {
    // Build the CustomAppBar in isolation inside a MaterialApp.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomAppBar(),
        ),
      ),
    );

    // Verify that our app logo "THE TOURERS." is displayed.
    expect(find.text('THE TOURERS.'), findsOneWidget);
  });
}
