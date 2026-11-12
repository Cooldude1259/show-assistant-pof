import 'package:flutter/material.dart';

import '../services/show_service.dart';
import '../theme.dart';

/// Crew/staff sign-in. Reached from the audience join screen.
class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key, required this.service});

  final ShowService service;

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
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
    if (_loading) return;
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
      // The app root now shows the crew/caller screen underneath this one,
      // so close the sign-in page to reveal it.
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
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
    final isMock = widget.service is MockShowService;

    return Scaffold(
      appBar: AppBar(title: const Text('Crew & staff')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Sign in',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Use the show code and PIN from your stage manager.',
                      style: TextStyle(color: Backstage.textMuted)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _showCode,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Show code',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
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
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _signIn(),
                    decoration: const InputDecoration(
                      labelText: 'PIN',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(
                            color: Backstage.danger, fontWeight: FontWeight.w700)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _loading ? null : _signIn,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Backstage.black))
                        : const Text('Sign in'),
                  ),
                  if (isMock) ...[
                    const SizedBox(height: 28),
                    const Text('DEMO ACCOUNTS',
                        style: TextStyle(
                            color: Backstage.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text(
                      'Show code ${MockShowService.demoShowCode}, PIN ${MockShowService.demoPin}. Tap one to fill in.',
                      style: TextStyle(color: Backstage.textMuted, fontSize: 13),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
