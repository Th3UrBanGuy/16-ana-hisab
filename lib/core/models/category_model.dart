class Category {
  final String id;
  final String name;
  final String colorCode;
  final String? icon;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.colorCode,
    this.icon,
    required this.createdAt,
  });

  // From Firestore
  factory Category.fromFirestore(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      name: data['name'] as String? ?? '',
      colorCode: data['colorCode'] as String? ?? '#4CAF50',
      icon: data['icon'] as String?,
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt'] as String) 
          : DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'colorCode': colorCode,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
