import 'package:flutter/material.dart';

import '../services/show_service.dart';
import '../theme.dart';
import 'audience_screen.dart';
import 'login_screen.dart';

/// First screen: audience join with just a show code. Staff sign-in is a
/// smaller link at the bottom.
class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key, required this.service});

  final ShowService service;

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _code = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final show = await widget.service.joinAsAudience(_code.text);
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => AudienceScreen(service: widget.service, show: show),
      ));
    } on LoginException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: playbillTheme(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Playbill.curtain, Playbill.bg],
              stops: [0, 0.55],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(Icons.theater_comedy, size: 56, color: Playbill.gold),
                            const SizedBox(height: 16),
                            const Text(
                              'WELCOME TO THE THEATRE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Playbill.gold,
                                letterSpacing: 3,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Join the show',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: Playbill.serif,
                                fontSize: 40,
                                color: Playbill.cream,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Enter the code on your ticket or the foyer screen.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Playbill.muted, fontSize: 15),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _code,
                              textAlign: TextAlign.center,
                              textCapitalization: TextCapitalization.characters,
                              autocorrect: false,
                              maxLength: 8,
                              onSubmitted: (_) => _join(),
                              style: const TextStyle(
                                fontSize: 32,
                                letterSpacing: 10,
                                fontWeight: FontWeight.w700,
                                color: Playbill.cream,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'CODE',
                                counterText: '',
                                contentPadding: EdgeInsets.symmetric(vertical: 18),
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(_error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFFFF8A80))),
                            ],
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _loading ? null : _join,
                              style: FilledButton.styleFrom(
                                backgroundColor: Playbill.gold,
                                foregroundColor: Playbill.bg,
                                minimumSize: const Size.fromHeight(56),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Playbill.bg))
                                  : const Text('Join',
                                      style: TextStyle(
                                          fontFamily: Playbill.serif, fontSize: 20)),
                            ),
                            if (widget.service is MockShowService) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Demo code: ${MockShowService.demoShowCode}',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Playbill.muted, fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => StaffLoginScreen(service: widget.service),
                    )),
                    icon: const Icon(Icons.badge_outlined, color: Playbill.muted),
                    label: const Text('Crew & staff sign in',
                        style: TextStyle(color: Playbill.muted)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
