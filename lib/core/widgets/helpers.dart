import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../theme/app_colors.dart';
import 'widgets.dart';



bool isWide(BuildContext context) => MediaQuery.sizeOf(context).width >= 900;

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Color severityColor(BuildContext c, Severity s) => switch (s) {
      Severity.high => c.pf.danger,
      Severity.medium => c.pf.warning,
      Severity.low => c.pf.success,
    };

Color statusColor(BuildContext c, ProjectStatus s) => switch (s) {
      ProjectStatus.notStarted => Pf.goldDark,
      ProjectStatus.inProgress => c.isDark ? Pf.gold : Pf.maroon,
      ProjectStatus.completed => c.pf.success,
    };

Color scoreColor(BuildContext c, num score) =>
    score >= 75 ? c.pf.success : (score >= 55 ? c.pf.warning : c.pf.danger);
