import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  
  String? _currentUserId;
  Map<String, dynamic>? _currentUserData;

  // Get current user data
  Map<String, dynamic>? get currentUser => _currentUserData;
  String? get currentUserId => _currentUserId;

  // Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Initialize authentication - check if user is logged in
  Future<bool> initialize() async {
    try {
      // Check if we have Firebase Auth user
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        // Try to load user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        
        if (userDoc.exists) {
          _currentUserId = firebaseUser.uid;
          _currentUserData = userDoc.data();
          return true;
        }
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Initialize auth error: $e');
      }
      return false;
    }
  }

  // Login with username and password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Hash the password
      final hashedPassword = _hashPassword(password);

      // Query Firestore for user with matching username and password
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: hashedPassword)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Invalid username or password',
        };
      }

      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      
      // Sign in anonymously to Firebase Auth (for session management)
      await _auth.signInAnonymously();
      
      // Update user document with Firebase Auth UID
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          ...userData,
          'id': userDoc.id,
          'lastLogin': DateTime.now().toIso8601String(),
        });
        
        _currentUserId = firebaseUser.uid;
        _currentUserData = userData;
      }

      return {
        'success': true,
        'user': userData,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Login error: $e');
      }
      return {
        'success': false,
        'message': 'Login failed. Please try again.',
      };
    }
  }

  // Register new user (admin function)
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      // Check if username already exists
      final existingUser = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Username already exists',
        };
      }

      // Hash password
      final hashedPassword = _hashPassword(password);

      // Create user document
      final userData = {
        'username': username,
        'password': hashedPassword,
        'fullName': fullName,
        'role': role,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection('users').add(userData);

      return {
        'success': true,
        'message': 'User registered successfully',
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Register error: $e');
      }
      return {
        'success': false,
        'message': 'Registration failed. Please try again.',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_currentUserId == null || _currentUserData == null) {
        return {
          'success': false,
          'message': 'Not logged in',
        };
      }

      // Verify current password
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (_currentUserData!['password'] != hashedCurrentPassword) {
        return {
          'success': false,
          'message': 'Current password is incorrect',
        };
      }

      // Hash new password
      final hashedNewPassword = _hashPassword(newPassword);

      // Update password in Firestore
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .update({'password': hashedNewPassword});

      _currentUserData!['password'] = hashedNewPassword;

      return {
        'success': true,
        'message': 'Password changed successfully',
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Change password error: $e');
      }
      return {
        'success': false,
        'message': 'Failed to change password',
      };
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUserId = null;
      _currentUserData = null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Logout error: $e');
      }
    }
  }

  // Check if user has admin role
  bool isAdmin() {
    return _currentUserData?['role'] == 'Admin';
  }

  // Check if user has cashier role
  bool isCashier() {
    return _currentUserData?['role'] == 'Cashier';
  }
}
