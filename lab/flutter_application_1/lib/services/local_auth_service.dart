import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class LocalAuthService {
  static const String _usersKey = 'users_list_json_array_of_all_users';
  static const String _sessionKey = 'user_session';
  final Uuid _uuid = Uuid();

  // Hash password
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Hash security answer
  String _hashSecurityAnswer(String answer) {
    return sha256.convert(utf8.encode(answer)).toString();
  }

  // Get SharedPreferences instance
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Register user
  Future<bool> register(User user, String securityQuestion, String securityAnswer) async {
    final prefs = await _getPrefs();
    if (await isUserExists(user.email)) {
      return false;
    }

    // Validate required user properties
    if (user.id.isEmpty || user.firstName.isEmpty || user.lastName.isEmpty || user.email.isEmpty) {
      throw Exception('Required user properties (id, firstName, lastName, email) cannot be empty');
    }

    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;

    // Create a new user with hashed password and security answer
    final newUser = User(
      id: user.id.isEmpty ? _uuid.v4() : user.id, // Ensure unique ID
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      passwordHash: _hashPassword(user.passwordHash.isEmpty ? 'default' : user.passwordHash),
      phoneNumber: user.phoneNumber,
      dateOfBirth: user.dateOfBirth,
      profileImage: user.profileImage,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      securityQuestion: securityQuestion,
      securityAnswer: securityAnswer.isEmpty ? null : _hashSecurityAnswer(securityAnswer),
    );

    users[newUser.id] = newUser.toJson();
    await prefs.setString(_usersKey, json.encode(users));
    return true;
  }

  // Login
  Future<bool> login(String email, String password, bool rememberMe) async {
    final prefs = await _getPrefs();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;

    final userJson = users.values.firstWhere(
      (user) => user['email'] == email,
      orElse: () => null,
    );

    if (userJson == null || userJson['passwordHash'] != _hashPassword(password)) {
      return false;
    }

    final user = User.fromJson(userJson);
    final sessionData = {
      'userId': user.id,
      'loginTime': DateTime.now().toIso8601String(),
      'expiryTime': DateTime.now().add(Duration(hours: 24)).toIso8601String(),
      'lastActivity': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_sessionKey, json.encode(sessionData));
    await prefs.setString('remember_me_${user.id}', rememberMe.toString());

    // Update lastLoginAt
    users[user.id] = {
      ...userJson,
      'lastLoginAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_usersKey, json.encode(users));
    return true;
  }

  // Check if user exists
  Future<bool> isUserExists(String email) async {
    final prefs = await _getPrefs();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;
    return users.values.any((user) => user['email'] == email);
  }

  // Update profile
  Future<bool> updateProfile(User updatedUser) async {
    final prefs = await _getPrefs();
    final session = await _getSession();
    if (session == null) return false;

    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;
    if (users.containsKey(session['userId'])) {
      final existingUser = users[session['userId']];
      // Validate required properties
      if (updatedUser.firstName.isEmpty || updatedUser.lastName.isEmpty || updatedUser.email.isEmpty) {
        return false;
      }
      users[session['userId']] = updatedUser.toJson()
        ..['securityQuestion'] = existingUser['securityQuestion']
        ..['securityAnswer'] = existingUser['securityAnswer']
        ..['passwordHash'] = existingUser['passwordHash']; // Preserve password
      await prefs.setString(_usersKey, json.encode(users));
      return true;
    }
    return false;
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final prefs = await _getPrefs();
    final session = await _getSession();
    if (session == null) return false;

    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;
    final userJson = users[session['userId']];
    if (userJson == null || userJson['passwordHash'] != _hashPassword(oldPassword)) {
      return false;
    }

    users[session['userId']] = {
      ...userJson,
      'passwordHash': _hashPassword(newPassword),
    };
    await prefs.setString(_usersKey, json.encode(users));
    return true;
  }

  // Forgot password: Get security question
  Future<String?> getSecurityQuestion(String email) async {
    final prefs = await _getPrefs();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;
    final userJson = users.values.firstWhere(
      (user) => user['email'] == email,
      orElse: () => null,
    );
    return userJson?['securityQuestion'];
  }

  // Forgot password: Verify security answer
  Future<bool> verifySecurityAnswer(String email, String answer) async {
    final prefs = await _getPrefs();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;
    final userJson = users.values.firstWhere(
      (user) => user['email'] == email,
      orElse: () => null,
    );
    if (userJson == null) return false;
    return userJson['securityAnswer'] == _hashSecurityAnswer(answer);
  }

  // Forgot password: Reset password
  Future<bool> resetPassword(String email, String newPassword) async {
    final prefs = await _getPrefs();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;
    final userJson = users.values.firstWhere(
      (user) => user['email'] == email,
      orElse: () => null,
    );
    if (userJson == null) return false;

    final userId = userJson['id'];
    users[userId] = {
      ...userJson,
      'passwordHash': _hashPassword(newPassword),
    };
    await prefs.setString(_usersKey, json.encode(users));
    return true;
  }

  // Logout
  Future<void> logout() async {
    final prefs = await _getPrefs();
    await prefs.remove(_sessionKey);
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final session = await _getSession();
    if (session == null) return null;

    final prefs = await _getPrefs();
    final usersJson = prefs.getString(_usersKey) ?? '{}';
    final users = json.decode(usersJson) as Map<String, dynamic>;
    final userJson = users[session['userId']];
    return userJson != null ? User.fromJson(userJson) : null;
  }

  // Session management
  Future<Map<String, dynamic>?> _getSession() async {
    final prefs = await _getPrefs();
    final sessionJson = prefs.getString(_sessionKey);
    if (sessionJson == null) return null;

    final session = json.decode(sessionJson) as Map<String, dynamic>;
    final expiryTime = DateTime.parse(session['expiryTime']);
    if (DateTime.now().isAfter(expiryTime)) {
      await prefs.remove(_sessionKey);
      return null;
    }
    return session;
  }

  // Auto-login check
  Future<User?> checkAutoLogin() async {
    final session = await _getSession();
    if (session == null) return null;

    final prefs = await _getPrefs();
    final rememberMe = prefs.getString('remember_me_${session['userId']}') == 'true';
    if (!rememberMe) return null;

    return await getCurrentUser();
  }

  // Update last activity
  Future<void> updateLastActivity() async {
    final session = await _getSession();
    if (session == null) return;

    session['lastActivity'] = DateTime.now().toIso8601String();
    final prefs = await _getPrefs();
    await prefs.setString(_sessionKey, json.encode(session));
  }
}