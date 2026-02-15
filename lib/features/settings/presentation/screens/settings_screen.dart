import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text('System Preferences'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Done',
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Search
          TextField(
            decoration: InputDecoration(
              hintText: 'Search settings',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 24),
          
          // Hardware Section
          _buildSectionHeader('HARDWARE'),
          _buildSettingItem(
            icon: Icons.print,
            iconColor: Colors.blue,
            title: 'Printer Setup',
            subtitle: 'Epson TM-88',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.credit_card,
            iconColor: Colors.purple,
            title: 'Card Reader',
            subtitle: 'Connected',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.qr_code_scanner,
            iconColor: Colors.blueGrey,
            title: 'Barcode Scanner',
            onTap: () {},
          ),
          SizedBox(height: 24),
          
          // Financials Section
          _buildSectionHeader('FINANCIALS'),
          _buildSettingItem(
            icon: Icons.percent,
            iconColor: Colors.orange,
            title: 'Tax Rates',
            onTap: () {},
          ),
          _buildToggleItem(
            icon: Icons.attach_money,
            iconColor: Colors.green,
            title: 'Tipping Options',
            value: true,
            onChanged: (value) {},
          ),
          _buildToggleItem(
            icon: Icons.receipt,
            iconColor: AppColors.primaryTeal,
            title: 'Digital Receipts',
            subtitle: 'Enabling digital receipts will prompt for email/phone after payment.',
            value: true,
            onChanged: (value) {},
          ),
          SizedBox(height: 24),
          
          // Account & Security Section
          _buildSectionHeader('ACCOUNT & SECURITY'),
          _buildSettingItem(
            icon: Icons.person,
            iconColor: AppColors.primaryTeal,
            title: 'User Account',
            subtitle: 'admin@pos-system.com',
            onTap: () {},
          ),
          _buildToggleItem(
            icon: Icons.lock,
            iconColor: Colors.red,
            title: 'Manager PIN Required',
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null ? Text(
          subtitle,
          style: TextStyle(fontSize: 12),
        ) : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primaryTeal,
        ),
      ),
    );
  }
}
