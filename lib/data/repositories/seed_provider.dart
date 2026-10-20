import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../seed/seed_data.dart';

/// One-off demo data. A Supabase-backed repository would load from tables instead.
final seedProvider = Provider<SeedBundle>((ref) => seedData());
