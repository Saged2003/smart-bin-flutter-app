import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_bin_eng/main.dart';

void main() {
  testWidgets('Login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(l: false));
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}