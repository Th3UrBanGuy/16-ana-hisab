import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/product_model.dart';
import '../../../../core/models/category_model.dart' as models;
import '../../../../main.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddProductDialog(
        onAdd: (product) async {
          try {
            final firestoreService = ref.read(firestoreServiceProvider);
            await firestoreService.addProduct(product);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product added successfully'), backgroundColor: Colors.green),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding product: $e'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => _EditProductDialog(
        product: product,
        onUpdate: (updatedProduct) async {
          try {
            final firestoreService = ref.read(firestoreServiceProvider);
            await firestoreService.updateProduct(product.id, updatedProduct);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product updated successfully'), backgroundColor: Colors.green),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating product: $e'), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final firestoreService = ref.read(firestoreServiceProvider);
                await firestoreService.deleteProduct(product.id);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product deleted successfully'), backgroundColor: Colors.green),
                );
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting product: $e'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesStream = ref.watch(firestoreServiceProvider).getCategories();
    final productsStream = _selectedCategoryId == null
        ? ref.watch(firestoreServiceProvider).getProducts()
        : ref.watch(firestoreServiceProvider).getProductsByCategory(_selectedCategoryId!);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory'),
            StreamBuilder<List<Product>>(
              stream: ref.watch(firestoreServiceProvider).getProducts(),
              builder: (context, snapshot) {
                final count = snapshot.data?.length ?? 0;
                return Text(
                  '$count Products',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or SKU...',
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
          
          // Category Filters
          StreamBuilder<List<models.Category>>(
            stream: categoriesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();
              
              final categories = snapshot.data!;
              return Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All Items', _selectedCategoryId == null, null),
                    SizedBox(width: 8),
                    ...categories.map((cat) => Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: _buildFilterChip(cat.name, _selectedCategoryId == cat.id, cat.id),
                    )),
                  ],
                ),
              );
            },
          ),
          
          // Table Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'PRODUCT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'PRICE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'STOCK',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(width: 100),
              ],
            ),
          ),
          
          // Product List
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No products found'));
                }
                
                var products = snapshot.data!;
                
                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  products = products.where((p) => 
                    p.name.toLowerCase().contains(_searchQuery) ||
                    p.sku.toLowerCase().contains(_searchQuery)
                  ).toList();
                }
                
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _buildProductItem(products[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        icon: Icon(Icons.add),
        label: Text('Add Product'),
        backgroundColor: AppColors.primaryTeal,
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, String? categoryId) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = categoryId;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkNavy : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    final isLowStock = product.stockQuantity < 10;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          left: BorderSide(
            color: isLowStock ? AppColors.warningOrange : Colors.transparent,
            width: 4,
          ),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Product Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                Icons.coffee,
                size: 28,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
          SizedBox(width: 16),
          
          // Product Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'SKU: ${product.sku}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (product.categoryName != null) ...[
                  SizedBox(height: 2),
                  Text(
                    product.categoryName!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Price
          Expanded(
            flex: 1,
            child: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          
          // Stock Level
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.stockQuantity.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isLowStock ? AppColors.errorRed : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLowStock 
                        ? AppColors.errorRed.withValues(alpha: 0.1) 
                        : AppColors.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isLowStock ? 'Low Stock' : 'In Stock',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isLowStock ? AppColors.errorRed : AppColors.successGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          SizedBox(width: 16),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () => _showEditProductDialog(product));
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () => _deleteProduct(product));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Add Product Dialog
class _AddProductDialog extends ConsumerStatefulWidget {
  final Function(Product) onAdd;

  const _AddProductDialog({required this.onAdd});

  @override
  ConsumerState<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<_AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesStream = ref.watch(firestoreServiceProvider).getCategories();

    return AlertDialog(
      title: Text('Add New Product'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name *'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _skuController,
                decoration: InputDecoration(labelText: 'SKU *'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _barcodeController,
                decoration: InputDecoration(labelText: 'Barcode'),
              ),
              SizedBox(height: 12),
              StreamBuilder<List<models.Category>>(
                stream: categoriesStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final categories = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(labelText: 'Category'),
                    items: categories.map((cat) => DropdownMenuItem(
                      value: cat.id,
                      child: Text(cat.name),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                        _selectedCategoryName = categories.firstWhere((c) => c.id == value).name;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Selling Price *'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _costPriceController,
                decoration: InputDecoration(labelText: 'Cost Price *'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(labelText: 'Initial Stock *'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final product = Product(
                id: '',
                name: _nameController.text,
                sku: _skuController.text,
                barcode: _barcodeController.text.isEmpty ? null : _barcodeController.text,
                price: double.parse(_priceController.text),
                costPrice: double.parse(_costPriceController.text),
                stockQuantity: int.parse(_stockController.text),
                categoryId: _selectedCategoryId,
                categoryName: _selectedCategoryName,
                description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              widget.onAdd(product);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
          child: Text('Add Product'),
        ),
      ],
    );
  }
}

// Edit Product Dialog
class _EditProductDialog extends ConsumerStatefulWidget {
  final Product product;
  final Function(Product) onUpdate;

  const _EditProductDialog({required this.product, required this.onUpdate});

  @override
  ConsumerState<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends ConsumerState<_EditProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _costPriceController = TextEditingController(text: widget.product.costPrice.toString());
    _stockController = TextEditingController(text: widget.product.stockQuantity.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Product'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Product Name'),
          ),
          SizedBox(height: 12),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(labelText: 'Selling Price'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _costPriceController,
            decoration: InputDecoration(labelText: 'Cost Price'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12),
          TextField(
            controller: _stockController,
            decoration: InputDecoration(labelText: 'Stock Quantity'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedProduct = widget.product.copyWith(
              name: _nameController.text,
              price: double.parse(_priceController.text),
              costPrice: double.parse(_costPriceController.text),
              stockQuantity: int.parse(_stockController.text),
              updatedAt: DateTime.now(),
            );
            widget.onUpdate(updatedProduct);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
          child: Text('Update'),
        ),
      ],
    );
  }
}
