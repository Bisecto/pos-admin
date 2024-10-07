import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:pos_admin/repository/auth_service.dart';

import '../../model/user_model.dart';
import '../../utills/app_utils.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<GetUserEvent>(getUserEvent);
    //on<AddUserEvent>(addUserEvent);
    on<DeleteUserEvent>(deleteUserEvent);
    // on<UserEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  }

  FutureOr<void> getUserEvent(
      GetUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      print(querySnapshot.docs);
      List<UserModel> userList = querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      emit(GetUserSuccessState(
        userList,
      ));
    } catch (e) {
      print(e.toString());
      emit(UserErrorState(e.toString()));
    }
  }
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // AuthService authService=AuthService();
  // Future<void> addUserEvent(AddUserEvent event, Emitter<UserState> emit) async {
  //   emit(UserLoadingState());
  //
  //   try {
  //
  //
  //     User? adminUser = firebaseAuth
  //         .FirebaseAuth.instance.currentUser; // Store the current admin
  //     print("Creating user with email: ${event.email}");
  //     String userId   = await authService.registerWithEmailAndPassword("Qwerty123@", event.context, event.email);
  //
  //     var collection =
  //         FirebaseFirestore.instance.collection('Users').doc(userId);
  //     UserModel newUser = UserModel(
  //         userId: userId,
  //         email: event.email,
  //         fullname: event.fullname,
  //         imageUrl: 'imageUrl',
  //         // Placeholder
  //         phone: event.phone,
  //         role: event.role,
  //         tenantId: 'tenantId',
  //         // Placeholder, handle multi-tenancy if needed
  //         createdAt: Timestamp.fromDate(DateTime.now()),
  //         updatedAt: Timestamp.fromDate(DateTime.now()),
  //         accountStatus: true);
  //     await collection.set(newUser.toFirestore());
  //
  //     // Fetch and display the updated user list
  //     QuerySnapshot querySnapshot =
  //         await FirebaseFirestore.instance.collection('Users').get();
  //     List<UserModel> userList = querySnapshot.docs
  //         .map((doc) => UserModel.fromFirestore(doc))
  //         .toList();
  //
  //     if (adminUser != null) {
  //       print("Re-authenticating admin user...");
  //       await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: adminUser.email!, // Ensure admin email is not null
  //         password: "Qwerty123@", // Admin's password
  //       );
  //     }
  //
  //     // Emit success with the user list
  //     emit(GetUserSuccessState([]));
  //   }catch (e) {
  //     // Catch any other errors
  //     print("Error: ${e.toString()}");
  //     emit(UserErrorState(e.toString()));
  //   }
  // }

  FutureOr<void> deleteUserEvent(
      DeleteUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    try {
      // String? userId = u.FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(event.userId)
          .update({"isActive": false});

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      print(querySnapshot.docs);
      List<UserModel> userList = querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      emit(GetUserSuccessState(userList));
      // emit(GetUserSuccessState(userList));
    } catch (e) {
      print(e.toString());
      emit(UserErrorState(e.toString()));
    }
  }
}
