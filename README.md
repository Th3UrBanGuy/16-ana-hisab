# NeoPOS - Professional Point of Sale System

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.35.4-blue.svg" />
  <img src="https://img.shields.io/badge/Firebase-Enabled-orange.svg" />
  <img src="https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS-green.svg" />
  <img src="https://img.shields.io/badge/Status-Production%20Ready-success.svg" />
</div>

## 🚀 Overview

NeoPOS is a modern, cloud-based Point of Sale (POS) system built with Flutter and Firebase. It provides a complete solution for retail businesses with real-time inventory management, sales tracking, and comprehensive reporting.

### ✨ Key Features

- **🔐 Secure Authentication** - SHA-256 password hashing with Firebase Auth integration
- **📦 Inventory Management** - Real-time stock tracking and low-stock alerts
- **💰 Sales Processing** - Fast POS interface with barcode scanning support
- **📊 Analytics Dashboard** - Real-time sales metrics and performance charts
- **👥 User Management** - Role-based access control (Admin/Cashier)
- **🧾 Receipt Generation** - PDF receipt generation and sharing
- **📱 Multi-Platform** - Works seamlessly on Web, Android, and iOS
- **☁️ Cloud-Sync** - All data synchronized via Firebase Firestore
- **🎨 Modern UI** - Clean Material Design 3 interface

## 🛠️ Technology Stack

- **Frontend:** Flutter 3.35.4
- **Backend:** Firebase (Firestore, Auth, Storage, Hosting)
- **State Management:** Riverpod
- **Security:** Crypto (SHA-256), Firebase Security Rules
- **Charts:** FL Chart
- **PDF Generation:** PDF package (web-compatible)

## 📋 Prerequisites

- Flutter SDK 3.35.4
- Dart 3.9.2
- Firebase CLI (for deployment)
- Firebase Project with Firestore enabled

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Th3UrBanGuy/16-ana-hisab.git
cd 16-ana-hisab
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

The project is already configured for Firebase project `sholoanahisab`. If you need to use your own Firebase project:

1. Replace `lib/firebase_options.dart` with your Firebase configuration
2. Update `android/app/google-services.json` (for Android)
3. Update `ios/Runner/GoogleService-Info.plist` (for iOS)

### 4. Run the App

**Web (Development):**
```bash
flutter run -d chrome
```

**Web (Production Build):**
```bash
flutter build web --release
python3 -m http.server 5060 --directory build/web
```

**Android:**
```bash
flutter run -d android
```

## 🌐 Web Preview

The app is currently running at: **https://5060-i7cz24wsjaq47l5uhgf8p-82b888ba.sandbox.novita.ai**

## 📱 Features Breakdown

### Dashboard
- Real-time sales metrics
- Revenue tracking with percentage changes
- Sales overview charts
- Top categories performance
- Quick navigation to all modules

### POS (Point of Sale)
- Fast product search and selection
- Barcode scanning support
- Category filtering
- Real-time cart management
- Multiple payment methods
- Receipt generation and sharing

### Inventory Management
- Product CRUD operations
- Stock level monitoring
- Low stock alerts
- Category management
- SKU and barcode tracking
- Cost price and selling price management

### Sales History
- Complete transaction history
- Date-based filtering
- Invoice details
- Sales reports
- Receipt regeneration

### Settings
- Hardware configuration (printer, card reader, barcode scanner)
- Financial settings (tax rates, tipping options)
- Digital receipts configuration
- User account management
- Security settings

## 🔒 Security Features

### Authentication
- ✅ SHA-256 password hashing
- ✅ Firebase Authentication integration
- ✅ Session management
- ✅ Secure password change functionality

### Authorization
- ✅ Role-based access control (Admin/Cashier)
- ✅ Firestore security rules enforced
- ✅ Protected admin routes

### Data Protection
- ✅ HTTPS enforced (Firebase Hosting)
- ✅ Security headers configured
- ✅ XSS protection
- ✅ CSRF protection via Firebase Auth tokens

## 📊 Database Structure

### Collections

**users**
- username, password (hashed), fullName, role, isActive, createdAt

**categories**
- name, colorCode, icon, createdAt

**products**
- name, sku, barcode, price, costPrice, stockQuantity, categoryId, categoryName, description, isActive, createdAt, updatedAt

**orders**
- invoiceNumber, customerId, subtotal, taxAmount, discountAmount, totalAmount, paymentMethod, status, notes, userId, items[], createdAt

**customers** (optional)
- name, phone, email, address, membershipCode, createdAt

## 🚀 Production Deployment

### Firebase Hosting

1. **Build the app:**
   ```bash
   flutter build web --release
   ```

2. **Deploy to Firebase:**
   ```bash
   firebase login
   firebase init hosting
   firebase deploy
   ```

3. **Access your app:**
   - https://sholoanahisab.web.app
   - https://sholoanahisab.firebaseapp.com

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

## 🔐 Default Credentials

**Admin Account:**
- Username: `admin`
- Password: `Admin@123`

⚠️ **IMPORTANT:** Change the admin password immediately after first login!

## 📖 API Documentation

### AuthService

```dart
// Login
final result = await authService.login(username, password);

// Register new user (admin only)
final result = await authService.registerUser(
  username: 'newuser',
  password: 'password',
  fullName: 'User Name',
  role: 'Cashier',
);

// Change password
final result = await authService.changePassword(
  currentPassword: 'old',
  newPassword: 'new',
);

// Logout
await authService.logout();
```

### FirestoreService

```dart
// Get products stream
Stream<List<Product>> products = firestoreService.getProducts();

// Add product
await firestoreService.addProduct(product);

// Create order
await firestoreService.createOrder(order, items);

// Seed initial data
await firestoreService.seedInitialData();
```

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Analyze code
flutter analyze
```

## 🐛 Known Issues

- PDF generation uses `printing` package which has FFI dependencies (web-compatible alternative used)
- Barcode scanning requires camera permissions on mobile platforms

## 🗺️ Roadmap

- [ ] Offline mode with local sync
- [ ] Multi-store support
- [ ] Advanced analytics and reports
- [ ] Customer loyalty program
- [ ] Email/SMS receipt delivery
- [ ] Supplier management
- [ ] Purchase order management
- [ ] Employee time tracking

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributors

- Development Team

## 🆘 Support

For support and questions:
- Create an issue on GitHub
- Email: support@example.com
- Firebase Console: https://console.firebase.google.com/project/sholoanahisab

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the robust backend infrastructure
- Material Design team for the beautiful UI guidelines

---

<div align="center">
  Made with ❤️ using Flutter and Firebase
</div>
