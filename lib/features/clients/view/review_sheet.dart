import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/clients_viewmodel.dart';

Future<void> showReviewSheet(BuildContext context, ClientDetailViewModel vm) {
  return showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => _ReviewSheet(vm: vm));
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({required this.vm});
  final ClientDetailViewModel vm;
  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  double _punct = 4, _stab = 4, _comm = 4, _overall = 4;
  String _project = '';
  String _note = '';

  Widget _slider(String label, String hint, double v, ValueChanged<double> onChanged) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
          Text('${v.round()} / 5', style: monoStyle(context, size: 11)),
        ]),
        Text(hint, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
        Slider(value: v, min: 1, max: 5, divisions: 4, onChanged: onChanged),
      ]);

  @override
  Widget build(BuildContext context) {
    final projects = widget.vm.projects;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Record experience', style: context.tt.titleLarge),
            const SizedBox(height: 12),
            if (projects.isNotEmpty) ...[
              PfSelectField<String>(
                label: 'Project (optional)',
                value: _project,
                options: ['', for (final p in projects) p.name],
                labelOf: (v) => v.isEmpty ? 'General' : v,
                onSelected: (v) => setState(() => _project = v),
              ),
              const SizedBox(height: 8),
            ],
            _slider('Payment punctuality', 'How reliably were invoices paid?', _punct, (v) => setState(() => _punct = v)),
            _slider('Requirement stability', 'Did the scope stay put?', _stab, (v) => setState(() => _stab = v)),
            _slider('Communication', 'Clear, timely, respectful?', _comm, (v) => setState(() => _comm = v)),
            _slider('Overall experience', 'Would you work with them again?', _overall, (v) => setState(() => _overall = v)),
            PfField(label: 'Note (optional)', minLines: 2, maxLines: 4, onChanged: (v) => _note = v),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                widget.vm.addReview(
                  punctuality: _punct.round(),
                  stability: _stab.round(),
                  communication: _comm.round(),
                  overall: _overall.round(),
                  projectName: _project,
                  note: _note.trim(),
                );
                Navigator.pop(context);
                toast(context, 'Experience recorded. The score has been updated.');
              },
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: const Text('Save rating'),
            ),
          ]),
        ),
      ),
    );
  }
}

