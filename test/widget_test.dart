import 'package:flutter_test/flutter_test.dart';
import 'package:show_assistant/main.dart';
import 'package:show_assistant/services/show_service.dart';

void main() {
  testWidgets('starts on the audience join screen', (tester) async {
    await tester.pumpWidget(ShowAssistantApp(service: MockShowService()));
    expect(find.text('Join the show'), findsOneWidget);
    expect(find.text('Crew & staff sign in'), findsOneWidget);
  });
}
