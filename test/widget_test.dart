import 'package:flutter_test/flutter_test.dart';
import 'package:citygame/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CityCompassApp());
    expect(find.text('CITY COMPASS'), findsOneWidget);
  });
}
