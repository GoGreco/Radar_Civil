import 'package:flutter_test/flutter_test.dart';
import 'package:radar_civil/main.dart';

void main() {
  testWidgets('App inicia sem erros', (WidgetTester tester) async {
    await tester.pumpWidget(const RadarCivilApp());

    expect(find.byType(RadarCivilApp), findsOneWidget);
  });
}
