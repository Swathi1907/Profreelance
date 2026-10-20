import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/services/negotiation.dart';
import '../viewmodel/negotiation_viewmodel.dart';
import 'chat_widgets.dart';

/// The chat itself. Used in the project workspace and on the Negotiate tab.
class NegotiationPanel extends ConsumerStatefulWidget {
  const NegotiationPanel({super.key, required this.projectId});
  final String projectId;

  @override
  ConsumerState<NegotiationPanel> createState() => _NegotiationPanelState();
}

class _NegotiationPanelState extends ConsumerState<NegotiationPanel> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _lastCount = 0;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void _send(NegotiationViewModel vm, String text) {
    _input.clear();
    vm.send(text);
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(negotiationViewModelProvider(widget.projectId));
    final count = vm.messages.length + (vm.typing ? 1 : 0);
    if (count != _lastCount) {
      _lastCount = count;
      _toEnd();
    }
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              const MonoLabel('Tone'),
              const SizedBox(width: 12),
              for (final t in Tone.values)
                Padding(padding: const EdgeInsets.only(right: 8), child: PfToggleChip(label: t.name[0].toUpperCase() + t.name.substring(1), selected: vm.tone == t, onTap: () => vm.setTone(t))),
            ]),
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              children: [
                for (final m in vm.messages)
                  if (m.fromUser)
                    UserBubble(m.text)
                  else
                    AssistantBubble(
                      text: m.text,
                      animate: m.animate && m == vm.messages.last,
                      child: m.reply == null ? null : ReplyExtras(reply: m.reply!, onDraft: vm.draft),
                    ),
                if (vm.typing) const TypingBubble(),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final q in NegotiationViewModel.quickPrompts)
                  Padding(padding: const EdgeInsets.only(right: 8), child: ActionChip(label: Text(q), onPressed: () => _send(vm, q))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  onSubmitted: (v) => _send(vm, v),
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(hintText: 'What did the client say?'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: vm.typing ? null : () => _send(vm, _input.text),
                style: IconButton.styleFrom(backgroundColor: context.isDark ? Pf.gold : Pf.maroon, foregroundColor: context.isDark ? Pf.ink : Colors.white, minimumSize: const Size(54, 54)),
                icon: const Icon(Icons.send),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
