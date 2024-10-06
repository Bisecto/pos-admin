part of 'user_bloc.dart';

@immutable
sealed class UserState {}

final class UserInitial extends UserState {}

class UserLoadingState extends UserState {}

class AddUserLoadingState extends UserState {}

class UserErrorState extends UserState {
  final String error;

  UserErrorState(this.error);
}

class GetUserSuccessState extends UserState {
  final List<UserModel> userList;

  GetUserSuccessState(this.userList);
}
