import 'package:flutter/material.dart';

import '../../../negotiation/view/negotiation_panel.dart';

class NegotiateTab extends StatelessWidget {
  const NegotiateTab({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context) => NegotiationPanel(projectId: projectId);
}
