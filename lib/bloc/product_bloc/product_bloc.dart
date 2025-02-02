import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

import '../../model/brand_model.dart';
import '../../model/category_model.dart';
import '../../model/log_model.dart';
import '../../model/product_model.dart';
import '../../model/user_model.dart';
import '../../repository/log_actions.dart';
import '../../res/app_enums.dart';
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
      // String? productUrl =
      //     await uploadImageToFirebase(event.imageFile, event.productName);
      String generatedId = AppUtils().generateFirestoreUniqueId();
      var collection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(event.tenantId)
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
        productImageUrl: '',//productUrl!,
        price: event.price,
        sku: event.sku,
        //productType:event.productType,
        discount: event.discount,
        productType: event.productType, qty: event.qty,
      );

      await collection.doc(generatedId).set(newProduct.toFirestore());
      LogActivity logActivity = LogActivity();
      LogModel logModel = LogModel(
          actionType: LogActionType.productAdd.toString(),
          actionDescription:
              "${event.userModel.fullname} added a new product with id $generatedId and name ${event.productName}",
          performedBy: event.userModel.fullname,
          userId: event.userModel.userId);
      await logActivity.logAction(event.userModel.tenantId.trim(), logModel);
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
          .doc(event.tenantId) // Replace with the tenant ID
          .collection('Products')
          .doc(event.productId);

      await collection.delete();
      LogActivity logActivity = LogActivity();
      LogModel logModel = LogModel(
          actionType: LogActionType.productDelete.toString(),
          actionDescription:
              "${event.userModel.fullname} deleted product with id ${event.productId}",
          performedBy: event.userModel.fullname,
          userId: event.userModel.userId);
      await logActivity.logAction(event.userModel.tenantId.trim(), logModel);
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
      // emit(GetProductSuccessState(productList));
    } catch (e) {
      print(e.toString());
      emit(ProductErrorState(e.toString()));
    }
  }
}

// Future<String?> uploadImageToFirebase(File imageFile, String imageName) async {
//   try {
//     // Create a unique filename for the image using the current timestamp
//     String fileName = imageName.replaceAll(' ', '') +
//         DateTime.now().millisecondsSinceEpoch.toString();
//
//     // Define a Firebase Storage reference
//     Reference firebaseStorageRef =
//         FirebaseStorage.instance.ref().child('product_images/$fileName');
//
//     // Upload the file to Firebase Storage
//     UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
//
//     // Wait until the file upload completes
//     TaskSnapshot taskSnapshot = await uploadTask;
//
//     // Get the download URL of the uploaded file
//     String downloadURL = await taskSnapshot.ref.getDownloadURL();
//
//     print("Image uploaded successfully. URL: $downloadURL");
//
//     return downloadURL; // Return the URL of the uploaded image
//   } catch (e) {
//     print("Error uploading image: $e");
//     return null; // Return null if the upload fails
//   }
// }
