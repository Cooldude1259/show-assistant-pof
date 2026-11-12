import 'package:flutter/material.dart';

import '../theme.dart';

/// Bordered box used for list items backstage.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.onTap, this.highlight});

  final Widget child;
  final VoidCallback? onTap;

  /// Optional coloured left edge.
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Backstage.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: highlight ?? Backstage.border, width: highlight == null ? 1 : 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: const TextStyle(
                color: Backstage.accent,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                fontSize: 13,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class MutedText extends StatelessWidget {
  const MutedText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Backstage.textMuted)),
    );
  }
}

/// Simple multi-line text editor dialog. Returns the new text, or null if
/// cancelled.
Future<String?> showNoteDialog(
  BuildContext context, {
  required String title,
  required String initial,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _NoteDialog(title: title, initial: initial),
  );
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.title, required this.initial});

  final String title;
  final String initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Backstage.surfaceHigh,
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 3,
        maxLines: 6,
        decoration: const InputDecoration(hintText: 'Add a note…'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
