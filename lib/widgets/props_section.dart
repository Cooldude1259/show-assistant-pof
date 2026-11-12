import 'package:flutter/material.dart';

import '../models.dart';
import '../services/show_service.dart';
import '../theme.dart';
import 'panel.dart';

/// Expandable props block shown at the top of each scene in the script, for
/// stage crew. Lists what goes on this scene, what's needed next, and what
/// should come back.
class PropsSection extends StatefulWidget {
  const PropsSection({
    super.key,
    required this.service,
    required this.user,
    required this.scene,
    this.nextScene,
  });

  final ShowService service;
  final StaffUser user;
  final Scene scene;
  final Scene? nextScene;

  @override
  State<PropsSection> createState() => _PropsSectionState();
}

class _PropsSectionState extends State<PropsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final props = service.props;
    final scene = widget.scene;
    final next = widget.nextScene;
    final thisScene = props.where((p) => p.onSceneId == scene.id).toList();
    final nextUp = next == null ? <Prop>[] : props.where((p) => p.onSceneId == next.id).toList();
    final comingBack = props.where((p) => p.offSceneId == scene.id).toList();
    final canEdit = widget.user.canEditProps;
    final outstanding = thisScene.where((p) => !p.isSet).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Backstage.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Backstage.accent, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, color: Backstage.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Props · ${thisScene.length} on, ${comingBack.length} back'
                      '${outstanding > 0 ? ' · $outstanding not set' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: Backstage.accent, size: 28),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    'Needed this scene',
                    trailing: canEdit
                        ? TextButton.icon(
                            onPressed: () => _openEditor(context, null),
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          )
                        : null,
                  ),
                  if (thisScene.isEmpty) const MutedText('Nothing goes on this scene.'),
                  for (final prop in thisScene)
                    _PropTile(
                      service: service,
                      prop: prop,
                      checked: prop.isSet,
                      checkLabel: 'Set',
                      onChecked: () => service.togglePropSet(prop.id),
                      onEdit: canEdit ? () => _openEditor(context, prop) : null,
                    ),
                  if (next != null) ...[
                    SectionHeader('Needed next · ${next.title}'),
                    if (nextUp.isEmpty) const MutedText('Nothing goes on next scene.'),
                    for (final prop in nextUp)
                      _PropTile(
                        service: service,
                        prop: prop,
                        checked: prop.isSet,
                        checkLabel: 'Ready',
                        onChecked: () => service.togglePropSet(prop.id),
                        onEdit: canEdit ? () => _openEditor(context, prop) : null,
                      ),
                  ],
                  const SectionHeader('Expected back after this scene'),
                  if (comingBack.isEmpty) const MutedText('Nothing due back this scene.'),
                  for (final prop in comingBack)
                    _PropTile(
                      service: service,
                      prop: prop,
                      checked: prop.returned,
                      checkLabel: 'Back',
                      onChecked: () => service.togglePropReturned(prop.id),
                      onEdit: canEdit ? () => _openEditor(context, prop) : null,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, Prop? existing) async {
    final service = widget.service;
    final result = await showDialog<_PropEdit>(
      context: context,
      builder: (_) => _PropEditorDialog(
        scenes: service.scenes,
        existing: existing,
        defaultSceneId: widget.scene.id,
      ),
    );
    if (result == null) return;
    if (result.delete && existing != null) {
      service.removeProp(existing.id);
    } else if (result.prop != null) {
      service.saveProp(result.prop!);
    }
  }
}

class _PropTile extends StatelessWidget {
  const _PropTile({
    required this.service,
    required this.prop,
    required this.checked,
    required this.checkLabel,
    required this.onChecked,
    this.onEdit,
  });

  final ShowService service;
  final Prop prop;
  final bool checked;
  final String checkLabel;
  final VoidCallback onChecked;
  final VoidCallback? onEdit;

  String _sceneShort(String? id) {
    if (id == null) return 'end of show';
    final scene = service.sceneById(id);
    return scene == null ? '?' : '${scene.act}.${scene.number} ${scene.title}';
  }

  @override
  Widget build(BuildContext context) {
    return Panel(
      onTap: onEdit,
      highlight: checked ? Backstage.go : null,
      child: Row(
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Backstage.text, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(prop.side.code,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(prop.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                Text(
                  'On ${_sceneShort(prop.onSceneId)} · Back ${_sceneShort(prop.offSceneId)}',
                  style: const TextStyle(color: Backstage.textMuted, fontSize: 13),
                ),
                if (prop.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(prop.note),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Checkbox(value: checked, onChanged: (_) => onChecked()),
              Text(checkLabel, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PropEdit {
  const _PropEdit.save(Prop this.prop) : delete = false;
  const _PropEdit.delete()
      : prop = null,
        delete = true;

  final Prop? prop;
  final bool delete;
}

class _PropEditorDialog extends StatefulWidget {
  const _PropEditorDialog({
    required this.scenes,
    required this.existing,
    required this.defaultSceneId,
  });

  final List<Scene> scenes;
  final Prop? existing;
  final String defaultSceneId;

  @override
  State<_PropEditorDialog> createState() => _PropEditorDialogState();
}

class _PropEditorDialogState extends State<_PropEditorDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');
  late PropSide _side = widget.existing?.side ?? PropSide.stageLeft;
  late String _onSceneId = widget.existing?.onSceneId ?? widget.defaultSceneId;
  late String? _offSceneId =
      widget.existing == null ? widget.defaultSceneId : widget.existing!.offSceneId;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final existing = widget.existing;
    Navigator.of(context).pop(_PropEdit.save(Prop(
      id: existing?.id ?? 'p${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      onSceneId: _onSceneId,
      offSceneId: _offSceneId,
      side: _side,
      note: _note.text.trim(),
      isSet: existing?.isSet ?? false,
      returned: existing?.returned ?? false,
    )));
  }

  @override
  Widget build(BuildContext context) {
    final sceneItems = [
      for (final scene in widget.scenes)
        DropdownMenuItem<String>(
          value: scene.id,
          child: Text('${scene.act}.${scene.number} ${scene.title}'),
        ),
    ];

    return AlertDialog(
      backgroundColor: Backstage.surfaceHigh,
      title: Text(widget.existing == null ? 'Add prop' : 'Edit prop'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: widget.existing == null,
              decoration: const InputDecoration(labelText: 'Prop name'),
            ),
            const SizedBox(height: 12),
            _labelled(
              'Props table',
              DropdownButton<PropSide>(
                value: _side,
                isExpanded: true,
                items: [
                  for (final side in PropSide.values)
                    DropdownMenuItem(value: side, child: Text(side.label)),
                ],
                onChanged: (v) => setState(() => _side = v ?? _side),
              ),
            ),
            _labelled(
              'Goes on in',
              DropdownButton<String>(
                value: _onSceneId,
                isExpanded: true,
                items: sceneItems,
                onChanged: (v) => setState(() => _onSceneId = v ?? _onSceneId),
              ),
            ),
            _labelled(
              'Comes back after',
              DropdownButton<String?>(
                value: _offSceneId,
                isExpanded: true,
                items: [
                  for (final item in sceneItems)
                    DropdownMenuItem<String?>(value: item.value, child: item.child),
                  const DropdownMenuItem<String?>(value: null, child: Text('End of show')),
                ],
                onChanged: (v) => setState(() => _offSceneId = v),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.existing != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(const _PropEdit.delete()),
            style: TextButton.styleFrom(foregroundColor: Backstage.danger),
            child: const Text('Delete'),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Widget _labelled(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Backstage.textMuted, fontSize: 13)),
          child,
        ],
      ),
    );
  }
}
