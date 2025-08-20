import 'package:flutter_test/flutter_test.dart';
import 'package:age_of_gold/app/app.dart';

void main() {
  group('App', () {
    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(const App());

      await tester.pumpAndSettle(const Duration(seconds: 400));
      expect(find.byType(AppView), findsOneWidget);
    });
  });
}
