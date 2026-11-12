import 'package:flutter/material.dart';

import '../services/show_service.dart';
import 'audience_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.service});

  final ShowService service;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _showCode = TextEditingController();
  final _username = TextEditingController();
  final _pin = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _showCode.dispose();
    _username.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.service.login(
        showCode: _showCode.text,
        username: _username.text,
        pin: _pin.text,
      );
      // On success the app root swaps this screen out, so nothing else to do.
    } on LoginException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fillDemo(String username) {
    setState(() {
      _showCode.text = MockShowService.demoShowCode;
      _username.text = username;
      _pin.text = MockShowService.demoPin;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMock = widget.service is MockShowService;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.theater_comedy, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('Show Assistant',
                      textAlign: TextAlign.center, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text('Crew sign-in',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _showCode,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Show code',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _username,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _loading ? null : _signIn(),
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _loading ? null : _signIn,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: _loading
                        ? const SizedBox(
                            width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Sign in'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => AudienceScreen(showName: widget.service.showName),
                    )),
                    child: const Text('Join as audience instead'),
                  ),
                  if (isMock) ...[
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Demo accounts', style: theme.textTheme.titleSmall),
                            const SizedBox(height: 4),
                            Text(
                              'Show code ${MockShowService.demoShowCode}, PIN ${MockShowService.demoPin}. Tap one to fill in.',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final account in MockShowService.demoAccounts)
                                  ActionChip(
                                    label: Text('${account.username} · ${account.roleLabel}'),
                                    onPressed: () => _fillDemo(account.username),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
