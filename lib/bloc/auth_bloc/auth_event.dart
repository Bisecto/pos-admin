part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class InitialEvent extends AuthEvent {}

class SignInEventClick extends AuthEvent {
  final String userData;
  final String password;

  SignInEventClick(this.userData, this.password);
}

class ResetPasswordEvent extends AuthEvent {
  final String email;

  ResetPasswordEvent(this.email);
}


class CreateUserRoleEventClick extends AuthEvent {
  final String email;
  final String password;
  String fullname;
  String imageUrl;
  String phone;
  String role;
  String tenantId;
  TenantModel tenantModel;
  final UserModel userModel;

  // final String loginOption;
  // final String accessPin;

  CreateUserRoleEventClick(this.email, this.tenantId, this.phone, this.imageUrl,
      this.fullname, this.role, this.password, this.tenantModel, this.userModel);
}
