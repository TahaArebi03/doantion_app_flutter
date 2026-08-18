class ProjectModel {
  final int id;
  final String title;
  final String description;
  final double goal_amount;
  final double balance;
  final String status;
  final List<String> images;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.goal_amount,
    required this.balance,
    required this.status,
    required this.images,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    final nestedProject = json['project'];
    if (nestedProject is Map<String, dynamic>) {
      return nestedProject;
    }
    if (nestedProject is Map) {
      return Map<String, dynamic>.from(nestedProject);
    }
    return json;
  }

  // دالة تحويل الـ JSON القادم من Laravel إلى كائن دارت يسهل قراءته
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final source = _normalizeJson(json);

    // معالجة الصور إن وجدت من المصفوفة المتداخلة
    List<String> imagesList = [];
    final imagesSource = source['images'] ?? json['images'];
    if (imagesSource != null) {
      if (imagesSource is List) {
        imagesList = imagesSource.map((img) {
          if (img is Map) return img['image_path'] ?? img['path'] ?? '';
          return img.toString();
        }).toList().cast<String>();
      }
    }

    final balanceValue =
        source['balance'] ??
        source['current_amount'] ??
        source['amount_raised'] ??
        source['total_raised'] ??
        source['current_balance'] ??
        source['donated_amount'] ??
        source['raised_amount'] ??
        0;

    return ProjectModel(
      id: _parseInt(source['id'] ?? json['id']),
      title: source['title'] ?? json['title'] ?? '',
      description: source['description'] ?? json['description'] ?? '',
      goal_amount: _parseAmount(source['goal_amount'] ?? json['goal_amount']),
      balance: _parseAmount(balanceValue),
      status: source['status'] ?? json['status'] ?? 'active',
      images: imagesList,
    );
  }
}
