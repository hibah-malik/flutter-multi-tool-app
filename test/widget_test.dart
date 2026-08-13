import 'package:flutter_test/flutter_test.dart';
import 'package:hw_project_app/main.dart';

void main() {
  testWidgets('app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CombinedHwApp());
    expect(find.text('HW Project App'), findsOneWidget);
  });
}
