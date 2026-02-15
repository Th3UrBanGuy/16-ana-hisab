import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Welcome back, Alex',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Today',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.keyboard_arrow_down, size: 20),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(Icons.notifications_outlined),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // KPI Cards
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'TOTAL SALES',
                    value: Formatters.formatCurrency(4203.50),
                    change: '+15%',
                    isPositive: true,
                    backgroundColor: AppColors.white,
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    title: 'REVENUE',
                    value: Formatters.formatCurrency(12890),
                    change: '+8.2%',
                    isPositive: true,
                    backgroundColor: AppColors.primaryTeal,
                    icon: Icons.attach_money,
                    isDark: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            
            // Sales Overview Chart
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sales Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.more_horiz),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: _buildSalesChart(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            
            // Top Categories
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Categories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: _buildPieChart(),
                      ),
                      SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCategoryItem('Coffee', '45%', AppColors.primaryTeal),
                            SizedBox(height: 12),
                            _buildCategoryItem('Pastries', '30%', AppColors.chartPurple),
                            SizedBox(height: 12),
                            _buildCategoryItem('Merch', '25%', AppColors.chartBlue),
                          ],
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required Color backgroundColor,
    required IconData icon,
    bool isDark = false,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDark ? AppColors.white.withValues(alpha: 0.8) : AppColors.primaryTeal,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: isDark ? AppColors.white.withValues(alpha: 0.8) : AppColors.successGreen,
              ),
              SizedBox(width: 4),
              Text(
                '$change vs yest.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.white.withValues(alpha: 0.8) : AppColors.successGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 2000,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(value / 1000).toStringAsFixed(0)}k',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['9 AM', '12 PM', '3 PM', '6 PM'];
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return Text(
                    labels[value.toInt()],
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  );
                }
                return Text('');
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1000),
              FlSpot(1, 3000),
              FlSpot(2, 4500),
              FlSpot(3, 5200),
            ],
            isCurved: true,
            color: AppColors.primaryTeal,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryTeal.withValues(alpha: 0.1),
            ),
          ),
        ],
        minY: 0,
        maxY: 10000,
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: [
          PieChartSectionData(
            value: 45,
            color: AppColors.primaryTeal,
            radius: 25,
            showTitle: false,
          ),
          PieChartSectionData(
            value: 30,
            color: AppColors.chartPurple,
            radius: 25,
            showTitle: false,
          ),
          PieChartSectionData(
            value: 25,
            color: AppColors.chartBlue,
            radius: 25,
            showTitle: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String name, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12),
        Text(
          name,
          style: TextStyle(fontSize: 14),
        ),
        Spacer(),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
