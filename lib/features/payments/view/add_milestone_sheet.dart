import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/payments_viewmodel.dart';

Future<void> showAddMilestoneSheet(BuildContext context, {String? projectId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AddMilestone(projectId: projectId),
  );
}

class _AddMilestone extends ConsumerStatefulWidget {
  const _AddMilestone({this.projectId});
  final String? projectId;
  @override
  ConsumerState<_AddMilestone> createState() => _AddMilestoneState();
}

class _AddMilestoneState extends ConsumerState<_AddMilestone> {
  String? _project;
  String _title = '';
  String _amount = '';
  String _clause = '';
  DateTime? _due;
  String? _error;

  @override
  void initState() {
    super.initState();
    _project = widget.projectId;
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(paymentsViewModelProvider);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add milestone', style: context.tt.titleLarge),
            const SizedBox(height: 16),
            if (widget.projectId == null) ...[
              PfSelectField<String>(
                label: 'Project',
                value: _project,
                options: [for (final p in vm.projects) p.id],
                labelOf: vm.projectName,
                onSelected: (v) => setState(() => _project = v),
              ),
              const FieldGap(),
            ],
            PfField(label: 'Milestone title', onChanged: (v) => _title = v),
            const FieldGap(),
            PfField(label: 'Amount', prefixText: '₹ ', decimal: true, onChanged: (v) => _amount = v),
            const FieldGap(),
            PfDateField(label: 'Due date', value: _due, onChanged: (d) => setState(() => _due = d)),
            const FieldGap(),
            PfField(label: 'Contract clause (optional)', hint: 'e.g. 7.2', onChanged: (v) => _clause = v),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: TextStyle(color: context.pf.danger))),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final amt = double.tryParse(_amount) ?? 0;
                if (_project == null || _title.trim().isEmpty || amt <= 0 || _due == null) {
                  setState(() => _error = 'Choose a project, then enter a title, amount and due date.');
                  return;
                }
                vm.addMilestone(projectId: _project!, title: _title.trim(), amount: amt, due: _due!, clause: _clause.trim());
                Navigator.pop(context);
                toast(context, 'Milestone added.');
              },
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: const Text('Add milestone'),
            ),
          ]),
        ),
      ),
    );
  }
}
