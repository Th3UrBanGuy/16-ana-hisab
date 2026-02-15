import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart' as models;

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== PRODUCTS ====================
  
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Product>> getProductsByCategory(String categoryId) {
    return _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toFirestore());
  }

  Future<void> updateProduct(String productId, Product product) async {
    await _firestore
        .collection('products')
        .doc(productId)
        .update(product.toFirestore());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // ==================== CATEGORIES ====================

  Stream<List<Category>> getCategories() {
    return _firestore
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> addCategory(Category category) async {
    await _firestore.collection('categories').add(category.toFirestore());
  }

  // ==================== ORDERS ====================

  Stream<List<models.Order>> getOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => models.Order.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<void> createOrder(models.Order order, List<models.OrderItem> items) async {
    // Create order document with items
    final orderWithItems = models.Order(
      id: order.id,
      invoiceNumber: order.invoiceNumber,
      customerId: order.customerId,
      subtotal: order.subtotal,
      taxAmount: order.taxAmount,
      discountAmount: order.discountAmount,
      totalAmount: order.totalAmount,
      paymentMethod: order.paymentMethod,
      status: order.status,
      notes: order.notes,
      userId: order.userId,
      createdAt: order.createdAt,
      items: items,
    );

    await _firestore.collection('orders').add(orderWithItems.toFirestore());

    // Update product stock
    for (final item in items) {
      final productRef = _firestore.collection('products').doc(item.productId);
      final productDoc = await productRef.get();
      
      if (productDoc.exists) {
        final currentStock = (productDoc.data()?['stockQuantity'] as num?)?.toInt() ?? 0;
        final newStock = currentStock - item.quantity;
        
        await productRef.update({
          'stockQuantity': newStock >= 0 ? newStock : 0,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // ==================== INITIAL DATA SEEDING ====================

  Future<void> seedInitialData() async {
    // Check if data already exists
    final productsSnapshot = await _firestore.collection('products').limit(1).get();
    if (productsSnapshot.docs.isNotEmpty) {
      // Data already exists, skip seeding
      return;
    }

    // Seed Categories
    final categoriesData = [
      {'name': 'Coffee', 'colorCode': '#00BFA5', 'createdAt': DateTime.now().toIso8601String()},
      {'name': 'Pastries', 'colorCode': '#9C27B0', 'createdAt': DateTime.now().toIso8601String()},
      {'name': 'Merch', 'colorCode': '#2196F3', 'createdAt': DateTime.now().toIso8601String()},
    ];

    final categoryIds = <String>[];
    for (final catData in categoriesData) {
      final docRef = await _firestore.collection('categories').add(catData);
      categoryIds.add(docRef.id);
    }

    // Seed Products
    final productsData = [
      {
        'name': 'Espresso',
        'sku': 'COF-001',
        'barcode': '1234567890123',
        'price': 3.50,
        'costPrice': 1.20,
        'stockQuantity': 100,
        'categoryId': categoryIds[0],
        'categoryName': 'Coffee',
        'description': 'Rich and bold espresso shot',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Cappuccino',
        'sku': 'COF-002',
        'barcode': '1234567890124',
        'price': 4.50,
        'costPrice': 1.80,
        'stockQuantity': 100,
        'categoryId': categoryIds[0],
        'categoryName': 'Coffee',
        'description': 'Classic cappuccino with steamed milk',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Latte',
        'sku': 'COF-003',
        'barcode': '1234567890125',
        'price': 4.75,
        'costPrice': 1.90,
        'stockQuantity': 100,
        'categoryId': categoryIds[0],
        'categoryName': 'Coffee',
        'description': 'Smooth latte with espresso and milk',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Croissant',
        'sku': 'PAS-001',
        'barcode': '1234567890126',
        'price': 3.25,
        'costPrice': 1.00,
        'stockQuantity': 50,
        'categoryId': categoryIds[1],
        'categoryName': 'Pastries',
        'description': 'Buttery and flaky croissant',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Muffin',
        'sku': 'PAS-002',
        'barcode': '1234567890127',
        'price': 2.75,
        'costPrice': 0.80,
        'stockQuantity': 60,
        'categoryId': categoryIds[1],
        'categoryName': 'Pastries',
        'description': 'Fresh baked muffin',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'T-Shirt',
        'sku': 'MER-001',
        'barcode': '1234567890128',
        'price': 19.99,
        'costPrice': 8.00,
        'stockQuantity': 25,
        'categoryId': categoryIds[2],
        'categoryName': 'Merch',
        'description': 'Branded coffee shop t-shirt',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    for (final prodData in productsData) {
      await _firestore.collection('products').add(prodData);
    }
  }
}
