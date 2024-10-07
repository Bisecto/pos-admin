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

class SignUpEventClick extends AuthEvent {
  final String email;
  final String password;
  String fullname;
  String imageUrl;
  String phone;
  String role;
  String tenantId;

  // final String loginOption;
  // final String accessPin;

  SignUpEventClick(this.email, this.tenantId, this.phone, this.imageUrl,
      this.fullname, this.role, this.password);
}
