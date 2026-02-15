import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ==================== TABLES ====================

// Products Table
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get sku => text().unique()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real()();
  RealColumn get costPrice => real()();
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  TextColumn get imagePath => text().nullable()();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Categories Table
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get colorCode => text().withDefault(const Constant('#4CAF50'))();
  TextColumn get icon => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Customers Table
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get pointsBalance => real().withDefault(const Constant(0.0))();
  RealColumn get walletBalance => real().withDefault(const Constant(0.0))();
  TextColumn get membershipCode => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Orders Table
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().unique()();
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  RealColumn get subtotal => real()();
  RealColumn get taxAmount => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()();
  TextColumn get paymentMethod => text()(); // Cash, Card, Split
  TextColumn get status => text()(); // Paid, Void, Refunded, Parked
  TextColumn get notes => text().nullable()();
  IntColumn get userId => integer().nullable()(); // Cashier/Admin who processed
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Order Items Table
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id, onDelete: KeyAction.cascade)();
  IntColumn get productId => integer().references(Products, #id)();
  TextColumn get productName => text()(); // Store name at time of sale
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()(); // Price at time of sale
  RealColumn get subtotal => real()();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
}

// Coupons Table
class Coupons extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  TextColumn get type => text()(); // Percentage, Fixed, BOGO
  RealColumn get value => real()();
  RealColumn get minOrderValue => real().withDefault(const Constant(0.0))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Audit Log Table
class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().nullable()();
  TextColumn get userName => text()();
  TextColumn get action => text()(); // "Deleted Invoice #102", "Voided Order"
  TextColumn get details => text().nullable()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

// Users Table (for RBAC)
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().unique()();
  TextColumn get password => text()(); // Hash this in production
  TextColumn get fullName => text()();
  TextColumn get role => text()(); // Admin, Cashier
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Shifts Table (for cash drawer management)
class Shifts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  RealColumn get openingBalance => real()();
  RealColumn get closingBalance => real().nullable()();
  RealColumn get expectedCash => real().nullable()();
  RealColumn get actualCash => real().nullable()();
  RealColumn get difference => real().nullable()();
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
}

// ==================== DATABASE ====================

@DriftDatabase(tables: [
  Products,
  Categories,
  Customers,
  Orders,
  OrderItems,
  Coupons,
  AuditLogs,
  Users,
  Shifts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Insert default admin user
        await into(users).insert(UsersCompanion.insert(
          username: 'admin',
          password: 'admin123', // Change this in production
          fullName: 'System Administrator',
          role: 'Admin',
        ));
        
        // Insert default categories
        await into(categories).insert(CategoriesCompanion.insert(
          name: 'Coffee',
          colorCode: const Value('#00BFA5'),
        ));
        await into(categories).insert(CategoriesCompanion.insert(
          name: 'Pastries',
          colorCode: const Value('#9C27B0'),
        ));
        await into(categories).insert(CategoriesCompanion.insert(
          name: 'Merch',
          colorCode: const Value('#2196F3'),
        ));
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle database migrations here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'retail_pro.sqlite'));
    return NativeDatabase(file);
  });
}
