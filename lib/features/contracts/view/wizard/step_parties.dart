import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../domain/services/contract_inputs.dart';
import '../../viewmodel/contract_wizard_viewmodel.dart';

class StepParties extends StatelessWidget {
  const StepParties({super.key, required this.vm});
  final ContractWizardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final i = vm.inputs;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PfSelectField<String>(
        label: 'Project',
        icon: Icons.folder_outlined,
        value: vm.projectId,
        options: [for (final p in vm.projects) p.id],
        labelOf: vm.projectName,
        error: vm.errors['project'],
        onSelected: vm.selectProject,
      ),
      if (i == null)
        const Padding(padding: EdgeInsets.only(top: 24), child: Text('Choose the project first. Its details, milestones and client history pre-fill the next steps.'))
      else ...[
        const SizedBox(height: 14),
        _ClientBanner(i: i),
        const FormSectionLabel('Freelancer'),
        PfField(label: 'Legal name', initial: i.freelancerName, onChanged: (v) => vm.update((x) => x.freelancerName = v)),
        const FieldGap(),
        PfSelectField<String>(label: 'Entity type', value: i.freelancerEntity, options: kEntityTypes, onSelected: (v) => vm.update((x) => x.freelancerEntity = v)),
        const FieldGap(),
        PfField(label: 'Address', initial: i.freelancerAddress, onChanged: (v) => vm.update((x) => x.freelancerAddress = v)),
        const FieldGap(),
        PfField(label: 'GSTIN (optional)', initial: i.freelancerGstin, capitalize: TextCapitalization.characters, onChanged: (v) => vm.update((x) => x.freelancerGstin = v)),
        const FormSectionLabel('Client'),
        PfField(label: 'Legal name of the client', initial: i.clientLegalName, error: vm.errors['clientName'], onChanged: (v) => vm.update((x) => x.clientLegalName = v)),
        const FieldGap(),
        PfSelectField<String>(label: 'Entity type', value: i.clientEntity, options: kEntityTypes, onSelected: (v) => vm.update((x) => x.clientEntity = v)),
        const FieldGap(),
        PfField(label: 'Registered address', initial: i.clientAddress, onChanged: (v) => vm.update((x) => x.clientAddress = v)),
        const FieldGap(),
        PfField(label: 'Client GSTIN (optional)', initial: i.clientGstin, capitalize: TextCapitalization.characters, onChanged: (v) => vm.update((x) => x.clientGstin = v)),
        const FieldGap(),
        PfField(label: 'Authorised signatory (name and designation)', initial: i.clientSignatory, onChanged: (v) => vm.update((x) => x.clientSignatory = v)),
        const FormSectionLabel('Agreement'),
        const FieldLabel('Contract type'),
        ChoiceRow(options: kContractTypes, value: i.contractType, onChanged: (v) => vm.update((x) => x.contractType = v)),
        const FieldGap(),
        PfDateField(label: 'Effective date', value: i.effectiveDate, onChanged: (d) => vm.update((x) => x.effectiveDate = d)),
        const FieldGap(),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: PfField(label: 'Governing law', initial: i.governingLaw, onChanged: (v) => vm.update((x) => x.governingLaw = v))),
          const SizedBox(width: 12),
          Expanded(child: PfField(label: 'Seat / city', initial: i.city, onChanged: (v) => vm.update((x) => x.city = v))),
        ]),
        const FieldGap(),
        PfSelectField<String>(label: 'Dispute resolution', value: i.disputeMode, options: kDisputeModes, onSelected: (v) => vm.update((x) => x.disputeMode = v)),
      ],
    ]);
  }
}

class _ClientBanner extends StatelessWidget {
  const _ClientBanner({required this.i});
  final ContractInputs i;

  @override
  Widget build(BuildContext context) {
    final s = i.clientScore;
    return PfCard(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Row(children: [
        if (s != null) ScoreRing(score: s.overall, size: 58, stroke: 6) else const Icon(Icons.person_search_outlined, size: 32),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            s == null
                ? 'No history with this client yet, so standard terms are used.'
                : '${i.client?.name} is rated ${s.tier} (${s.overall.round()}). Terms are pre-set from that: ${s.suggestedAdvance}% advance and ${s.suggestedLateFee}% monthly late fee. You can change them in the next steps.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ]),
    );
  }
}
