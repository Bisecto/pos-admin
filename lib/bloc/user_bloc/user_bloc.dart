import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as u;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../model/user_model.dart';
import '../../utills/app_utils.dart';

part 'user_event.dart';

part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<GetUserEvent>(getUserEvent);
    on<AddUserEvent>(addUserEvent);
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

  Future<void> addUserEvent(AddUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());

    try {
      // Ensure event values are valid
      if (event.email.isEmpty || event.fullname.isEmpty || event.phone.isEmpty) {
        print("Email, fullname, or phone cannot be empty");
        emit(UserErrorState("Email, fullname, or phone cannot be empty"));
        return;
      }

      //u.User? adminUser = u.FirebaseAuth.instance.currentUser; // Store the current admin
      print("Creating user with email: ${event.email}");

      // Create the new user
      UserCredential userCredential = await u.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: event.email,
          password: "Qwerty123@"
      );

      User? user = userCredential.user;
      if (user == null) {
        throw Exception("User creation failed");
      }

      // Add the new user to Firestore
      var collection = FirebaseFirestore.instance.collection('Users').doc(user.uid);
      UserModel newUser = UserModel(
          userId: user.uid,
          email: event.email,
          fullname: event.fullname,
          imageUrl: 'imageUrl', // Placeholder
          phone: event.phone,
          role: event.role,
          tenantId: 'tenantId', // Placeholder, handle multi-tenancy if needed
          createdAt: Timestamp.fromDate(DateTime.now()),
          updatedAt: Timestamp.fromDate(DateTime.now()),
          accountStatus: true
      );
      await collection.set(newUser.toFirestore());

      // Fetch and display the updated user list
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Users').get();
      List<UserModel> userList = querySnapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

      // Log the admin back in after user creation
      // if (adminUser != null) {
      //   print("Re-authenticating admin user...");
      //   await u.FirebaseAuth.instance.signInWithEmailAndPassword(
      //     email: adminUser.email!, // Ensure admin email is not null
      //     password: "Qwerty123@",  // Admin's password
      //   );
      // }

      // Emit success with the user list
      emit(GetUserSuccessState(userList));
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      print("FirebaseAuthException: ${e.message}");
      emit(UserErrorState(e.message!));
    } catch (e) {
      // Catch any other errors
      print("Error: ${e.toString()}");
      emit(UserErrorState(e.toString()));
    }
  }


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
