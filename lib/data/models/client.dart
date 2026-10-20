class ClientReview {
  const ClientReview({
    required this.id,
    required this.date,
    required this.punctuality,
    required this.stability,
    required this.communication,
    required this.overall,
    this.projectName = '',
    this.note = '',
  });

  final String id;
  final DateTime date;
  final int punctuality; // 1-5: how punctual the payments were
  final int stability; // 1-5: how stable the requirements were
  final int communication; // 1-5
  final int overall; // 1-5
  final String projectName;
  final String note;
}

class Client {
  const Client({
    required this.id,
    required this.name,
    required this.contact,
    required this.industry,
    this.reviews = const [],
  });

  final String id;
  final String name;
  final String contact;
  final String industry;
  final List<ClientReview> reviews;

  Client withReview(ClientReview r) =>
      Client(id: id, name: name, contact: contact, industry: industry, reviews: [r, ...reviews]);
}
