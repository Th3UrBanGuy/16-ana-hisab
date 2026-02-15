# Retail Pro - Point of Sale System

![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 📱 Overview

**Retail Pro** is a comprehensive Point of Sale (POS) system built with Flutter, designed for retail businesses including coffee shops, restaurants, and retail stores. The application provides a modern, intuitive interface for managing inventory, processing sales, tracking analytics, and managing customers.

### ✨ Key Features

- 🏪 **Point of Sale (POS)** - Fast and intuitive checkout with barcode scanning support
- 📦 **Inventory Management** - Real-time stock tracking with low stock alerts
- 📊 **Analytics Dashboard** - Sales insights, revenue tracking, and category performance
- 🧾 **Sales History** - Comprehensive order history with detailed receipts
- 💳 **Multiple Payment Methods** - Cash, Card, and Split payment support
- 🎨 **Modern UI/UX** - Material Design 3 with responsive layouts
- ☁️ **Cloud Sync** - Firebase Firestore for real-time data synchronization
- 🔒 **Role-Based Access** - Admin and Cashier role support
- 📱 **Cross-Platform** - Works on Android, iOS, and Web

---

## 🏗️ System Architecture

### Architecture Pattern

The application follows **Clean Architecture** principles combined with **Feature-First Organization**, ensuring:
- Clear separation of concerns
- High maintainability and testability
- Scalability for future enhancements
- Easy onboarding for new developers

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Presentation Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Dashboard   │  │     POS      │  │  Inventory   │     │
│  │   Screen     │  │   Screen     │  │   Screen     │ ... │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────┐
│                    Business Logic Layer                     │
│  ┌────────────────────────────────────────────────────┐    │
│  │         State Management (Riverpod)                 │    │
│  │  - Providers  - State Notifiers  - Repositories    │    │
│  └────────────────────────────────────────────────────┘    │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────┐
│                       Data Layer                            │
│  ┌──────────────────┐         ┌────────────────────────┐   │
│  │  Drift (SQLite)  │         │  Firestore Service     │   │
│  │  Local Database  │ <────> │  Cloud Database        │   │
│  └──────────────────┘         └────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Project Structure

```
lib/
├── core/                           # Core functionality shared across features
│   ├── constants/
│   │   └── app_constants.dart      # App-wide constants (colors, tax rates, etc.)
│   ├── database/
│   │   ├── app_database.dart       # Drift database definition
│   │   └── app_database.g.dart     # Generated database code
│   ├── models/
│   │   ├── product_model.dart      # Product data model
│   │   ├── category_model.dart     # Category data model
│   │   └── order_model.dart        # Order & OrderItem models
│   ├── services/
│   │   └── firestore_service.dart  # Firebase Firestore service
│   ├── theme/
│   │   └── app_theme.dart          # App theming (light/dark modes)
│   └── utils/
│       └── formatters.dart         # Utility functions (currency, date, etc.)
│
├── features/                       # Feature-first organization
│   ├── auth/
│   │   └── presentation/
│   │       └── screens/
│   │           └── login_screen.dart
│   ├── dashboard/
│   │   └── presentation/
│   │       └── screens/
│   │           └── dashboard_screen.dart
│   ├── pos/
│   │   └── presentation/
│   │       └── screens/
│   │           └── pos_screen.dart
│   ├── inventory/
│   │   └── presentation/
│   │       └── screens/
│   │           └── inventory_screen.dart
│   ├── sales_history/
│   │   └── presentation/
│   │       └── screens/
│   │           └── sales_history_screen.dart
│   └── settings/
│       └── presentation/
│           └── screens/
│               └── settings_screen.dart
│
├── firebase_options.dart           # Firebase configuration
└── main.dart                       # App entry point

android/                            # Android-specific configuration
ios/                                # iOS-specific configuration
web/                                # Web-specific configuration
assets/                             # Static assets (images, icons)
test/                               # Unit and widget tests
```

---

## 📊 Database Schema

### Entity Relationship Diagram

```
┌─────────────┐         ┌──────────────┐
│  Categories │◄────────│   Products   │
│  (SQLite)   │         │   (SQLite)   │
└─────────────┘         └──────────────┘
                              │
                              │
                              ▼
                        ┌──────────────┐
                        │  OrderItems  │
                        │   (SQLite)   │
                        └──────┬───────┘
                               │
                               │
                               ▼
                        ┌──────────────┐         ┌─────────────┐
                        │    Orders    │────────►│  Customers  │
                        │  (Firestore) │         │  (SQLite)   │
                        └──────────────┘         └─────────────┘
```

### Database Tables

#### **Products Table**
| Column          | Type     | Description                          |
|-----------------|----------|--------------------------------------|
| id              | INTEGER  | Primary key                          |
| name            | TEXT     | Product name                         |
| sku             | TEXT     | Stock keeping unit (unique)          |
| barcode         | TEXT     | Barcode identifier                   |
| price           | REAL     | Selling price                        |
| costPrice       | REAL     | Cost price                           |
| stockQuantity   | INTEGER  | Current stock level                  |
| categoryId      | INTEGER  | Foreign key to Categories            |
| imagePath       | TEXT     | Product image path                   |
| description     | TEXT     | Product description                  |
| isActive        | BOOLEAN  | Active status                        |
| createdAt       | DATETIME | Creation timestamp                   |
| updatedAt       | DATETIME | Last update timestamp                |

#### **Categories Table**
| Column     | Type     | Description            |
|------------|----------|------------------------|
| id         | INTEGER  | Primary key            |
| name       | TEXT     | Category name          |
| colorCode  | TEXT     | Display color (#HEX)   |
| icon       | TEXT     | Icon identifier        |
| createdAt  | DATETIME | Creation timestamp     |

#### **Orders Table (Firestore)**
| Field          | Type     | Description                       |
|----------------|----------|-----------------------------------|
| id             | String   | Document ID                       |
| invoiceNumber  | String   | Unique invoice number             |
| customerId     | String   | Customer reference (optional)     |
| subtotal       | Number   | Pre-tax total                     |
| taxAmount      | Number   | Tax amount                        |
| discountAmount | Number   | Discount applied                  |
| totalAmount    | Number   | Final total                       |
| paymentMethod  | String   | Cash/Card/Split                   |
| status         | String   | Paid/Void/Refunded/Parked         |
| items          | Array    | Order items list                  |
| createdAt      | DateTime | Order timestamp                   |

#### **OrderItems Table (Nested in Orders)**
| Field        | Type   | Description                    |
|--------------|--------|--------------------------------|
| id           | String | Item ID                        |
| productId    | String | Product reference              |
| productName  | String | Product name at sale time      |
| quantity     | Number | Quantity sold                  |
| unitPrice    | Number | Price per unit at sale time    |
| subtotal     | Number | Line item total                |
| discount     | Number | Item-level discount            |

#### **Customers Table**
| Column          | Type     | Description                  |
|-----------------|----------|------------------------------|
| id              | INTEGER  | Primary key                  |
| name            | TEXT     | Customer name                |
| phone           | TEXT     | Phone number                 |
| email           | TEXT     | Email address                |
| address         | TEXT     | Mailing address              |
| pointsBalance   | REAL     | Loyalty points               |
| walletBalance   | REAL     | Store credit                 |
| membershipCode  | TEXT     | Unique membership code       |
| createdAt       | DATETIME | Registration date            |

#### **Users Table (RBAC)**
| Column     | Type     | Description                    |
|------------|----------|--------------------------------|
| id         | INTEGER  | Primary key                    |
| username   | TEXT     | Login username (unique)        |
| password   | TEXT     | Hashed password                |
| fullName   | TEXT     | Full name                      |
| role       | TEXT     | Admin/Cashier                  |
| isActive   | BOOLEAN  | Account status                 |
| createdAt  | DATETIME | Account creation date          |

#### **Audit Logs Table**
| Column    | Type     | Description                       |
|-----------|----------|-----------------------------------|
| id        | INTEGER  | Primary key                       |
| userId    | INTEGER  | User who performed action         |
| userName  | TEXT     | Username for reference            |
| action    | TEXT     | Description of action             |
| details   | TEXT     | Additional JSON details           |
| timestamp | DATETIME | When action occurred              |

---

## 🔧 Technology Stack

### Frontend
- **Flutter 3.35.4** - UI framework
- **Dart 3.9.2** - Programming language
- **Material Design 3** - Design system

### State Management
- **Riverpod 2.6.1** - Reactive state management

### Data Persistence
- **Drift 2.20.0** - Type-safe SQLite wrapper (offline-first)
- **Cloud Firestore 5.4.3** - Cloud database for real-time sync

### UI/Charts
- **fl_chart 0.70.1** - Beautiful charts and graphs
- **intl 0.20.1** - Internationalization and formatting

### Barcode & QR
- **mobile_scanner 5.2.3** - Barcode scanning
- **qr_flutter 4.1.0** - QR code generation
- **barcode_widget 2.0.4** - Barcode display

### PDF & Printing
- **pdf 3.11.1** - PDF generation
- **printing 5.13.4** - Printing support

### Authentication
- **Firebase Auth 5.3.1** - User authentication
- **Firebase Core 3.6.0** - Firebase SDK

### Storage & Media
- **Firebase Storage 12.3.2** - Cloud file storage
- **image_picker 1.1.2** - Image selection
- **cached_network_image 3.4.1** - Image caching

### Utilities
- **uuid 4.5.1** - Unique ID generation
- **shared_preferences 2.5.3** - Key-value storage
- **path_provider 2.1.0** - File system paths

### Navigation
- **go_router 14.6.2** - Declarative routing

---

## 🎨 UI/UX Design

### Color Palette

```dart
Primary Teal:      #00BFA5  // Main brand color
Dark Navy:         #1A2332  // Accent color
Light Gray:        #F5F5F5  // Background
White:             #FFFFFF  // Cards and surfaces
Text Primary:      #1A1A1A  // Main text
Text Secondary:    #757575  // Secondary text
Error Red:         #E53935  // Errors and warnings
Success Green:     #4CAF50  // Success states
Warning Orange:    #FF9800  // Warnings
Chart Blue:        #2196F3  // Chart colors
Chart Purple:      #9C27B0  // Chart colors
```

### Screen Descriptions

#### 1. **Login Screen**
- Simple authentication with username/password
- Demo credentials provided: `admin / admin123`
- Material Design input fields with validation
- Loading state during authentication

#### 2. **Dashboard Screen**
- **KPI Cards**: Total sales, revenue with trend indicators
- **Sales Overview Chart**: Line chart showing hourly sales
- **Top Categories Chart**: Pie chart with category breakdown
- Real-time data updates
- Date filter (Today, Week, Month)

#### 3. **POS Screen (Point of Sale)**
- **Left Panel**: Product grid with category filters
- **Right Panel**: Cart with quantity management
- Real-time search functionality
- Add to cart with one tap
- Quantity adjustment controls
- Checkout with payment method selection (Cash/Card)
- Low stock indicators
- Barcode scanner integration

#### 4. **Inventory Screen**
- Searchable product list with table view
- Category filters
- Stock level indicators (In Stock / Low Stock / Out of Stock)
- Add/Edit/Delete product operations
- Visual stock warnings
- Sortable columns
- Bulk operations support

#### 5. **Sales History Screen**
- Chronological order list with date/time
- Status badges (Paid, Void, Refunded, Parked)
- Payment method display
- Order details modal with item breakdown
- Subtotal, tax, discount, and total breakdown
- Filter by date range and status

#### 6. **Settings Screen**
- Hardware configuration (Printer, Card Reader, Scanner)
- Financial settings (Tax rates, Tipping, Digital receipts)
- Account management
- Security settings (Manager PIN)
- Search functionality for settings

---

## 🔐 Security Features

### Authentication & Authorization
- **Role-Based Access Control (RBAC)**: Admin and Cashier roles
- **Password Hashing**: Bcrypt for production use (demo uses plain text)
- **Session Management**: Secure session handling with timeout
- **PIN Protection**: Manager PIN for sensitive operations

### Data Security
- **Local Database Encryption**: SQLite encryption support
- **Firebase Security Rules**: Firestore rules for data access control
- **Audit Logging**: All critical operations logged with user tracking
- **Secure Storage**: Credentials stored in secure storage

### Best Practices
- Input validation on all forms
- SQL injection prevention through parameterized queries
- XSS prevention in web version
- Rate limiting on API calls
- Secure communication (HTTPS/SSL)

---

## 🚀 Getting Started

### Prerequisites

```bash
Flutter SDK: 3.35.4
Dart SDK: 3.9.2
Android Studio / VS Code
Git
```

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/retail-pro.git
cd retail-pro
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate database code**
```bash
dart run build_runner build
```

4. **Run the app**
```bash
# For web
flutter run -d chrome

# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your app (Android/iOS/Web)
3. Download configuration files:
   - `google-services.json` for Android → `android/app/`
   - `GoogleService-Info.plist` for iOS → `ios/Runner/`
4. Update `lib/firebase_options.dart` with your Firebase configuration
5. Enable Firestore Database in Firebase Console
6. Set up Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Products collection
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Categories collection
    match /categories/{categoryId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null;
    }
  }
}
```

---

## 📱 Building for Production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Google Play)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (requires macOS)

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

Output: `build/web/`

---

## 🧪 Testing

### Run Unit Tests

```bash
flutter test
```

### Run Integration Tests

```bash
flutter test integration_test/
```

### Code Coverage

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📈 Performance Optimization

- **Lazy Loading**: Products and orders loaded on-demand
- **Image Caching**: Network images cached for faster loading
- **Database Indexing**: Optimized queries with proper indexes
- **State Management**: Efficient state updates with Riverpod
- **Build Optimization**: Release builds with code minification
- **Memory Management**: Proper disposal of controllers and streams

---

## 🔄 Data Flow

### Order Processing Flow

```
1. User adds products to cart (POS Screen)
      ↓
2. Calculates subtotal, tax, and total
      ↓
3. User selects payment method (Cash/Card)
      ↓
4. Order is created with invoice number
      ↓
5. Order saved to Firestore with items
      ↓
6. Product stock updated in real-time
      ↓
7. Audit log entry created
      ↓
8. Receipt generated (optional)
      ↓
9. Cart cleared and ready for next order
```

### Inventory Update Flow

```
1. Admin adds/edits product (Inventory Screen)
      ↓
2. Validation checks (SKU uniqueness, price validation)
      ↓
3. Product saved to Firestore
      ↓
4. Local SQLite database synced
      ↓
5. UI updated with new product
      ↓
6. Audit log entry for tracking
```

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style

- Follow Dart's official style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features
- Update documentation as needed

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👥 Authors

- **Development Team** - Initial work and ongoing maintenance

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend infrastructure
- Community contributors and package authors
- Material Design team for UI guidelines

---

## 📞 Support

For support, please contact:
- Email: support@retailpro.com
- Issues: [GitHub Issues](https://github.com/yourusername/retail-pro/issues)
- Documentation: [Wiki](https://github.com/yourusername/retail-pro/wiki)

---

## 🗺️ Roadmap

### Version 1.1 (Planned)
- [ ] Customer loyalty program integration
- [ ] Email receipt generation
- [ ] Advanced reporting and analytics
- [ ] Multi-store support
- [ ] Shift management
- [ ] Cash drawer tracking

### Version 1.2 (Planned)
- [ ] Offline mode with sync
- [ ] Barcode label printing
- [ ] Purchase order management
- [ ] Supplier management
- [ ] Employee time tracking
- [ ] Multi-currency support

### Version 2.0 (Future)
- [ ] AI-powered inventory forecasting
- [ ] Customer relationship management (CRM)
- [ ] Marketing automation
- [ ] Mobile POS (Android/iOS apps)
- [ ] Integration with accounting software
- [ ] Advanced security features

---

## 📊 Application Metrics

- **Lines of Code**: ~3,500+
- **Number of Screens**: 6
- **Database Tables**: 9
- **API Endpoints**: REST with Firestore
- **Supported Platforms**: Web, Android, iOS
- **Test Coverage**: 80%+ (target)

---

## 🔍 Troubleshooting

### Common Issues

**Issue**: Build fails with Drift errors
```bash
Solution: Run dart run build_runner build --delete-conflicting-outputs
```

**Issue**: Firebase initialization error
```bash
Solution: Ensure firebase_options.dart has correct configuration
```

**Issue**: Products not loading
```bash
Solution: Check Firestore security rules and authentication
```

**Issue**: Images not displaying
```bash
Solution: Verify asset paths in pubspec.yaml
```

---

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [Drift Documentation](https://drift.simonbinder.eu/)
- [Material Design Guidelines](https://material.io/design)

---

**Built with ❤️ using Flutter**
