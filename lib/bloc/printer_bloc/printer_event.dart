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
  final String port;
  final String type;
  final bool isPrinterUsb;
  final UserModel userModel;

  AddPrinterEvent(
      this.printerName, this.tenantId, this.ip, this.port, this.type,this.isPrinterUsb, this.userModel);
}

class DeletePrinterEvent extends PrinterEvent {
  final String printerId;
  final String tenantId;
  final UserModel userModel;

  DeletePrinterEvent(this.printerId, this.tenantId,this.userModel);
}

class EditPrinterEvent extends PrinterEvent {
  final String printerId;
  final String printerEditedName;
  final String tenantId;

  EditPrinterEvent(this.printerId, this.printerEditedName, this.tenantId);
}
