import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'table_event.dart';
part 'table_state.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  TableBloc() : super(TableInitial()) {
    on<TableEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
