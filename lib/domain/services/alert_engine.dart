import '../../data/models/models.dart';
import '../../core/utils/format.dart';

/// Rule-based alert engine. Every alert has a stable id (type + entity) so a
/// dismissed alert stays dismissed until the underlying situation changes.
class AlertEngine {
  AlertEngine._();

  static List<AppAlert> generate(Portfolio d, {required int leadDays, required Set<String> dismissed, DateTime? at}) {
    final now = at ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final out = <AppAlert>[];

    for (final p in d.projects) {
      final clientName = d.client(p.clientId)?.name ?? 'client';

      if (p.status == ProjectStatus.inProgress) {
        final left = DateTime(p.dueDate.year, p.dueDate.month, p.dueDate.day).difference(today).inDays;
        if (left < 0) {
          out.add(AppAlert(
            id: 'deadline:${p.id}',
            type: AlertType.deadline,
            severity: Severity.high,
            title: '${p.name} is ${-left} days overdue',
            detail: 'Due ${fmtDate(p.dueDate)} for $clientName. Agree a new date or deliver.',
            route: '/projects/${p.id}',
          ));
        } else if (left <= leadDays) {
          out.add(AppAlert(
            id: 'deadline:${p.id}',
            type: AlertType.deadline,
            severity: left <= 3 ? Severity.high : Severity.medium,
            title: '${p.name} is due ${relDays(p.dueDate, now)}',
            detail: 'Deadline ${fmtDate(p.dueDate)} for $clientName.',
            route: '/projects/${p.id}',
          ));
        }

        // Burn rate vs progress: hours used compared with milestones done.
        final ms = d.milestonesOf(p.id);
        final progress = ms.isEmpty ? 0.0 : ms.where((m) => m.paidOn != null).length / ms.length;
        final burn = p.estimatedHours == 0 ? 0.0 : p.actualHours / p.estimatedHours;
        if (burn > 1.0 || (burn - progress > 0.25 && burn > 0.5)) {
          final over = ((burn - 1) * 100).round();
          out.add(AppAlert(
            id: 'estimation:${p.id}',
            type: AlertType.estimation,
            severity: burn > 1.15 ? Severity.high : Severity.medium,
            title: burn > 1
                ? '${p.name}: effort is $over% over the estimate'
                : '${p.name}: hours are running ahead of progress',
            detail:
                '${p.actualHours.round()}h used of ${p.estimatedHours.round()}h estimated, ${(progress * 100).round()}% of milestones paid. Consider a change order.',
            route: '/projects/${p.id}',
          ));
        }
      }

      if (p.changeRequests >= 3) {
        out.add(AppAlert(
          id: 'scope:${p.id}',
          type: AlertType.scope,
          severity: p.changeRequests >= 5 ? Severity.high : Severity.medium,
          title: '${p.name}: ${p.changeRequests} scope changes so far',
          detail: 'Frequent changes usually mean the budget needs revisiting. Raise a formal amendment.',
          route: '/projects/${p.id}/amend',
        ));
      }
    }

    for (final m in d.milestones) {
      final p = d.project(m.projectId);
      if (p == null || m.paidOn != null) continue;
      final days = DateTime(m.due.year, m.due.month, m.due.day).difference(today).inDays;
      if (days < 0) {
        out.add(AppAlert(
          id: 'payment:${m.id}',
          type: AlertType.payment,
          severity: days < -7 ? Severity.high : Severity.medium,
          title: '${inr(m.amount)} overdue from ${d.client(p.clientId)?.name ?? 'client'}',
          detail: '"${m.title}" on ${p.name} was due ${relDays(m.due, now)}.',
          route: '/payments',
        ));
      } else if (days <= 5) {
        out.add(AppAlert(
          id: 'payment:${m.id}',
          type: AlertType.payment,
          severity: Severity.low,
          title: 'Invoice ${inr(m.amount)} falls due ${relDays(m.due, now)}',
          detail: '"${m.title}" on ${p.name}. Send the invoice now.',
          route: '/payments',
        ));
      }
    }

    for (final c in d.contracts) {
      final p = d.project(c.projectId);
      if (p == null) continue;
      if (c.status == ContractStatus.amendmentPending) {
        out.add(AppAlert(
          id: 'contract:${c.id}',
          type: AlertType.contract,
          severity: Severity.medium,
          title: 'Amendment awaiting client signature',
          detail: '${p.name} v${c.version} changes price or timeline. Follow up with the client.',
          route: '/contracts/${c.id}',
        ));
      } else if (c.status == ContractStatus.sent) {
        out.add(AppAlert(
          id: 'contract:${c.id}',
          type: AlertType.contract,
          severity: Severity.low,
          title: 'Contract sent, not signed yet',
          detail: '${p.name} v${c.version} is waiting for the client.',
          route: '/contracts/${c.id}',
        ));
      }
    }

    out.removeWhere((a) => dismissed.contains(a.id));
    out.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return out;
  }
}
