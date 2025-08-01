import 'package:equatable/equatable.dart';

import '../models/user_model.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  final String field;
  AuthError(this.message, this.field);
  @override
  List<Object?> get props => [message, field];
}

class AuthLoggedOut extends AuthState {}

class AuthRegistered extends AuthState {
  final User user;
  AuthRegistered(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthValidationError extends AuthState {
  final Map<String, String> errors;
  AuthValidationError(this.errors);
  @override
  List<Object?> get props => [errors];
}
