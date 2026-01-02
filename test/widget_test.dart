
import 'package:flutter_test/flutter_test.dart';
import 'package:open_tv/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OpenTVApp());

    // Verify the app launches with the correct title
    expect(find.text('OpenTV'), findsOneWidget);
  });
}
