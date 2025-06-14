part of 'table_bloc.dart';

@immutable
abstract class TableEvent {}

class GetTableEvent extends TableEvent {
  final String tenantId;

  GetTableEvent(this.tenantId);
}

class AddTableEvent extends TableEvent {
  final String tenantId;

  final String tableName;
  final UserModel userModel;

  AddTableEvent(this.tableName, this.tenantId, this.userModel);
}
class DeleteTableEvent extends TableEvent {
  final String tableId;
  final String tenantId;

  DeleteTableEvent(this.tableId, this.tenantId);
}
