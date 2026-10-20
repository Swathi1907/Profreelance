import 'models.dart';
class VaultDoc {
  const VaultDoc({
    required this.id,
    required this.name,
    required this.category,
    required this.sizeKb,
    required this.addedAt,
    this.projectId,
    this.tags = const [],
  });

  final String id;
  final String name;
  final DocCategory category;
  final String? projectId;
  final int sizeKb;
  final DateTime addedAt;
  final List<String> tags;
}
