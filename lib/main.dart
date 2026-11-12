import 'package:flutter/material.dart';

import 'models.dart';
import 'screens/caller_screen.dart';
import 'screens/crew_screen.dart';
import 'screens/join_screen.dart';
import 'services/show_service.dart';
import 'theme.dart';

void main() {
  runApp(ShowAssistantApp(service: MockShowService()));
}

class ShowAssistantApp extends StatelessWidget {
  const ShowAssistantApp({super.key, required this.service});

  final ShowService service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Show Assistant',
      debugShowCheckedModeBanner: false,
      theme: backstageTheme(),
      // Signed out = audience join screen (with a link to staff sign-in).
      // Signed in = the screen for that role.
      home: ListenableBuilder(
        listenable: service,
        builder: (context, _) {
          final user = service.user;
          if (user == null) return JoinScreen(service: service);
          return user.role == StaffRole.stageManager
              ? CallerScreen(service: service)
              : CrewScreen(service: service);
        },
      ),
    );
  }
}
