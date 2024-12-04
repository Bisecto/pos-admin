import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:pos_admin/model/printer_model.dart';
import 'package:pos_admin/utills/app_utils.dart';

part 'printer_event.dart';

part 'printer_state.dart';

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  PrinterBloc() : super(PrinterInitial()) {
    on<GetPrinterEvent>(getPrinterEvent);
    on<AddPrinterEvent>(addPrinterEvent);
    on<DeletePrinterEvent>(deletePrinterEvent);

    // on<PrinterEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  }

  FutureOr<void> getPrinterEvent(
      GetPrinterEvent event, Emitter<PrinterState> emit) async {
    emit(PrinterLoadingState());
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
          .collection('Printer')
          .get();
      print(querySnapshot.docs);
      List<PrinterModel> printerList = querySnapshot.docs
          .map((doc) => PrinterModel.fromFirestore(doc))
          .toList();
      emit(GetPrinterSuccessState(printerList));
    } catch (e) {
      print(e.toString());
      emit(PrinterErrorState(e.toString()));
    }
  }

  Future<void> addPrinterEvent(
      AddPrinterEvent event, Emitter<PrinterState> emit) async {
    emit(PrinterLoadingState());
    try {
      String? userId = FirebaseAuth.instance.currentUser!.uid;
      String? tenantId = FirebaseAuth.instance.currentUser!.tenantId;

      String generatedId = AppUtils().generateFirestoreUniqueId();
      var collection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId) // Replace with the tenant ID
          .collection('Printer');

      PrinterModel newPrinter = PrinterModel(
        printerId: generatedId,
        printerName: event.printerName,
        createdBy: userId,
        updatedBy: userId,
        createdAt: Timestamp.fromDate(DateTime.now()),
        updatedAt: Timestamp.fromDate(DateTime.now()),
        ip: event.ip,
        port: event.port,
        type: event.type,
      );

      await collection.doc(generatedId).set(newPrinter.toFirestore());

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
          .collection('Printer')
          .get();
      print(querySnapshot.docs);
      List<PrinterModel> printerList = querySnapshot.docs
          .map((doc) => PrinterModel.fromFirestore(doc))
          .toList();
      emit(GetPrinterSuccessState(printerList));
      // emit(GetPrinterSuccessState(printerList));
    } catch (e) {
      print(e.toString());
      emit(PrinterErrorState(e.toString()));
    }
  }

  FutureOr<void> deletePrinterEvent(
      DeletePrinterEvent event, Emitter<PrinterState> emit) async {
    emit(PrinterLoadingState());
    try {
      String? userId = FirebaseAuth.instance.currentUser!.uid;

      var collection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId) // Replace with the tenant ID
          .collection('Printer')
          .doc(event.printerId);

      await collection.delete();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
          .collection('Printer')
          .get();
      print(querySnapshot.docs);
      List<PrinterModel> printerList = querySnapshot.docs
          .map((doc) => PrinterModel.fromFirestore(doc))
          .toList();
      emit(GetPrinterSuccessState(printerList));
      // emit(GetPrinterSuccessState(printerList));
    } catch (e) {
      print(e.toString());
      emit(PrinterErrorState(e.toString()));
    }
  }
}
