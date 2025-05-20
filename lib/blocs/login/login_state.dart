import 'package:equatable/equatable.dart';
import 'package:bloc_dio_laravel_api/core/models/auth_response.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  final String token;
  final String message;
  final bool success;

  const LoginSuccess({
    required this.token,
    this.message = 'Login success.',
    this.success = true,
  });

  factory LoginSuccess.fromAuthResponse(AuthResponse response) {
    return LoginSuccess(
      token: response.token,
      message: response.message,
      success: response.success,
    );
  }

  @override
  List<Object> get props => [token, message, success];
}

class LoginFailed extends LoginState {
  final String error;

  const LoginFailed({required this.error});

  @override
  List<Object> get props => [error];
}
