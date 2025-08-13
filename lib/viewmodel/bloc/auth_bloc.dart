import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/api_service.dart';
import '../../data/models/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService _apiService = ApiService();

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await _apiService.login(
        email: event.email,
        password: event.password,
        role: event.role,
      );

      // Handle the encrypted response structure
      if (response['encrypted'] == true && response['data'] != null) {
        final data = response['data'];
        final user = User.fromJson(data['user']);
        final token = data['token'] ?? '';

        emit(AuthSuccess(user: user, token: token));
      } else {
        emit(AuthFailure(message: 'Invalid response format'));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
}
