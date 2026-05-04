import 'package:flutter_test/flutter_test.dart';
import 'package:charo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CharoApp());
    expect(find.byType(CharoApp), findsOneWidget);
  });
}
