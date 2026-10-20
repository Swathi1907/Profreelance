import '../../domain/services/contract_builder.dart';
import '../models/models.dart';

DateTime _d(int days) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day).add(Duration(days: days));
}

Milestone _paid(String id, String pid, String title, double amt, int dueDays, int lateDays, String clause) => Milestone(
      id: id,
      projectId: pid,
      title: title,
      amount: amt,
      due: _d(dueDays),
      paidOn: _d(dueDays + lateDays),
      clause: clause,
    );

Milestone _due(String id, String pid, String title, double amt, int dueDays, String clause) =>
    Milestone(id: id, projectId: pid, title: title, amount: amt, due: _d(dueDays), clause: clause);

ClientReview _rev(String id, int daysAgo, int p, int s, int c, int o, String project, String note) => ClientReview(
      id: id,
      date: _d(-daysAgo),
      punctuality: p,
      stability: s,
      communication: c,
      overall: o,
      projectName: project,
      note: note,
    );

SeedBundle seedData() {
  final clients = <Client>[
    Client(id: 'c1', name: 'Nexus Retail', contact: 'Priya Nair', industry: 'Retail', reviews: [
      _rev('r1', 200, 5, 4, 5, 5, 'Retail Inventory Dashboard', 'Paid the day invoices landed.'),
      _rev('r2', 60, 4, 4, 4, 4, 'E-Commerce Android App', 'Clear feedback, two small scope tweaks.'),
    ]),
    Client(id: 'c2', name: 'Zesty Bites', contact: 'Rahul Kapoor', industry: 'Food-tech', reviews: [
      _rev('r3', 230, 3, 3, 4, 3, 'Restaurant Booking App', 'Payments came about a week late.'),
    ]),
    Client(id: 'c3', name: 'FitLife Inc.', contact: 'Meera Joshi', industry: 'Health & fitness', reviews: [
      _rev('r4', 150, 2, 3, 3, 2, 'Workout Planner App', 'Chased three invoices.'),
    ]),
    Client(id: 'c4', name: 'Talkative', contact: 'Arjun Rao', industry: 'Communication', reviews: [
      _rev('r5', 105, 3, 1, 4, 2, 'Support Chatbot', 'Requirements changed every sprint.'),
      _rev('r6', 20, 3, 2, 4, 3, 'Chat Messenger App', 'Better, but still adding features mid-way.'),
    ]),
    Client(id: 'c5', name: 'Orbit Finance', contact: 'Sneha Iyer', industry: 'Fintech', reviews: [
      _rev('r7', 148, 5, 5, 5, 5, 'Sales Forecast Model', 'Ideal client.'),
    ]),
    Client(id: 'c6', name: 'Studio Ayra', contact: 'Kabir Shah', industry: 'Design agency', reviews: [
      _rev('r8', 133, 5, 4, 5, 5, 'Landing Page Redesign', 'Fast and fair.'),
    ]),
    const Client(id: 'c7', name: 'Personal', contact: 'Self', industry: 'Self-initiated'),
  ];

  final projects = <Project>[
    Project(
      id: 'p1', name: 'E-Commerce Android App', clientId: 'c1', domain: 'Mobile App Development', subDomain: 'E-commerce',
      description: 'Native Android shopping app with catalogue, cart, checkout and order tracking.',
      techStack: const ['Kotlin', 'Firebase', 'Razorpay'], status: ProjectStatus.inProgress,
      startDate: _d(-60), dueDate: _d(6), budget: 180000, estimatedHours: 240, actualHours: 150,
      advancePct: 20, revisions: 2, complexity: 4, changeRequests: 1,
      deliverables: 'Android app, admin panel, release build, source code',
      exclusions: 'iOS version, marketing content',
    ),
    Project(
      id: 'p2', name: 'Food Delivery App', clientId: 'c2', domain: 'Mobile App Development', subDomain: 'Food-tech',
      description: 'Cross-platform food ordering app with live order tracking and restaurant dashboard.',
      techStack: const ['Flutter', 'Firebase', 'Google Maps'], status: ProjectStatus.notStarted,
      startDate: _d(7), dueDate: _d(75), budget: 150000, estimatedHours: 200, advancePct: 20, revisions: 2, complexity: 4,
      deliverables: 'Customer app, rider app, restaurant web dashboard', exclusions: 'Payment gateway onboarding',
    ),
    Project(
      id: 'p3', name: 'Fitness Tracker UI', clientId: 'c3', domain: 'UI/UX Design', subDomain: 'Health',
      description: 'Design system and high-fidelity screens for a workout and nutrition tracking app.',
      techStack: const ['Figma', 'Prototyping'], status: ProjectStatus.inProgress,
      startDate: _d(-35), dueDate: _d(2), budget: 60000, estimatedHours: 80, actualHours: 70,
      advancePct: 33, revisions: 2, complexity: 3,
      deliverables: '40 screens, design tokens, clickable prototype', exclusions: 'Front-end code',
    ),
    Project(
      id: 'p4', name: 'Chat Messenger App', clientId: 'c4', domain: 'Mobile App Development', subDomain: 'Messaging',
      description: 'Real-time messenger with groups, media sharing, read receipts and push notifications.',
      techStack: const ['Kotlin', 'WebSocket', 'Supabase'], status: ProjectStatus.inProgress,
      startDate: _d(-90), dueDate: _d(20), budget: 120000, estimatedHours: 160, actualHours: 190,
      advancePct: 20, revisions: 3, complexity: 4, changeRequests: 4,
      deliverables: 'Android app and backend schema', exclusions: 'Voice and video calls',
    ),
    Project(
      id: 'p5', name: 'Portfolio Website', clientId: 'c7', domain: 'Web Development', subDomain: 'Portfolio',
      description: 'Personal portfolio site with project showcase, blog and contact form.',
      techStack: const ['React', 'Tailwind CSS'], status: ProjectStatus.completed,
      startDate: _d(-120), endDate: _d(-100), dueDate: _d(-98), budget: 25000, estimatedHours: 40, actualHours: 36, complexity: 2,
    ),
    Project(
      id: 'p6', name: 'Restaurant Booking App', clientId: 'c2', domain: 'Mobile App Development', subDomain: 'Food-tech',
      description: 'Table reservation app with restaurant search, live availability and reminders.',
      techStack: const ['Flutter', 'Firebase'], status: ProjectStatus.completed,
      startDate: _d(-300), endDate: _d(-235), dueDate: _d(-240), budget: 110000, estimatedHours: 150, actualHours: 168, complexity: 3,
    ),
    Project(
      id: 'p7', name: 'Retail Inventory Dashboard', clientId: 'c1', domain: 'Web Development', subDomain: 'Dashboard',
      description: 'Inventory and sales analytics dashboard with role-based access.',
      techStack: const ['React', 'Node.js', 'PostgreSQL'], status: ProjectStatus.completed,
      startDate: _d(-260), endDate: _d(-200), dueDate: _d(-205), budget: 140000, estimatedHours: 180, actualHours: 175, complexity: 3,
    ),
    Project(
      id: 'p8', name: 'Workout Planner App', clientId: 'c3', domain: 'Mobile App Development', subDomain: 'Health',
      description: 'Android workout planning app with exercise library and progress charts.',
      techStack: const ['Kotlin', 'Firebase'], status: ProjectStatus.completed,
      startDate: _d(-220), endDate: _d(-160), dueDate: _d(-165), budget: 90000, estimatedHours: 120, actualHours: 138, complexity: 3,
    ),
    Project(
      id: 'p9', name: 'Sales Forecast Model', clientId: 'c5', domain: 'Machine Learning', subDomain: 'Forecasting',
      description: 'Time-series sales forecasting model served through a REST API.',
      techStack: const ['Python', 'scikit-learn', 'FastAPI'], status: ProjectStatus.completed,
      startDate: _d(-200), endDate: _d(-150), dueDate: _d(-150), budget: 130000, estimatedHours: 110, actualHours: 126, complexity: 4,
    ),
    Project(
      id: 'p10', name: 'Landing Page Redesign', clientId: 'c6', domain: 'Web Development', subDomain: 'Marketing',
      description: 'Conversion-focused landing page redesign with new component library.',
      techStack: const ['React', 'Figma'], status: ProjectStatus.completed,
      startDate: _d(-150), endDate: _d(-135), dueDate: _d(-135), budget: 30000, estimatedHours: 30, actualHours: 28, complexity: 2,
    ),
    Project(
      id: 'p11', name: 'Support Chatbot', clientId: 'c4', domain: 'Machine Learning', subDomain: 'NLP',
      description: 'Customer support chatbot with intent classification and FAQ retrieval.',
      techStack: const ['Python', 'Transformers', 'FastAPI'], status: ProjectStatus.completed,
      startDate: _d(-180), endDate: _d(-110), dueDate: _d(-125), budget: 160000, estimatedHours: 170, actualHours: 205, complexity: 5, changeRequests: 6,
    ),
  ];

  final milestones = <Milestone>[
    _paid('m1', 'p1', 'Advance', 36000, -58, 0, '3.1'),
    _paid('m2', 'p1', 'UI/UX design', 30000, -40, 0, '3.2'),
    _paid('m3', 'p1', 'Authentication and catalogue', 30000, -20, 1, '3.3'),
    _due('m4', 'p1', 'Cart and checkout', 30000, 3, '3.4'),
    _due('m5', 'p1', 'Payments and orders', 30000, 6, '3.5'),
    _due('m6', 'p1', 'Testing and release', 24000, 14, '3.6'),
    _due('m7', 'p2', 'Advance', 30000, 5, '3.1'),
    _due('m8', 'p2', 'Customer app', 40000, 30, '3.2'),
    _due('m9', 'p2', 'Rider app and tracking', 45000, 55, '3.3'),
    _due('m10', 'p2', 'Dashboard and release', 35000, 75, '3.4'),
    _paid('m11', 'p3', 'Wireframes', 20000, -25, 6, '3.1'),
    _due('m12', 'p3', 'High-fidelity screens', 25000, -4, '3.2'),
    _due('m13', 'p3', 'Prototype and handoff', 15000, 2, '3.3'),
    _paid('m14', 'p4', 'Advance', 24000, -88, 0, '3.1'),
    _paid('m15', 'p4', 'Core messaging', 24000, -60, 2, '3.2'),
    _paid('m16', 'p4', 'Groups and media', 24000, -40, 4, '3.3'),
    _due('m17', 'p4', 'Notifications', 24000, 5, '3.4'),
    _due('m18', 'p4', 'Testing and release', 24000, 20, '3.5'),
    _paid('m19', 'p5', 'Advance', 10000, -118, 0, '3.1'),
    _paid('m20', 'p5', 'Final delivery', 15000, -100, 0, '3.2'),
    _paid('m21', 'p6', 'Advance', 30000, -298, 4, '3.1'),
    _paid('m22', 'p6', 'Beta build', 40000, -270, 7, '3.2'),
    _paid('m23', 'p6', 'Final delivery', 40000, -235, 9, '3.3'),
    _paid('m24', 'p7', 'Advance', 40000, -258, 0, '3.1'),
    _paid('m25', 'p7', 'Final delivery', 100000, -200, 1, '3.2'),
    _paid('m26', 'p8', 'Advance', 30000, -218, 6, '3.1'),
    _paid('m27', 'p8', 'Final delivery', 60000, -160, 11, '3.2'),
    _paid('m28', 'p9', 'Advance', 40000, -198, 0, '3.1'),
    _paid('m29', 'p9', 'Final delivery', 90000, -150, 0, '3.2'),
    _paid('m30', 'p10', 'Full payment', 30000, -135, 0, '3.1'),
    _paid('m31', 'p11', 'Advance', 50000, -178, 3, '3.1'),
    _paid('m32', 'p11', 'Final delivery', 110000, -110, 12, '3.2'),
  ];

  Contract make(String id, String pid, int v, ContractStatus st, int daysAgo, {String summary = ''}) {
    final p = projects.firstWhere((x) => x.id == pid);
    final c = clients.firstWhere((x) => x.id == p.clientId);
    final ms = milestones.where((m) => m.projectId == pid).toList();
    return Contract(
      id: id,
      projectId: pid,
      version: v,
      status: st,
      createdAt: _d(-daysAgo),
      title: '${p.name} - Services Agreement',
      summary: summary,
      clauses: ContractBuilder.build(ContractInputs.defaults(p, c, ms)),
    );
  }

  final contracts = <Contract>[
    make('k1', 'p1', 1, ContractStatus.signed, 62),
    make('k2', 'p3', 1, ContractStatus.sent, 3),
    make('k3', 'p4', 1, ContractStatus.signed, 92),
    make('k4', 'p4', 2, ContractStatus.amendmentPending, 4, summary: 'Adds read receipts and message search. +₹18,000, +6 days.'),
    make('k5', 'p5', 1, ContractStatus.signed, 121),
  ];

  VaultDoc doc(String id, String name, DocCategory cat, String? pid, int kb, int ago, [List<String> tags = const []]) =>
      VaultDoc(id: id, name: name, category: cat, projectId: pid, sizeKb: kb, addedAt: _d(-ago), tags: tags);

  final docs = <VaultDoc>[
    doc('d1', 'Nexus_requirements_v3.pdf', DocCategory.requirements, 'p1', 420, 55, ['srs']),
    doc('d2', 'Nexus_proposal_signed.pdf', DocCategory.proposals, 'p1', 880, 62, ['contract']),
    doc('d3', 'INV-1043_cart_checkout.pdf', DocCategory.invoices, 'p1', 96, 8, ['invoice']),
    doc('d4', 'Storefront_wireframes.fig', DocCategory.designFiles, 'p1', 9800, 44, ['figma']),
    doc('d5', 'Zesty_client_brief.docx', DocCategory.clientBriefs, 'p2', 310, 12, ['brief']),
    doc('d6', 'Delivery_apps_benchmark.xlsx', DocCategory.references, 'p2', 540, 10),
    doc('d7', 'FitLife_brand_guidelines.pdf', DocCategory.clientBriefs, 'p3', 2300, 34, ['brand']),
    doc('d8', 'FitLife_hifi_screens_v2.fig', DocCategory.designFiles, 'p3', 15400, 6, ['figma']),
    doc('d9', 'Talkative_api_spec.yaml', DocCategory.requirements, 'p4', 64, 80),
    doc('d10', 'Talkative_amendment_v2_draft.pdf', DocCategory.proposals, 'p4', 210, 4, ['amendment']),
    doc('d11', 'Portfolio_site_final.zip', DocCategory.deliverables, 'p5', 18700, 100, ['release']),
    doc('d12', 'WCAG_checklist.pdf', DocCategory.references, null, 150, 200),
  ];

  return SeedBundle(
    projects: projects,
    milestones: milestones,
    clients: clients,
    contracts: contracts,
    docs: docs,
  );
}

class SeedBundle {
  const SeedBundle({
    required this.projects,
    required this.milestones,
    required this.clients,
    required this.contracts,
    required this.docs,
  });
  final List<Project> projects;
  final List<Milestone> milestones;
  final List<Client> clients;
  final List<Contract> contracts;
  final List<VaultDoc> docs;
}
