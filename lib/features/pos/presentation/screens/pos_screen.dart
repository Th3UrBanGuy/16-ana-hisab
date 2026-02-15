import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/models/category_model.dart' as models;
import '../../../../core/models/order_model.dart' as models;
import '../../../../main.dart';

class CartItem {
  final Product product;
  int quantity;
  
  CartItem({required this.product, this.quantity = 1});
  
  double get subtotal => product.price * quantity;
}

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  String? _selectedCategoryId;
  final List<CartItem> _cartItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  double _taxRate = 0.10; // 10% tax
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double get _subtotal => _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
  double get _taxAmount => _subtotal * _taxRate;
  double get _total => _subtotal + _taxAmount;

  void _addToCart(Product product) {
    setState(() {
      final existingItem = _cartItems.where((item) => item.product.id == product.id).firstOrNull;
      if (existingItem != null) {
        existingItem.quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
    });
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _cartItems[index].quantity += delta;
      if (_cartItems[index].quantity <= 0) {
        _cartItems.removeAt(index);
      }
    });
  }

  Future<void> _checkout(BuildContext context) async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    final paymentMethod = await showDialog<String>(
      context: context,
      builder: (context) => _CheckoutDialog(totalAmount: _total),
    );

    if (paymentMethod == null) return;

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final uuid = Uuid();
      
      // Generate invoice number
      final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      
      // Create order
      final order = models.Order(
        id: '',
        invoiceNumber: invoiceNumber,
        subtotal: _subtotal,
        taxAmount: _taxAmount,
        discountAmount: 0.0,
        totalAmount: _total,
        paymentMethod: paymentMethod,
        status: 'Paid',
        createdAt: DateTime.now(),
      );
      
      // Create order items
      final items = _cartItems.map((cartItem) => models.OrderItem(
        id: uuid.v4(),
        orderId: '',
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        quantity: cartItem.quantity,
        unitPrice: cartItem.product.price,
        subtotal: cartItem.subtotal,
      )).toList();
      
      // Save order to Firebase
      await firestoreService.createOrder(order, items);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear cart
      setState(() {
        _cartItems.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesStream = ref.watch(firestoreServiceProvider).getCategories();
    final productsStream = _selectedCategoryId == null
        ? ref.watch(firestoreServiceProvider).getProducts()
        : ref.watch(firestoreServiceProvider).getProductsByCategory(_selectedCategoryId!);

    return Scaffold(
      appBar: AppBar(
        title: Text('Point of Sale'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () {
              // TODO: Implement barcode scanning
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Barcode scanner coming soon')),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Left Side - Product Grid
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                
                // Category Tabs
                StreamBuilder<List<models.Category>>(
                  stream: categoriesStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return SizedBox(height: 60, child: Center(child: CircularProgressIndicator()));
                    }
                    
                    final categories = snapshot.data!;
                    return Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('All Items'),
                              selected: _selectedCategoryId == null,
                              onSelected: (selected) {
                                setState(() => _selectedCategoryId = null);
                              },
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: AppColors.primaryTeal,
                              labelStyle: TextStyle(
                                color: _selectedCategoryId == null ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          ...categories.map((category) => Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category.name),
                              selected: _selectedCategoryId == category.id,
                              onSelected: (selected) {
                                setState(() => _selectedCategoryId = category.id);
                              },
                              backgroundColor: Colors.grey.shade200,
                              selectedColor: AppColors.primaryTeal,
                              labelStyle: TextStyle(
                                color: _selectedCategoryId == category.id ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          )),
                        ],
                      ),
                    );
                  },
                ),
                
                // Products Grid
                Expanded(
                  child: StreamBuilder<List<Product>>(
                    stream: productsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No products available'));
                      }
                      
                      var products = snapshot.data!;
                      
                      // Apply search filter
                      if (_searchQuery.isNotEmpty) {
                        products = products.where((p) => 
                          p.name.toLowerCase().contains(_searchQuery) ||
                          p.sku.toLowerCase().contains(_searchQuery)
                        ).toList();
                      }
                      
                      return GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return _buildProductCard(products[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Right Side - Cart & Checkout
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Column(
              children: [
                // Order Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Order',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${_cartItems.length} items',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Cart Items
                Expanded(
                  child: _cartItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Cart is empty',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            return _buildCartItem(_cartItems[index], index);
                          },
                        ),
                ),
                
                // Order Summary
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Subtotal', _subtotal),
                      SizedBox(height: 8),
                      _buildSummaryRow('Tax (10%)', _taxAmount),
                      Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            Formatters.formatCurrency(_total),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _cartItems.isEmpty ? null : () => _checkout(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryTeal,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart_checkout),
                              SizedBox(width: 12),
                              Text(
                                'Checkout',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isLowStock = product.stockQuantity < 10;
    
    return GestureDetector(
      onTap: () => _addToCart(product),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.coffee,
                    size: 48,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Stock: ${product.stockQuantity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isLowStock ? Colors.red : AppColors.textSecondary,
                        ),
                      ),
                      if (isLowStock) ...[
                        SizedBox(width: 4),
                        Icon(Icons.warning, size: 12, color: Colors.red),
                      ],
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Formatters.formatCurrency(product.price),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(item.product.price),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: () => _updateQuantity(index, -1),
                color: AppColors.primaryTeal,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () => _updateQuantity(index, 1),
                color: AppColors.primaryTeal,
              ),
            ],
          ),
          Text(
            Formatters.formatCurrency(item.subtotal),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          Formatters.formatCurrency(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CheckoutDialog extends StatelessWidget {
  final double totalAmount;

  const _CheckoutDialog({required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Complete Payment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(totalAmount),
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, 'Cash'),
              icon: Icon(Icons.money),
              label: Text('Cash'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: AppColors.primaryTeal,
              ),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, 'Card'),
              icon: Icon(Icons.credit_card),
              label: Text('Card'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: AppColors.primaryTeal,
              ),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
