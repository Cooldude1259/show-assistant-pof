import 'package:flutter/material.dart';

/// Placeholder for the audience side (separate trust level, no sign-in).
class AudienceScreen extends StatelessWidget {
  const AudienceScreen({super.key, required this.showName});

  final String showName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(showName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Show starts in 15 minutes'),
              subtitle: const Text('Please take your seats'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phonelink_erase),
              title: const Text('Phones on silent'),
              subtitle: const Text('This screen dims automatically when the show starts'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Audience features are a placeholder in this proof of concept.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
