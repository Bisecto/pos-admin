part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class InitialEvent extends AuthEvent {}

class SignInEventClick extends AuthEvent {
  final String userData;
  final String password;

  // final String loginOption;
  // final String accessPin;

  SignInEventClick(this.userData, this.password);
}


