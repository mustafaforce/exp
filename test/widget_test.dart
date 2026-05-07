import 'package:flutter_test/flutter_test.dart';
import 'package:exp/app.dart';

void main() {
  testWidgets('App loads with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
