import '../models/user_model.dart';
import '../services/local_auth_service.dart';

class AuthRepository {
  final LocalAuthService _authService;

  AuthRepository(this._authService);

  Future<User?> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  Future<void> register(User user) async {
    await _authService.register(user);
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<bool> isUserExists(String email) async {
    return await _authService.isUserExists(email);
  }

  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  Future<void> updateProfile(User user) async {
    await _authService.updateProfile(user);
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    return await _authService.changePassword(currentPassword, newPassword);
  }
}
