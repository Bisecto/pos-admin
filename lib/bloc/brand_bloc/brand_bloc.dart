import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../model/brand_model.dart';
import '../../utills/app_utils.dart';

part 'brand_event.dart';
part 'brand_state.dart';

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  BrandBloc() : super(BrandInitial()) {
    on<GetBrandEvent>(getBrandEvent);
    on<AddBrandEvent>(addBrandEvent);
    on<DeleteBrandEvent>(deleteBrandEvent);
    // on<BrandEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  }
  FutureOr<void> getBrandEvent(
      GetBrandEvent event, Emitter<BrandState> emit) async {
    emit(BrandLoadingState());
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
          .collection('Brand')
          .get();
      print(querySnapshot.docs);
      List<Brand> BrandList =
      querySnapshot.docs.map((doc) => Brand.fromFirestore(doc)).toList();
      emit(GetBrandSuccessState(BrandList));
    } catch (e) {
      print(e.toString());
      emit(BrandErrorState(e.toString()));
    }
  }

  Future<void> addBrandEvent(
      AddBrandEvent event, Emitter<BrandState> emit) async {
    emit(BrandLoadingState());
    try {
      String? userId = FirebaseAuth.instance.currentUser!.uid;
      //String? tenantId = FirebaseAuth.instance.currentUser!.tenantId;


      String generatedId = AppUtils().generateFirestoreUniqueId();
      var collection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP') // Replace with the tenant ID
          .collection('Brand');

      Brand newBrand = Brand(
        brandId: generatedId,
        brandName: event.brandName,
        createdBy: userId,
        updatedBy: userId,
        createdAt: Timestamp.fromDate(DateTime.now()),
        updatedAt: Timestamp.fromDate(DateTime.now()),
      );

      await collection.doc(generatedId).set(newBrand.toFirestore());

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP')
          .collection('Brand')
          .get();
      print(querySnapshot.docs);
      List<Brand> BrandList =
      querySnapshot.docs.map((doc) => Brand.fromFirestore(doc)).toList();
      emit(GetBrandSuccessState(BrandList));
      // emit(GetBrandSuccessState(BrandList));
    } catch (e) {
      print(e.toString());
      emit(BrandErrorState(e.toString()));
    }
  }

  FutureOr<void> deleteBrandEvent(DeleteBrandEvent event, Emitter<BrandState> emit) async{
    emit(BrandLoadingState());
    try {
      String? userId = FirebaseAuth.instance.currentUser!.uid;

      var collection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP') // Replace with the tenant ID
          .collection('Brand').doc(event.brandId);


      await collection.delete();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP')
          .collection('Brand')
          .get();
      print(querySnapshot.docs);
      List<Brand> BrandList =
      querySnapshot.docs.map((doc) => Brand.fromFirestore(doc)).toList();
      emit(GetBrandSuccessState(BrandList));
      // emit(GetBrandSuccessState(BrandList));
    } catch (e) {
      print(e.toString());
      emit(BrandErrorState(e.toString()));
    }
  }
}
