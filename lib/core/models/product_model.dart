class Product {
  final String id;
  final String name;
  final String sku;
  final String? barcode;
  final double price;
  final double costPrice;
  final int stockQuantity;
  final String? categoryId;
  final String? categoryName;
  final String? imagePath;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    required this.price,
    required this.costPrice,
    required this.stockQuantity,
    this.categoryId,
    this.categoryName,
    this.imagePath,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // From Firestore
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] as String? ?? '',
      sku: data['sku'] as String? ?? '',
      barcode: data['barcode'] as String?,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (data['costPrice'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (data['stockQuantity'] as num?)?.toInt() ?? 0,
      categoryId: data['categoryId'] as String?,
      categoryName: data['categoryName'] as String?,
      imagePath: data['imagePath'] as String?,
      description: data['description'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt'] as String) 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt'] as String) 
          : DateTime.now(),
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'price': price,
      'costPrice': costPrice,
      'stockQuantity': stockQuantity,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'imagePath': imagePath,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // CopyWith method
  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    double? price,
    double? costPrice,
    int? stockQuantity,
    String? categoryId,
    String? categoryName,
    String? imagePath,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
