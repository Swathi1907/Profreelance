import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../core/utils/format.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../../../domain/domain_providers.dart';
import '../../../domain/services/client_scoring.dart';
import '../../../domain/services/negotiation.dart';

class ChatMessage {
  ChatMessage({required this.fromUser, required this.text, this.reply, this.animate = false});
  final bool fromUser;
  final String text;
  final NegotiationReply? reply;
  final bool animate;
}

/// One conversation per project. The assistant sees that project's budget,
/// hours, revisions and the client's reliability score.
class NegotiationViewModel extends BaseViewModel {
  NegotiationViewModel(super.ref, this.projectId) {
    watch(portfolioProvider);
    final p = project;
    messages.add(ChatMessage(
      fromUser: false,
      text: p == null
          ? 'Pick a project and tell me what the client is asking for.'
          : 'I have ${p.name} open: ${inr(p.budget)} for about ${p.estimatedHours.round()} hours, with ${p.revisions} revisions included. What is ${client?.name ?? 'the client'} asking for?',
    ));
  }

  final String projectId;
  final List<ChatMessage> messages = [];
  Tone tone = Tone.friendly;
  bool typing = false;

  static const quickPrompts = [
    'The client wants a 20% discount',
    'They want delivery 2 weeks earlier',
    'Client asks for an extra feature at no cost',
    'They want to pay 60 days after delivery',
  ];

  Project? get project => ref.read(portfolioProvider).project(projectId);
  Client? get client => project == null ? null : ref.read(portfolioProvider).client(project!.clientId);
  ClientScore? get score => client == null ? null : ref.read(scoresProvider)[client!.id];

  void setTone(Tone t) {
    tone = t;
    refresh();
  }

  Future<void> send(String text) async {
    final t = text.trim();
    if (t.isEmpty || typing) return;
    messages.add(ChatMessage(fromUser: true, text: t));
    typing = true;
    refresh();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (isDisposed) return;
    final reply = NegotiationEngine.respond(
      message: t,
      project: project,
      client: client,
      score: score,
      hourlyRate: ref.read(preferencesProvider).hourlyRate,
      tone: tone,
    );
    messages.add(ChatMessage(fromUser: false, text: reply.text, reply: reply, animate: true));
    typing = false;
    refresh();
  }

  void draft(Strategy s) {
    final d = NegotiationEngine.draftFor(s, tone, client?.name ?? 'the client');
    messages.add(ChatMessage(
      fromUser: false,
      text: 'Here is a ready-to-send reply for Option ${s.option}.',
      reply: NegotiationReply(text: '', draft: d),
      animate: true,
    ));
    refresh();
  }
}

final negotiationViewModelProvider =
    ChangeNotifierProvider.autoDispose.family<NegotiationViewModel, String>((ref, id) => NegotiationViewModel(ref, id));
