import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class LocalAuthService {
  final storage = FlutterSecureStorage();

  Future<void> _initDefaultUser() async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users_list') ?? [];

    if (users.isEmpty) {
      final defaultUser = User(
        id: 'default_user_123',
        firstName: 'Test',
        lastName: 'User',
        email: 'test@test.com',
        passwordHash: hashPassword('Test123!', 'default_user_123'),
        createdAt: DateTime.now(),
      );

      users.add(jsonEncode(defaultUser.toJson()));
      await prefs.setStringList('users_list', users);
    }
  }

  Future<void> register(User user) async {
    await _initDefaultUser();
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users_list') ?? [];

    users.add(jsonEncode(user.toJson()));
    await prefs.setStringList('users_list', users);
    await prefs.setString('current_user_id', user.id);
  }

  Future<User?> login(String email, String password) async {
    await _initDefaultUser();
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users_list') ?? [];

    if (email == 'test@test.com' && password == 'Test123!') {
      final testUser = User(
        id: 'default_user_123',
        firstName: 'Test',
        lastName: 'User',
        email: 'test@test.com',
        passwordHash: hashPassword('Test123!', 'default_user_123'),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await prefs.setString('current_user_id', testUser.id);
      return testUser;
    }

    for (var userJson in users) {
      final user = User.fromJson(jsonDecode(userJson));
      final expectedHash = hashPassword(password, user.id);

      if (user.email == email && user.passwordHash == expectedHash) {
        await prefs.setString('current_user_id', user.id);

        final updatedUser = User(
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          passwordHash: user.passwordHash,
          phoneNumber: user.phoneNumber,
          dateOfBirth: user.dateOfBirth,
          profileImage: user.profileImage,
          createdAt: user.createdAt,
          lastLoginAt: DateTime.now(),
        );

        await updateUserInStorage(updatedUser);
        return updatedUser;
      }
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
  }

  Future<bool> isUserExists(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users_list') ?? [];

    for (var userJson in users) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.email == email) {
        return true;
      }
    }
    return false;
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('current_user_id');

    if (currentUserId == null) return null;

    final users = prefs.getStringList('users_list') ?? [];
    for (var userJson in users) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.id == currentUserId) {
        return user;
      }
    }
    return null;
  }

  Future<void> updateProfile(User user) async {
    await updateUserInStorage(user);
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return false;

    if (currentUser.passwordHash !=
        hashPassword(currentPassword, currentUser.id)) {
      return false;
    }

    final updatedUser = User(
      id: currentUser.id,
      firstName: currentUser.firstName,
      lastName: currentUser.lastName,
      email: currentUser.email,
      passwordHash: hashPassword(newPassword, currentUser.id),
      phoneNumber: currentUser.phoneNumber,
      dateOfBirth: currentUser.dateOfBirth,
      profileImage: currentUser.profileImage,
      createdAt: currentUser.createdAt,
      lastLoginAt: currentUser.lastLoginAt,
    );

    await updateUserInStorage(updatedUser);
    return true;
  }

  Future<void> updateUserInStorage(User updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList('users_list') ?? [];

    final updatedUsers = users.map((userJson) {
      final user = User.fromJson(jsonDecode(userJson));
      if (user.id == updatedUser.id) {
        return jsonEncode(updatedUser.toJson());
      }
      return userJson;
    }).toList();

    await prefs.setStringList('users_list', updatedUsers);
  }

  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
