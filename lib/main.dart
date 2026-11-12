import 'package:flutter/material.dart';

import 'models.dart';
import 'screens/caller_screen.dart';
import 'screens/crew_screen.dart';
import 'screens/login_screen.dart';
import 'services/show_service.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      // Which screen shows is decided purely by who is signed in.
      home: ListenableBuilder(
        listenable: service,
        builder: (context, _) {
          final user = service.user;
          if (user == null) return LoginScreen(service: service);
          return user.role == StaffRole.stageManager
              ? CallerScreen(service: service)
              : CrewScreen(service: service);
        },
      ),
    );
  }
}
