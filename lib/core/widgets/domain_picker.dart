import 'package:flutter/material.dart';

import '../../data/catalog/catalog.dart';
import '../theme/app_colors.dart';

/// Searchable domain field. Shows the built-in catalogue (70+ entries) and the
/// user's own domains, and lets the user add a new one on the spot.
class DomainPickerField extends StatelessWidget {
  const DomainPickerField({
    super.key,
    required this.value,
    required this.customDomains,
    required this.onSelected,
    required this.onAddCustom,
    this.error,
  });

  final String value;
  final List<String> customDomains;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onAddCustom;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final r = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _DomainSheet(selected: value, custom: customDomains, onAddCustom: onAddCustom),
        );
        if (r != null) onSelected(r);
      },
      child: InputDecorator(
        isEmpty: value.isEmpty,
        decoration: InputDecoration(
          labelText: 'Project Domain',
          errorText: error,
          prefixIcon: Icon(Icons.category_outlined, color: context.cs.primary),
          suffixIcon: const Icon(Icons.search),
        ),
        child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _DomainSheet extends StatefulWidget {
  const _DomainSheet({required this.selected, required this.custom, required this.onAddCustom});
  final String selected;
  final List<String> custom;
  final ValueChanged<String> onAddCustom;

  @override
  State<_DomainSheet> createState() => _DomainSheetState();
}

class _DomainSheetState extends State<_DomainSheet> {
  String _q = '';

  List<MapEntry<String, List<String>>> get _groups {
    final q = _q.trim().toLowerCase();
    final all = <MapEntry<String, List<String>>>[
      if (widget.custom.isNotEmpty) MapEntry('My domains', widget.custom),
      ...kDomainCatalog.entries,
    ];
    if (q.isEmpty) return all;
    return [
      for (final g in all)
        if (g.value.any((d) => d.toLowerCase().contains(q))) MapEntry(g.key, g.value.where((d) => d.toLowerCase().contains(q)).toList()),
    ];
  }

  bool get _exact {
    final q = _q.trim().toLowerCase();
    return q.isEmpty || [...widget.custom, ...kDomainCatalog.values.expand((e) => e)].any((d) => d.toLowerCase() == q);
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _q = v),
                decoration: const InputDecoration(hintText: 'Search 70+ domains, or type your own', prefixIcon: Icon(Icons.search)),
              ),
            ),
            Flexible(
              child: ListView(shrinkWrap: true, children: [
                if (!_exact)
                  ListTile(
                    leading: CircleAvatar(backgroundColor: context.cs.primary, foregroundColor: context.cs.onPrimary, child: const Icon(Icons.add)),
                    title: Text('Add "${_q.trim()}" as my own domain'),
                    subtitle: const Text('Saved for your next projects'),
                    onTap: () {
                      widget.onAddCustom(_q.trim());
                      Navigator.pop(context, _q.trim());
                    },
                  ),
                for (final g in groups) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                    child: Text(g.key.toUpperCase(), style: monoStyle(context, size: 10.5)),
                  ),
                  for (final d in g.value)
                    ListTile(
                      dense: true,
                      title: Text(d),
                      trailing: d == widget.selected ? Icon(Icons.check_circle, color: context.cs.primary) : null,
                      onTap: () => Navigator.pop(context, d),
                    ),
                ],
                if (groups.isEmpty && _exact) const Padding(padding: EdgeInsets.all(24), child: Text('No domains match.')),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
