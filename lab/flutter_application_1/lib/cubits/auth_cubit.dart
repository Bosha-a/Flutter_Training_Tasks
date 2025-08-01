import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_model.dart';
import '../services/local_auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalAuthService authService;
  AuthCubit(this.authService) : super(AuthInitial());

  void login(String email, String password, bool rememberMe) async {
    emit(AuthLoading());
    try {
      final user = await authService.login(email, password);
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(AuthError("Invalid email or password", "login"));
      }
    } catch (e) {
      emit(AuthError("Login failed: $e", "login"));
    }
  }

  void register(User user) async {
    emit(AuthLoading());
    await authService.register(user);
    emit(AuthRegistered(user));
  }

  void logout() async {
    await authService.logout();
    emit(AuthLoggedOut());
  }

  void validateForm(Map<String, String> formData) {
    final errors = <String, String>{};

    if (formData['firstName']!.length < 2) {
      errors['firstName'] = 'First name must be at least 2 characters';
    }
    if (formData['password']!.length < 8) {
      errors['password'] = 'Password must be strong';
    }
    if (errors.isNotEmpty) {
      emit(AuthValidationError(errors));
    }
  }
}
