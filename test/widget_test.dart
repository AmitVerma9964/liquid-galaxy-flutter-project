import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:amti_fluttter_task1/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LgApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
