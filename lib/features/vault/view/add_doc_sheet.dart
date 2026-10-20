import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../viewmodel/vault_viewmodel.dart';

Future<void> showAddDocSheet(BuildContext context, {String? projectId}) {
  return showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => _AddDoc(projectId: projectId));
}

/// Simulated upload: the real app would send the file to a Supabase Storage bucket.
class _AddDoc extends ConsumerStatefulWidget {
  const _AddDoc({this.projectId});
  final String? projectId;
  @override
  ConsumerState<_AddDoc> createState() => _AddDocState();
}

class _AddDocState extends ConsumerState<_AddDoc> {
  String _name = '';
  DocCategory _cat = DocCategory.requirements;
  String? _project;
  String _tags = '';
  double _progress = 0;
  bool _uploading = false;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _project = widget.projectId;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _upload(VaultViewModel vm) {
    if (_name.trim().isEmpty) {
      setState(() => _error = 'Enter a file name, for example brief.pdf.');
      return;
    }
    setState(() {
      _uploading = true;
      _error = null;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 90), (t) {
      if (!mounted) return;
      setState(() => _progress = (_progress + 0.1).clamp(0, 1));
      if (_progress >= 1) {
        t.cancel();
        vm.add(
          name: _name.trim(),
          category: _cat,
          projectId: _project,
          sizeKb: 120 + (_name.length * 37) % 900,
          tags: _tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        );
        Navigator.pop(context);
        toast(context, 'Stored and encrypted: ${_name.trim()}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(vaultViewModelProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add to vault', style: context.tt.titleLarge),
            const SizedBox(height: 4),
            Text('Prototype upload: enter the file name. The Supabase build opens the file picker.', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            PfField(label: 'File name', icon: Icons.insert_drive_file_outlined, capitalize: TextCapitalization.none, onChanged: (v) => _name = v),
            const FieldGap(),
            PfSelectField<DocCategory>(label: 'Category', value: _cat, options: DocCategory.values, labelOf: (c) => c.label, onSelected: (c) => setState(() => _cat = c)),
            const FieldGap(),
            if (widget.projectId == null)
              PfSelectField<String>(
                label: 'Linked project',
                value: _project ?? '',
                options: ['', for (final p in vm.projects) p.id],
                labelOf: (id) => id.isEmpty ? 'General (no project)' : vm.projectName(id),
                onSelected: (id) => setState(() => _project = id.isEmpty ? null : id),
              ),
            if (widget.projectId == null) const FieldGap(),
            PfField(label: 'Tags (comma separated)', capitalize: TextCapitalization.none, onChanged: (v) => _tags = v),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: TextStyle(color: context.pf.danger))),
            const SizedBox(height: 16),
            if (_uploading) ...[
              AnimatedBar(value: _progress, height: 10),
              const SizedBox(height: 8),
              Text('Encrypting and uploading ${(_progress * 100).round()}%', style: monoStyle(context, size: 11)),
            ] else
              FilledButton.icon(onPressed: () => _upload(vm), icon: const Icon(Icons.lock_outline), label: const Text('Encrypt and store'), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52))),
          ]),
        ),
      ),
    );
  }
}
