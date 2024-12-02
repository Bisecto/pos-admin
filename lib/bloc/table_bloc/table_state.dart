part of 'table_bloc.dart';


sealed class TableState {}

final class TableInitial extends TableState {}
class TableLoadingState extends TableState {}
class AddTableLoadingState extends TableState {}
class TableErrorState extends TableState {
  final String error;

  TableErrorState(this.error);
}
class GetTableSuccessState extends TableState {
  List<TableModel> tableList;


  GetTableSuccessState(
      this.tableList
      );
}