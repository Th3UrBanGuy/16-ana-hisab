# Firebase Hosting Deployment Guide for NeoPOS

## Prerequisites
1. Firebase CLI installed: `npm install -g firebase-tools`
2. Firebase project created: `sholoanahisab`

## Deployment Steps

### 1. Login to Firebase
```bash
firebase login
```

### 2. Initialize Firebase in your project
```bash
cd /home/user/flutter_app
firebase init
```

Select:
- Hosting
- Firestore

Use existing project: `sholoanahisab`

### 3. Build Flutter web app
```bash
flutter build web --release
```

### 4. Deploy to Firebase Hosting
```bash
firebase deploy
```

Your app will be available at:
- https://sholoanahisab.web.app
- https://sholoanahisab.firebaseapp.com

## Automated Deployment Script

```bash
#!/bin/bash
cd /home/user/flutter_app

# Build
echo "Building Flutter web app..."
flutter build web --release

# Deploy
echo "Deploying to Firebase..."
firebase deploy --only hosting

echo "✓ Deployment complete!"
echo "Visit: https://sholoanahisab.web.app"
```

## Security Considerations

✅ **Completed:**
- Password hashing with SHA-256
- Firebase Authentication integration
- Firestore security rules configured
- HTTPS enforced by Firebase Hosting
- Security headers configured

⚠️ **Before Production:**
1. Review and test Firestore security rules
2. Configure custom domain (optional)
3. Set up Firebase Auth email verification
4. Configure rate limiting in Firebase Console
5. Enable Firebase Performance Monitoring
6. Set up error tracking (Crashlytics)

## Admin Credentials

**Username:** admin
**Password:** Admin@123

⚠️ **CRITICAL:** Change admin password immediately after first login!

## Monitoring

- Firebase Console: https://console.firebase.google.com/project/sholoanahisab
- Hosting Dashboard: https://console.firebase.google.com/project/sholoanahisab/hosting
- Firestore Data: https://console.firebase.google.com/project/sholoanahisab/firestore

## Support

For issues or questions:
- Firebase Documentation: https://firebase.google.com/docs
- Flutter Web: https://flutter.dev/web
