class Order {
  final String id;
  final String invoiceNumber;
  final String? customerId;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final String? notes;
  final int? userId;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.invoiceNumber,
    this.customerId,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    this.notes,
    this.userId,
    required this.createdAt,
    this.items = const [],
  });

  // From Firestore
  factory Order.fromFirestore(Map<String, dynamic> data, String id) {
    final itemsList = (data['items'] as List<dynamic>?)
        ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
        .toList() ?? [];

    return Order(
      id: id,
      invoiceNumber: data['invoiceNumber'] as String? ?? '',
      customerId: data['customerId'] as String?,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (data['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: data['paymentMethod'] as String? ?? '',
      status: data['status'] as String? ?? '',
      notes: data['notes'] as String?,
      userId: (data['userId'] as num?)?.toInt(),
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt'] as String) 
          : DateTime.now(),
      items: itemsList,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'invoiceNumber': invoiceNumber,
      'customerId': customerId,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'notes': notes,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final double discount;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.discount = 0.0,
  });

  // From Map
  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      id: data['id'] as String? ?? '',
      orderId: data['orderId'] as String? ?? '',
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
      'discount': discount,
    };
  }
}
