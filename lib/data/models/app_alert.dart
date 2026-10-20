import 'models.dart';
class AppAlert {
  const AppAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.detail,
    required this.route,
  });

  final String id;
  final AlertType type;
  final Severity severity;
  final String title;
  final String detail;
  final String route;
}
