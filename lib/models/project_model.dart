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

  // دالة تحويل الـ JSON القادم من Laravel إلى كائن دارت يسهل قراءته
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    // معالجة الصور إن وجدت من المصفوفة المتداخلة
    List<String> imagesList = [];
    if (json['images'] != null) {
      imagesList = List<String>.from(
        json['images'].map(
          (img) => img is Map ? (img['image_path'] ?? '') : img.toString(),
        ),
      );
    }

    return ProjectModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // السيرفر قد يرسل الأرقام بنوع int أو double، نقوم بتحويلها بأمان
      goal_amount: double.tryParse(json['goal_amount'].toString()) ?? 0.0,
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
      status: json['status'] ?? 'active',
      images: imagesList,
    );
  }
}
