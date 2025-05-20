import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/constants/api_urls.dart';
import '../../core/models/logout_response.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DioClient _dioClient;

  HomeBloc({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient(),
      super(HomeInitial()) {
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        // If no token, just consider it a successful logout
        await prefs.remove('auth_token');
        emit(HomeLogoutSuccess());
        return;
      }

      // Make API call to logout
      try {
        // Add token to the request headers
        final response = await _dioClient.post(
          ApiUrls.logout,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        // Parse the response
        final logoutResponse = LogoutResponse.fromJson(response.data);

        // Remove the token locally
        await prefs.remove('auth_token');

        // Emit success with the message from the response if available
        emit(HomeLogoutSuccess(message: logoutResponse.message));
      } catch (error) {
        // Even if the server call fails, we'll remove the token locally
        await prefs.remove('auth_token');

        // We'll still consider it a success since the user is logged out locally
        emit(const HomeLogoutSuccess(message: 'Logged out locally'));
      }
    } catch (e) {
      emit(HomeLogoutFailure(error: 'Logout failed: ${e.toString()}'));
    }
  }
}
