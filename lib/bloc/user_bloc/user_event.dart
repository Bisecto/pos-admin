part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class GetUserEvent extends UserEvent {
  final String tenantId;

  GetUserEvent(this.tenantId);
}

class AddUserEvent extends UserEvent {
  String email;
  String fullname;
  String imageUrl;
  String phone;
  String role;
  String tenantId;
  BuildContext context;

  AddUserEvent(this.email, this.tenantId, this.phone, this.imageUrl,
      this.fullname, this.role, this.context);
}

class DeleteUserEvent extends UserEvent {
  final String userId;

  DeleteUserEvent(this.userId);
}

class EditUserEvent extends UserEvent {
  UserModel user;

  EditUserEvent(this.user);
}
