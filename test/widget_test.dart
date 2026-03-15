import 'package:flutter_test/flutter_test.dart';
import 'package:trimbakeshwar_app/main.dart';

void main() {
  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TrimbakeshwarApp());
    expect(find.text('TRIMBAKESHWAR'), findsOneWidget);
  });
}
