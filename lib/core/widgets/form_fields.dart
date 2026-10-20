import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../utils/format.dart';

/// Small caps section label, as on the original "Create New Project" screen.
class FormSectionLabel extends StatelessWidget {
  const FormSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 12),
        child: Text(text.toUpperCase(),
            style: TextStyle(
              color: context.isDark ? Pf.gold : Pf.maroon,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            )),
      );
}

class FieldGap extends StatelessWidget {
  const FieldGap({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(height: 14);
}

/// Text input used by every form. Errors come from the ViewModel.
class PfField extends StatelessWidget {
  const PfField({
    super.key,
    required this.label,
    this.initial = '',
    this.onChanged,
    this.icon,
    this.keyboard,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.helper,
    this.error,
    this.suffixText,
    this.prefixText,
    this.hint,
    this.digitsOnly = false,
    this.decimal = false,
    this.capitalize = TextCapitalization.sentences,
  });

  final String label;
  final String initial;
  final ValueChanged<String>? onChanged;
  final IconData? icon;
  final TextInputType? keyboard;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final String? helper;
  final String? error;
  final String? suffixText;
  final String? prefixText;
  final String? hint;
  final bool digitsOnly;
  final bool decimal;
  final TextCapitalization capitalize;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initial,
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textCapitalization: capitalize,
      keyboardType: keyboard ?? (digitsOnly ? TextInputType.number : (decimal ? const TextInputType.numberWithOptions(decimal: true) : (maxLines != 1 ? TextInputType.multiline : TextInputType.text))),
      inputFormatters: [
        if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
        if (decimal) FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        helperMaxLines: 2,
        errorText: error,
        errorMaxLines: 2,
        alignLabelWithHint: maxLines != 1,
        suffixText: suffixText,
        prefixText: prefixText,
        prefixIcon: icon == null ? null : Icon(icon, color: context.cs.primary),
      ),
    );
  }
}

Future<T?> showOptionSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  T? selected,
  String Function(T)? labelOf,
  bool searchable = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _OptionSheet<T>(title: title, options: options, selected: selected, labelOf: labelOf ?? (x) => x.toString(), searchable: searchable),
  );
}

class _OptionSheet<T> extends StatefulWidget {
  const _OptionSheet({required this.title, required this.options, required this.selected, required this.labelOf, required this.searchable});
  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final bool searchable;

  @override
  State<_OptionSheet<T>> createState() => _OptionSheetState<T>();
}

class _OptionSheetState<T> extends State<_OptionSheet<T>> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final items = widget.options.where((o) => widget.labelOf(o).toLowerCase().contains(_q.toLowerCase())).toList();
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(alignment: Alignment.centerLeft, child: Text(widget.title, style: context.tt.titleMedium)),
            ),
            if (widget.searchable)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _q = v),
                  decoration: const InputDecoration(hintText: 'Search', prefixIcon: Icon(Icons.search)),
                ),
              ),
            Flexible(
              child: ListView(shrinkWrap: true, children: [
                for (final o in items)
                  ListTile(
                    title: Text(widget.labelOf(o)),
                    trailing: o == widget.selected ? Icon(Icons.check_circle, color: context.cs.primary) : null,
                    onTap: () => Navigator.pop(context, o),
                  ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Tap-to-choose field that replaces a dropdown (sheet with optional search).
class PfSelectField<T> extends StatelessWidget {
  const PfSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
    this.labelOf,
    this.icon,
    this.error,
    this.helper,
    this.searchable = false,
  });

  final String label;
  final T? value;
  final List<T> options;
  final ValueChanged<T> onSelected;
  final String Function(T)? labelOf;
  final IconData? icon;
  final String? error;
  final String? helper;
  final bool searchable;

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '' : (labelOf ?? (x) => x.toString())(value as T);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final r = await showOptionSheet<T>(context, title: label, options: options, selected: value, labelOf: labelOf, searchable: searchable);
        if (r != null) onSelected(r);
      },
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          helperText: helper,
          prefixIcon: icon == null ? null : Icon(icon, color: context.cs.primary),
          suffixIcon: const Icon(Icons.expand_more),
        ),
        child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class PfDateField extends StatelessWidget {
  const PfDateField({super.key, required this.label, required this.value, required this.onChanged, this.error, this.firstDate, this.lastDate, this.helper});
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final String? error;
  final String? helper;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: value ?? now.add(const Duration(days: 30)),
          firstDate: firstDate ?? DateTime(now.year - 1),
          lastDate: lastDate ?? DateTime(now.year + 5),
        );
        if (d != null) onChanged(d);
      },
      child: InputDecorator(
        isEmpty: value == null,
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          helperText: helper,
          prefixIcon: Icon(Icons.calendar_today_outlined, color: context.cs.primary),
        ),
        child: Text(value == null ? '' : fmtDate(value!)),
      ),
    );
  }
}

class PfSwitchRow extends StatelessWidget {
  const PfSwitchRow({super.key, required this.title, required this.value, required this.onChanged, this.subtitle});
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          if (subtitle != null) Text(subtitle!, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
        ]),
      ),
      Switch(value: value, onChanged: onChanged),
    ]);
  }
}

/// Selectable pill. Used for single choice and multi choice groups.
class PfToggleChip extends StatelessWidget {
  const PfToggleChip({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = context.isDark ? Pf.gold : Pf.maroon;
    final on = context.isDark ? Pf.ink : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? fill : context.cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: selected ? fill : context.pf.cardLine),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (selected) ...[Icon(Icons.check, size: 15, color: on), const SizedBox(width: 5)],
            Text(label, style: TextStyle(color: selected ? on : context.cs.onSurface, fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}

class ChipMultiSelect extends StatelessWidget {
  const ChipMultiSelect({super.key, required this.options, required this.selected, required this.onToggle});
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final o in options) PfToggleChip(label: o, selected: selected.contains(o), onTap: () => onToggle(o))],
      );
}

class ChoiceRow extends StatelessWidget {
  const ChoiceRow({super.key, required this.options, required this.value, required this.onChanged});
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [for (final o in options) PfToggleChip(label: o, selected: o == value, onTap: () => onChanged(o))],
      );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
      );
}
