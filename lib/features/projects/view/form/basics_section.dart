import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../viewmodel/project_form_viewmodel.dart';

class BasicsSection extends StatelessWidget {
  const BasicsSection({super.key, required this.vm});
  final ProjectFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    final suggestions = vm.clientSuggestions;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FormSectionLabel('Project basics'),
      PfField(label: 'Project Title', icon: Icons.folder_outlined, initial: vm.title, error: vm.errors['title'], onChanged: (v) => vm.update(() => vm.title = v)),
      const FieldGap(),
      PfField(label: 'Enter Client Name', icon: Icons.person_outline, initial: vm.clientName, error: vm.errors['client'], capitalize: TextCapitalization.words, onChanged: (v) => vm.update(() => vm.clientName = v)),
      if (suggestions.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, children: [
          for (final s in suggestions) ActionChip(label: Text(s), onPressed: () => vm.update(() => vm.clientName = s), visualDensity: VisualDensity.compact),
        ]),
        Text('Existing clients: tap to reuse one (their reliability history carries over).', style: Theme.of(context).textTheme.bodySmall),
      ],
      const FieldGap(),
      DomainPickerField(
        value: vm.domain,
        customDomains: vm.customDomains,
        error: vm.errors['domain'],
        onSelected: (d) => vm.update(() => vm.domain = d),
        onAddCustom: vm.addCustomDomain,
      ),
      const FieldGap(),
      PfField(key: ValueKey('sub${vm.domain}'), label: 'Sub-domain', initial: vm.subDomain, onChanged: (v) => vm.update(() => vm.subDomain = v)),
      if (vm.subDomainHints.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, children: [
          for (final h in vm.subDomainHints) ActionChip(label: Text(h), onPressed: () => vm.update(() => vm.subDomain = h), visualDensity: VisualDensity.compact),
        ]),
      ],
      const FieldGap(),
      PfField(label: 'What should the client achieve through this project?', initial: vm.objective, minLines: 3, maxLines: 5, onChanged: (v) => vm.update(() => vm.objective = v)),
      const FieldGap(),
      PfField(
        label: 'Describe the overall project, functionality, and purpose.',
        initial: vm.description,
        minLines: 4,
        maxLines: 7,
        maxLength: 1000,
        error: vm.errors['description'],
        onChanged: (v) => vm.update(() => vm.description = v),
      ),
    ]);
  }
}
