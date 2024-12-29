part of 'bank_bloc.dart';

@immutable
abstract class BankEvent {}
class GetBankEvent extends BankEvent {
  final String tenantId;
  GetBankEvent(this.tenantId);
}
class AddBankEvent extends BankEvent {
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String tenantId;

  AddBankEvent(this.bankName,this.tenantId, this.accountNumber, this.accountName);
}
class DeleteBankEvent extends BankEvent {
  final String bankId;
  final String tenantId;

  DeleteBankEvent(this.bankId,this.tenantId);
}
class EditBankEvent extends BankEvent {
  final String bankId;
  final String bankEditedName;
  final String tenantId;


  EditBankEvent(this.bankId,this.bankEditedName,this.tenantId);
}
