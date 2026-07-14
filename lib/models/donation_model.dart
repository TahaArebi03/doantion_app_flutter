class Donation {
  final String id;
  final String projectId;
  final String donorName;
  final int amount;
  final DateTime date;

  Donation({
    required this.id,
    required this.projectId,
    required this.donorName,
    required this.amount,
    required this.date,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'].toString(),
      projectId: json['project_id'].toString(),
      donorName: json['donor_name'] ?? '',
      amount: json['amount'] ?? 0,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }
}
