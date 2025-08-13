part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final User user;
  final String token;

  AuthSuccess({required this.user, required this.token});
}

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure({required this.message});
}
