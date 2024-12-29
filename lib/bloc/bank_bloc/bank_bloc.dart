import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../model/bank_model.dart';
import '../../utills/app_utils.dart';

part 'bank_event.dart';
part 'bank_state.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
  BankBloc() : super(BankInitial()) {
    on<GetBankEvent>(getBankEvent);
    on<AddBankEvent>(addBankEvent);
    on<DeleteBankEvent>(deleteBankEvent);
    // on<BankEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  }
  FutureOr<void> getBankEvent(
      GetBankEvent event, Emitter<BankState> emit) async {
    emit(BankLoadingState());
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
          .collection('Bank')
          .get();
      print(querySnapshot.docs);
      List<Bank> BankList =
      querySnapshot.docs.map((doc) => Bank.fromFirestore(doc)).toList();
      emit(GetBankSuccessState(BankList));
    } catch (e) {
      print(e.toString());
      emit(BankErrorState(e.toString()));
    }
  }

  Future<void> addBankEvent(
      AddBankEvent event, Emitter<BankState> emit) async {
    emit(BankLoadingState());
    try {
      String? userId = FirebaseAuth.instance.currentUser!.uid;
      //String? tenantId = FirebaseAuth.instance.currentUser!.tenantId;


      String generatedId = AppUtils().generateFirestoreUniqueId();
      var collection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId) // Replace with the tenant ID
          .collection('Bank');

      Bank newBank = Bank(
        bankId: generatedId,
        bankName: event.bankName,
        accountNumber:event.accountNumber,
        createdBy: userId,
        updatedBy: userId,
        createdAt: Timestamp.fromDate(DateTime.now()),
        updatedAt: Timestamp.fromDate(DateTime.now()), accountName: event.accountName,
      );

      await collection.doc(generatedId).set(newBank.toFirestore());

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
          .collection('Bank')
          .get();
      print(querySnapshot.docs);
      List<Bank> BankList =
      querySnapshot.docs.map((doc) => Bank.fromFirestore(doc)).toList();
      emit(GetBankSuccessState(BankList));
      // emit(GetBankSuccessState(BankList));
    } catch (e) {
      print(e.toString());
      emit(BankErrorState(e.toString()));
    }
  }

  FutureOr<void> deleteBankEvent(DeleteBankEvent event, Emitter<BankState> emit) async{
    emit(BankLoadingState());
    try {
      String? userId = FirebaseAuth.instance.currentUser!.uid;

      var collection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId) // Replace with the tenant ID
          .collection('Bank').doc(event.bankId);


      await collection.delete();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
          .collection('Bank')
          .get();
      print(querySnapshot.docs);
      List<Bank> BankList =
      querySnapshot.docs.map((doc) => Bank.fromFirestore(doc)).toList();
      emit(GetBankSuccessState(BankList));
      // emit(GetBankSuccessState(BankList));
    } catch (e) {
      print(e.toString());
      emit(BankErrorState(e.toString()));
    }
  }
}
