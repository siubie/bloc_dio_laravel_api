import 'package:bloc/bloc.dart';
import 'package:bloc_dio_laravel_api/core/constants/api_urls.dart';
import 'package:bloc_dio_laravel_api/core/models/auth_response.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_client.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final DioClient _dioClient;

  LoginBloc({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient(),
      super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginReset>(_onLoginReset);
  }

  void _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginInProgress());

    try {
      final response = await _dioClient.post(
        ApiUrls.login,
        data: {'email': event.email, 'password': event.password},
      );

      // For status code 201 (Created) or 200 (OK)
      if (response.statusCode == 201 || response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);

        if (authResponse.success) {
          // Store token in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', authResponse.token);

          emit(LoginSuccess.fromAuthResponse(authResponse));
        } else {
          emit(LoginFailed(error: authResponse.message));
        }
      } else {
        emit(LoginFailed(error: 'Login failed. Please try again.'));
      }
    } catch (e) {
      String errorMessage = 'An error occurred. Please try again.';

      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMessage = 'Invalid email or password.';
        } else if (e.response?.data != null) {
          try {
            // Try to parse as AuthResponse
            final authResponse = AuthResponse.fromJson(e.response?.data);
            errorMessage = authResponse.message;
          } catch (_) {
            // Fallback to simple message extraction
            if (e.response?.data['message'] != null) {
              errorMessage = e.response?.data['message'] as String;
            }
          }
        }
      }

      emit(LoginFailed(error: errorMessage));
    }
  }

  void _onLoginReset(LoginReset event, Emitter<LoginState> emit) {
    emit(LoginInitial());
  }
}
