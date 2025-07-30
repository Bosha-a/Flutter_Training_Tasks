import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/local_auth_service.dart';
import '../models/user_model.dart';

// Auth States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthSecurityQuestion extends AuthState {
  final String question;
  AuthSecurityQuestion(this.question);
}

// Auth Events
abstract class AuthEvent {}

class RegisterEvent extends AuthEvent {
  final User user;
  final String securityQuestion;
  final String securityAnswer;
  RegisterEvent(this.user, this.securityQuestion, this.securityAnswer);
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;
  LoginEvent(this.email, this.password, this.rememberMe);
}

class CheckUserExistsEvent extends AuthEvent {
  final String email;
  CheckUserExistsEvent(this.email);
}

class UpdateProfileEvent extends AuthEvent {
  final User user;
  UpdateProfileEvent(this.user);
}

class ChangePasswordEvent extends AuthEvent {
  final String oldPassword;
  final String newPassword;
  ChangePasswordEvent(this.oldPassword, this.newPassword);
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}

class GetSecurityQuestionEvent extends AuthEvent {
  final String email;
  GetSecurityQuestionEvent(this.email);
}

class VerifySecurityAnswerEvent extends AuthEvent {
  final String email;
  final String answer;
  VerifySecurityAnswerEvent(this.email, this.answer);
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String newPassword;
  ResetPasswordEvent(this.email, this.newPassword);
}

// Auth Cubit
class AuthCubit extends Cubit<AuthState> {
  final LocalAuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _authService.checkAutoLogin();
      if (user != null) {
        await _authService.updateLastActivity();
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Error checking auth status: $e'));
    }
  }

  Future<void> register(RegisterEvent event) async {
    emit(AuthLoading());
    try {
      final success = await _authService.register(event.user, event.securityQuestion, event.securityAnswer);
      if (success) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError('Registration successful'));
        }
      } else {
        emit(AuthError('Registration failed: Email already exists'));
      }
    } catch (e) {
      emit(AuthError('Registration error: $e'));
    }
  }

  Future<void> login(LoginEvent event) async {
    emit(AuthLoading());
    try {
      final success = await _authService.login(event.email, event.password, event.rememberMe);
      if (success) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          await _authService.updateLastActivity();
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError('Login successful but failed to retrieve user'));
        }
      } else {
        emit(AuthError('Login failed: Invalid credentials'));
      }
    } catch (e) {
      emit(AuthError('Login error: $e'));
    }
  }

  Future<void> checkUserExists(CheckUserExistsEvent event) async {
    try {
      final exists = await _authService.isUserExists(event.email);
      emit(exists ? AuthError('User exists') : AuthError('User does not exist'));
    } catch (e) {
      emit(AuthError('Error checking user: $e'));
    }
  }

  Future<void> updateProfile(UpdateProfileEvent event) async {
    emit(AuthLoading());
    try {
      final success = await _authService.updateProfile(event.user);
      if (success) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          await _authService.updateLastActivity();
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError('Profile updated but failed to retrieve user'));
        }
      } else {
        emit(AuthError('Profile update failed'));
      }
    } catch (e) {
      emit(AuthError('Profile update error: $e'));
    }
  }

  Future<void> changePassword(ChangePasswordEvent event) async {
    emit(AuthLoading());
    try {
      final success = await _authService.changePassword(event.oldPassword, event.newPassword);
      if (success) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          await _authService.updateLastActivity();
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthError('Password changed but failed to retrieve user'));
        }
      } else {
        emit(AuthError('Password change failed: Incorrect old password'));
      }
    } catch (e) {
      emit(AuthError('Password change error: $e'));
    }
  }

  Future<void> getSecurityQuestion(GetSecurityQuestionEvent event) async {
    emit(AuthLoading());
    try {
      final question = await _authService.getSecurityQuestion(event.email);
      if (question != null) {
        emit(AuthSecurityQuestion(question));
      } else {
        emit(AuthError('No user found with this email'));
      }
    } catch (e) {
      emit(AuthError('Error retrieving security question: $e'));
    }
  }

  Future<void> verifySecurityAnswer(VerifySecurityAnswerEvent event) async {
    emit(AuthLoading());
    try {
      final success = await _authService.verifySecurityAnswer(event.email, event.answer);
      if (success) {
        emit(AuthSecurityQuestion('')); // Placeholder to allow password reset
      } else {
        emit(AuthError('Incorrect security answer'));
      }
    } catch (e) {
      emit(AuthError('Error verifying security answer: $e'));
    }
  }

  Future<void> resetPassword(ResetPasswordEvent event) async {
    emit(AuthLoading());
    try {
      final success = await _authService.resetPassword(event.email, event.newPassword);
      if (success) {
        emit(AuthUnauthenticated());
        // Show success message in UI
      } else {
        emit(AuthError('Password reset failed'));
      }
    } catch (e) {
      emit(AuthError('Password reset error: $e'));
    }
  }

  Future<void> logout(LogoutEvent event) async {
    emit(AuthLoading());
    try {
      await _authService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout error: $e'));
    }
  }
}