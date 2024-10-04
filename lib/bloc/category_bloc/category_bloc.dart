import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:pos_admin/model/category_model.dart';
import 'package:pos_admin/utills/app_utils.dart';

part 'category_event.dart';

part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<GetCategoryEvent>(getCategoryEvent);
    on<AddCategoryEvent>(addCategoryEvent);
    on<DeleteCategoryEvent>(deleteCategoryEvent);

    // on<CategoryEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  }

  FutureOr<void> getCategoryEvent(
      GetCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoadingState());
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
          .collection('Category')
          .get();
      print(querySnapshot.docs);
      List<Category> categoryList =
          querySnapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      emit(GetCategorySuccessState(categoryList));
    } catch (e) {
      print(e.toString());
      emit(CategoryErrorState(e.toString()));
    }
  }

  Future<void> addCategoryEvent(
      AddCategoryEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoadingState());
    try {
      String? userId = FirebaseAuth.instance.currentUser!.uid;
      String? tenantId = FirebaseAuth.instance.currentUser!.tenantId;


      String generatedId = AppUtils().generateFirestoreUniqueId();
      var collection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP') // Replace with the tenant ID
          .collection('Category');

      Category newCategory = Category(
        categoryId: generatedId,
        categoryName: event.categoryName,
        createdBy: userId,
        updatedBy: userId,
        createdAt: Timestamp.fromDate(DateTime.now()),
        updatedAt: Timestamp.fromDate(DateTime.now()),
      );

      await collection.doc(generatedId).set(newCategory.toFirestore());

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP')
          .collection('Category')
          .get();
      print(querySnapshot.docs);
      List<Category> categoryList =
          querySnapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      emit(GetCategorySuccessState(categoryList));
      // emit(GetCategorySuccessState(categoryList));
    } catch (e) {
      print(e.toString());
      emit(CategoryErrorState(e.toString()));
    }
  }

  FutureOr<void> deleteCategoryEvent(DeleteCategoryEvent event, Emitter<CategoryState> emit) async{
    emit(CategoryLoadingState());
    try {
      String? userId = FirebaseAuth.instance.currentUser!.uid;

      var collection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP') // Replace with the tenant ID
          .collection('Category').doc(event.categoryId);


      await collection.delete();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP')
          .collection('Category')
          .get();
      print(querySnapshot.docs);
      List<Category> categoryList =
      querySnapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      emit(GetCategorySuccessState(categoryList));
      // emit(GetCategorySuccessState(categoryList));
    } catch (e) {
      print(e.toString());
      emit(CategoryErrorState(e.toString()));
    }
  }
}
