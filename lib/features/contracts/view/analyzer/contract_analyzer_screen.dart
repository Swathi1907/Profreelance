import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../viewmodel/analyzer_viewmodel.dart';
import 'analysis_result_view.dart';

class ContractAnalyzerScreen extends ConsumerStatefulWidget {
  const ContractAnalyzerScreen({super.key, this.projectId});
  final String? projectId;

  @override
  ConsumerState<ContractAnalyzerScreen> createState() => _ContractAnalyzerScreenState();
}

class _ContractAnalyzerScreenState extends ConsumerState<ContractAnalyzerScreen> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(analyzerViewModelProvider(widget.projectId ?? ''));
    if (_c.text != vm.text) _c.text = vm.text;

    Widget input = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (vm.project != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PfChip('Linked to ${vm.project!.name}  ·  ${vm.client?.name ?? ''}', color: context.cs.primary, icon: Icons.link),
        ),
      TextField(
        controller: _c,
        onChanged: (v) => vm.text = v,
        minLines: 12,
        maxLines: 18,
        decoration: const InputDecoration(hintText: 'Paste the contract your client sent. Numbered clauses give the best results.', alignLabelWithHint: true),
      ),
      const SizedBox(height: 12),
      Wrap(spacing: 10, runSpacing: 10, children: [
        OutlinedButton.icon(onPressed: vm.loadSample, icon: const Icon(Icons.science_outlined), label: const Text('Load sample contract')),
        OutlinedButton.icon(onPressed: () => toast(context, 'PDF and DOCX text extraction runs on the server in the full build. Paste text here for now.'), icon: const Icon(Icons.upload_file), label: const Text('Upload PDF')),
      ]),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: vm.running ? null : () {
          vm.setText(_c.text);
          vm.analyze();
        },
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Analyse contract'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
      ),
    ]);

    Widget progress = PfCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Analysing', style: context.tt.titleMedium),
        const SizedBox(height: 14),
        for (var i = 0; i < AnalyzerViewModel.stages.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              SizedBox(
                width: 22,
                height: 22,
                child: i < vm.stage
                    ? Icon(Icons.check_circle, color: context.pf.success, size: 22)
                    : (i == vm.stage ? const CircularProgressIndicator(strokeWidth: 2.4) : Icon(Icons.circle_outlined, color: context.cs.outline, size: 20)),
              ),
              const SizedBox(width: 12),
              Text(AnalyzerViewModel.stages[i], style: TextStyle(fontWeight: i == vm.stage ? FontWeight.w800 : FontWeight.w500)),
            ]),
          ),
      ]),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Analyse client contract'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/contracts'))),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 40), children: [
            Text('Paste a contract to extract its clauses, spot one-sided terms, find what is missing and get plain-English explanations.', style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant, height: 1.4)),
            const SizedBox(height: 16),
            if (vm.running) progress else if (vm.result != null) AnalysisResultView(vm: vm) else input,
          ]),
        ),
      ),
    );
  }
}
