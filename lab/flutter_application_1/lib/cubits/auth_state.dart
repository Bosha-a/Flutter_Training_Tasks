import 'package:equatable/equatable.dart';
import '../models/user_model.dart'; // Update path as needed

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

// 1. App startup state
class AuthInitial extends AuthState {}

// 2. During authentication process
class AuthLoading extends AuthState {}

// 3. Login successful
class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

// 4. Error with a specific field
class AuthError extends AuthState {
  final String message;
  final String field;

  const AuthError(this.message, this.field);

  @override
  List<Object?> get props => [message, field];
}

// 5. User logged out
class AuthLoggedOut extends AuthState {}

// 6. Registration successful
class AuthRegistered extends AuthState {
  final User user;

  const AuthRegistered(this.user);

  @override
  List<Object?> get props => [user];
}

// 7. Form validation errors
class AuthValidationError extends AuthState {
  final Map<String, String> errors;

  const AuthValidationError(this.errors);

  @override
  List<Object?> get props => [errors];
}
