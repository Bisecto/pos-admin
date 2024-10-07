import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../model/brand_model.dart';
import '../../model/category_model.dart';
import '../../model/product_model.dart';
import '../../utills/app_utils.dart';

part 'product_event.dart';

part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<GetProductEvent>(getProductEvent);
    on<AddProductEvent>(addProductEvent);
    on<DeleteProductEvent>(deleteProductEvent);
    // on<ProductEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  }

  FutureOr<void> getProductEvent(
      GetProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      QuerySnapshot brandQuerySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
          .collection('Brand')
          .get();
      print(brandQuerySnapshot.docs);
      List<Brand> BrandList = brandQuerySnapshot.docs
          .map((doc) => Brand.fromFirestore(doc))
          .toList();

      QuerySnapshot categoryQuerySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
          .collection('Category')
          .get();
      print(categoryQuerySnapshot.docs);
      List<Category> categoryList = categoryQuerySnapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
          .collection('Products')
          .get();
      print(querySnapshot.docs);
      List<Product> productList =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      emit(GetProductSuccessState(productList, BrandList, categoryList));
    } catch (e) {
      print(e.toString());
      emit(ProductErrorState(e.toString()));
    }
  }

  Future<void> addProductEvent(
      AddProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      String? userId = FirebaseAuth.instance.currentUser!.uid;

      String generatedId = AppUtils().generateFirestoreUniqueId();
      var collection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP')
          .collection('Products');

      Product newProduct = Product(
        productId: generatedId,
        productName: event.productName,
        createdBy: userId,
        updatedBy: userId,
        createdAt: Timestamp.fromDate(DateTime.now()),
        updatedAt: Timestamp.fromDate(DateTime.now()),
        categoryId: event.categoryId,
        brandId: event.brandId,
        productImageUrl: '',
        price: event.price,
        sku: event.sku, discount: event.discount,
      );

      await collection.doc(generatedId).set(newProduct.toFirestore());
      QuerySnapshot brandQuerySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc("8V8YTiKWyObO7tppMHeP")
          .collection('Brand')
          .get();
      print(brandQuerySnapshot.docs);
      List<Brand> BrandList = brandQuerySnapshot.docs
          .map((doc) => Brand.fromFirestore(doc))
          .toList();

      QuerySnapshot categoryQuerySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc("8V8YTiKWyObO7tppMHeP")
          .collection('Category')
          .get();
      print(categoryQuerySnapshot.docs);
      List<Category> categoryList = categoryQuerySnapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP')
          .collection('Products')
          .get();
      print(querySnapshot.docs);
      List<Product> productList =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      emit(GetProductSuccessState(productList, BrandList, categoryList));
      // emit(GetProductSuccessState(productList));
    } catch (e) {
      print(e.toString());
      emit(ProductErrorState(e.toString()));
    }
  }

  FutureOr<void> deleteProductEvent(
      DeleteProductEvent event, Emitter<ProductState> emit) async {
    emit(ProductLoadingState());
    try {
      String? userId = FirebaseAuth.instance.currentUser!.uid;

      var collection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP') // Replace with the tenant ID
          .collection('Products')
          .doc(event.productId);

      await collection.delete();
      QuerySnapshot brandQuerySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc("8V8YTiKWyObO7tppMHeP")
          .collection('Brand')
          .get();
      print(brandQuerySnapshot.docs);
      List<Brand> BrandList = brandQuerySnapshot.docs
          .map((doc) => Brand.fromFirestore(doc))
          .toList();

      QuerySnapshot categoryQuerySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc("8V8YTiKWyObO7tppMHeP")
          .collection('Category')
          .get();
      print(categoryQuerySnapshot.docs);
      List<Category> categoryList = categoryQuerySnapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc('8V8YTiKWyObO7tppMHeP')
          .collection('Products')
          .get();
      print(querySnapshot.docs);
      List<Product> productList =
          querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      emit(GetProductSuccessState(productList, BrandList, categoryList));
      // emit(GetProductSuccessState(productList));
    } catch (e) {
      print(e.toString());
      emit(ProductErrorState(e.toString()));
    }
  }
}
