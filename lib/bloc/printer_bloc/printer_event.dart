part of 'printer_bloc.dart';

abstract class PrinterEvent {}

class GetPrinterEvent extends PrinterEvent {
  final String tenantId;

  GetPrinterEvent(this.tenantId);
}

class AddPrinterEvent extends PrinterEvent {
  final String printerName;
  final String tenantId;
  final String ip;
  final int port;
  final String type;

  AddPrinterEvent(
      this.printerName, this.tenantId, this.ip, this.port, this.type);
}

class DeletePrinterEvent extends PrinterEvent {
  final String printerId;
  final String tenantId;

  DeletePrinterEvent(this.printerId, this.tenantId);
}

class EditPrinterEvent extends PrinterEvent {
  final String printerId;
  final String printerEditedName;
  final String tenantId;

  EditPrinterEvent(this.printerId, this.printerEditedName, this.tenantId);
}
