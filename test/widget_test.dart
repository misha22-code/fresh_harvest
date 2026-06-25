// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_harvest/main.dart';

void main() {
  testWidgets('Builds FreshHarvestApp', (WidgetTester tester) async {
    await tester.pumpWidget(const FreshHarvestApp());

    expect(find.byType(FreshHarvestApp), findsOneWidget);
  });
}