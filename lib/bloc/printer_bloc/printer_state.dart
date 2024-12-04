part of 'printer_bloc.dart';

@immutable
abstract class PrinterState {}

final class PrinterInitial extends PrinterState {}
class PrinterLoadingState extends PrinterState {}
class AddPrinterLoadingState extends PrinterState {}
class PrinterErrorState extends PrinterState {
  final String error;

  PrinterErrorState(this.error);
}
class GetPrinterSuccessState extends PrinterState {
  final List<PrinterModel> printerList;


  GetPrinterSuccessState(
      this.printerList,);
}