import 'package:flutter_test/flutter_test.dart';
import 'package:show_assistant/main.dart';
import 'package:show_assistant/services/show_service.dart';

void main() {
  testWidgets('starts on the sign-in screen', (tester) async {
    await tester.pumpWidget(ShowAssistantApp(service: MockShowService()));
    expect(find.text('Sign in'), findsOneWidget);
  });
}
