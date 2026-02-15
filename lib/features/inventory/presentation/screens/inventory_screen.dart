import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = [
      {
        'name': 'Signature Espresso Blend',
        'sku': 'COF-BLD-01',
        'stock': 142,
        'status': 'In Stock',
        'icon': '☕',
      },
      {
        'name': 'Vanilla Syrup (1L)',
        'sku': 'SYR-VAN-10',
        'stock': 4,
        'status': 'Low Stock',
        'icon': '🧃',
      },
      {
        'name': 'Oat Milk Barista Ed.',
        'sku': 'MLK-OAT-05',
        'stock': 89,
        'status': 'In Stock',
        'icon': '🥛',
      },
      {
        'name': 'Ceramic Mug 12oz',
        'sku': 'MER-MUG-12',
        'stock': 24,
        'status': 'In Stock',
        'icon': '☕',
      },
      {
        'name': 'Paper Filters V60',
        'sku': 'FLT-V60-02',
        'stock': 8,
        'status': 'Reorder',
        'icon': '📄',
      },
      {
        'name': 'Sencha Green Tea',
        'sku': 'TEA-GRN-01',
        'stock': 65,
        'status': 'In Stock',
        'icon': '🍵',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory'),
            Text(
              'All Stores • 1,240 Items',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
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
                  ),
                ),
              ],
            ),
          ),
          
          // Category Filters
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All Items', true),
                SizedBox(width: 8),
                _buildFilterChip('Low Stock', false),
                SizedBox(width: 8),
                _buildFilterChip('Beverages', false),
                SizedBox(width: 8),
                _buildFilterChip('Snacks', false),
              ],
            ),
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
                  flex: 2,
                  child: Text(
                    'STOCK LEVEL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          
          // Product List
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductItem(product);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.add),
        label: Text('Add Product'),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
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
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    final stock = product['stock'] as int;
    final status = product['status'] as String;
    
    Color statusColor;
    Color bgColor;
    
    if (status == 'Low Stock' || status == 'Reorder') {
      statusColor = AppColors.errorRed;
      bgColor = AppColors.errorRed.withValues(alpha: 0.1);
    } else {
      statusColor = AppColors.successGreen;
      bgColor = AppColors.successGreen.withValues(alpha: 0.1);
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          left: BorderSide(
            color: status == 'Low Stock' || status == 'Reorder' 
                ? AppColors.warningOrange 
                : Colors.transparent,
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
              child: Text(
                product['icon'] as String,
                style: TextStyle(fontSize: 28),
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
                  product['name'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'SKU: ${product['sku']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Stock Level
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stock.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
