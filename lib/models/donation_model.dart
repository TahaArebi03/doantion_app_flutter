class DonationModel {
  final int id;
  final int projectId;
  final String projectTitle;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  DonationModel({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    final project = json['project'] ?? json;
    return DonationModel(
      id: json['id'] ?? 0,
      projectId: project['id'] ?? 0,
      projectTitle: project['title'] ?? 'مشروع غير معروف',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'] ?? 'unknown',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
