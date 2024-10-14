part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class OnClickedState extends AuthState {}

class LoadingState extends AuthState {}

class AccessTokenExpireState extends AuthState {}

class ErrorState extends AuthState {
  final String error;

  ErrorState(this.error);
}

class DeviceChange extends AuthState {
  final String msg;
  final String email;
  final String password;

  DeviceChange(this.msg, this.email, this.password);
}

class SuccessState extends AuthState {
  final String msg;
  TenantModel? tenantModel;

  SuccessState(this.msg, this.tenantModel);
}

class CreateUserSuccessState extends AuthState {
  final String msg;

  CreateUserSuccessState(this.msg);
}

class ResetPasswordSuccessState extends AuthState {
  final String msg;

  ResetPasswordSuccessState(this.msg);
}

class OtpRequestSuccessState extends AuthState {
  final String msg;
  final String userData;

  OtpRequestSuccessState(this.msg, this.userData);
}

class OtpVerificationSuccessState extends AuthState {
  final String msg;

  //final String userData;

  OtpVerificationSuccessState(this.msg);
}

class FindEmailSuccessPage extends AuthState {
  //final FindUserModel findUserModel;
  final String msg;

  FindEmailSuccessPage(this.msg);
}
