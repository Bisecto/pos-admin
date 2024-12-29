part of 'bank_bloc.dart';

@immutable
sealed class BankState {}

final class BankInitial extends BankState {}
class BankLoadingState extends BankState {}
class AddBankLoadingState extends BankState {}
class BankErrorState extends BankState {
  final String error;

  BankErrorState(this.error);
}
class GetBankSuccessState extends BankState {
  final List<Bank> bankList;


  GetBankSuccessState(
      this.bankList,);
}