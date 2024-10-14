import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import 'package:http/http.dart' as http;

import '../../model/tenant_model.dart';
import '../../model/user_model.dart';
import '../../res/apis.dart';
import '../../utills/app_navigator.dart';
import '../../utills/app_utils.dart';
import '../../utills/shared_preferences.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignInEventClick>(signInEventClick);
    on<CreateUserRoleEventClick>(createUserRoleEventClick);
    on<SignUpEventClick>(signUpEventClick);
    on<ResetPasswordEvent>(resetPasswordEvent);
    // on<AuthEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  }

  //final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FutureOr<void>> signInEventClick(
      SignInEventClick event, Emitter<AuthState> emit) async {
    emit(LoadingState());

    try {
      print(1);
      AppUtils().logout();
      //await _auth.signOut();
      print(FirebaseAuth.instance.currentUser); // This should return null
      //await FirebaseAuth.instance.authStateChanges().firstWhere((user) => user == null);
      print(1);

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: event.userData, password: event.password);
      User? user = userCredential.user;
      print(1);

      //FirebaseAuth.instance.tenantId = '';
      // await user!.updateProfile(        'tenantId': newTenantId,
      // );
      print(user!.tenantId);
      print(user.uid);
      if (user.email!.isNotEmpty) {

        DocumentSnapshot userDocumentSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        UserModel userModel = UserModel.fromFirestore(userDocumentSnapshot);
        await SharedPref.putString('email', event.userData);
        await SharedPref.putString('password', event.password);
        if (userModel.accountStatus &&
            (userModel.role.toLowerCase() == 'admin' ||
                userModel.role.toLowerCase() == 'manager')) {
          DocumentSnapshot tenantDocumentSnapshot = await FirebaseFirestore
              .instance
              .collection('Enrolled Entities')
              .doc(userModel.tenantId)
              .get();
          TenantModel tenantModel =
          TenantModel.fromFirestore(tenantDocumentSnapshot);
          emit(SuccessState("Successfully Signed in", tenantModel, userModel));
        } else {
          emit(ErrorState(
              "You don\'t have access to this, Please contact your admin.")); // Emit error message
          emit(AuthInitial());
        }
      } else {
        emit(ErrorState(
            "There was a problem logging you in, please try again.")); // Emit error message
        emit(AuthInitial()); //
      }
      // var userDetails = await FirebaseFirestore.instance
      //     .collection('Admin_User')
      //     .doc(user!.uid)
      //     .get();
      // if (userDetails.exists) {
      //   emit(SuccessState("Successfully Signed in"));
      // } else {
      //   emit(ErrorState(
      //       "There was a problem logging you in, please try again.")); // Emit error message
      //   emit(AuthInitial()); //
      // }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      print(e.code.toString());
      String errorMessage =
          "There was a problem logging you in, please try again."; // Default message

      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        errorMessage = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        errorMessage = 'Wrong password provided.';
      } else if (e.code == 'invalid-credential') {
        print('Invalid Credential provided for that user.');
        errorMessage = 'Invalid Credential provided.';
      } else if (e.code == 'user-disabled') {
        print('Your account has been disabled');
        errorMessage = 'Your account has been disabled.';
      } else if (e.code == 'invalid-email') {
        print('Invalid email provided.');
        errorMessage = "There was a problem logging you in, please try again.";
      }

      emit(ErrorState(errorMessage)); // Emit error message
      emit(AuthInitial()); // Reset state after handling error
    } catch (e) {
      emit(ErrorState("There was a problem logging you in, please try again."));
      emit(AuthInitial()); // Reset state
    }
  }

  FutureOr<void> signUpEventClick(
      SignUpEventClick event, Emitter<AuthState> emit) async {
    emit(LoadingState());

    try {
      // User? adminUser = FirebaseAuth.instance.currentUser;

      // if (adminUser == null) {
      //   emit(ErrorState("Admin is not signed in"));
      //   return;
      // }

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: event.email, password: 'Qwerty123@');

      User? newUser = userCredential.user;

      var newUserCollection =
          FirebaseFirestore.instance.collection('Users').doc(newUser!.uid);

      UserModel userModel = UserModel(
          userId: newUser.uid,
          email: event.email,
          fullname: event.fullname,
          imageUrl: '',
          phone: event.phone,
          role: event.role,
          tenantId: event.tenantId,
          createdAt: Timestamp.fromDate(DateTime.now()),
          updatedAt: Timestamp.fromDate(DateTime.now()),
          accountStatus: false);

      await newUserCollection.set(userModel.toFirestore());

      emit(CreateUserSuccessState("Account created successfully"));
    } on FirebaseAuthException catch (e) {
      // Handle different FirebaseAuth exceptions during sign-up
      print(e.toString());
      print(e.code.toString());
      // await FirebaseAuth.instance.signInWithEmailAndPassword(
      //     email: await SharedPref.getString('email'),
      //     password: await SharedPref.getString('password'));

      String errorMessage =
          "There was a problem signing you up, please try again."; // Default message

      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        errorMessage = 'The account already exists for this email.';
      } else if (e.code == 'invalid-email') {
        print('Invalid email provided.');
        errorMessage = 'Invalid email provided.';
      } else if (e.code == 'operation-not-allowed') {
        print('Operation not allowed.');
        errorMessage = 'Operation not allowed, please contact support.';
      }

      emit(ErrorState(
          errorMessage)); // Emit the error state with a custom message
      emit(AuthInitial()); // Reset the state after handling the error
    } catch (e) {
      print(e.toString());
      emit(ErrorState("An unexpected error occurred, please try again."));
    } finally {
      // Optional cleanup or reset actions if needed
    }
  }

  // FutureOr<void> signUpEventClick(
  //     SignUpEventClick event, Emitter<AuthState> emit) async {
  //   emit(LoadingState());
  //
  //   try {
  //     await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  //
  //     print(1234);
  //     await FirebaseAuth.instance.signOut();
  //     print(345);
  //
  //     // FirebaseAuth.instance.;
  //     UserCredential userCredential =
  //         await _auth.createUserWithEmailAndPassword(
  //             email: event.email, password: 'Qwerty123@');
  //     print("fr4iueu");
  //
  //     User? user = userCredential.user;
  //     var userCollection =
  //         FirebaseFirestore.instance.collection('Users').doc(user!.uid);
  //     print("fr4iueu");
  //
  //     UserModel userModel = UserModel(
  //         userId: user.uid,
  //         email: event.email,
  //         fullname: event.fullname,
  //         imageUrl: '',
  //         phone: event.phone,
  //         role: event.role,
  //         tenantId: event.tenantId,
  //         createdAt: Timestamp.fromDate(DateTime.now()),
  //         updatedAt: Timestamp.fromDate(DateTime.now()),
  //         accountStatus: true);
  //
  //     await userCollection
  //         .set(userModel.toFirestore()); //FirebaseAuth.instance.tenantId='';
  //     // await user!.updateProfile(        'tenantId': newTenantId,
  //     // );
  //     print(user.tenantId);
  //     print(user.uid);
  //     await FirebaseAuth.instance.signOut();
  //
  //     // if (user.email!.isNotEmpty) {
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: await SharedPref.getString('email'),
  //         password: await SharedPref.getString('password'));
  //     emit(SuccessState("Successfully Signed in", event.tenantModel));
  //
  //     // } else {
  //     //   emit(ErrorState(
  //     //       "There was a problem logging you in, please try again.")); // Emit error message
  //     //   emit(AuthInitial()); //
  //     // }
  //   } on FirebaseAuthException catch (e) {
  //     // Handle different FirebaseAuth exceptions during sign-up
  //     print(e.toString());
  //     print(e.code.toString());
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: await SharedPref.getString('email'),
  //         password: await SharedPref.getString('password'));
  //
  //     String errorMessage =
  //         "There was a problem signing you up, please try again."; // Default message
  //
  //     if (e.code == 'weak-password') {
  //       print('The password provided is too weak.');
  //       errorMessage = 'The password provided is too weak.';
  //     } else if (e.code == 'email-already-in-use') {
  //       print('The account already exists for that email.');
  //       errorMessage = 'The account already exists for this email.';
  //     } else if (e.code == 'invalid-email') {
  //       print('Invalid email provided.');
  //       errorMessage = 'Invalid email provided.';
  //     } else if (e.code == 'operation-not-allowed') {
  //       print('Operation not allowed.');
  //       errorMessage = 'Operation not allowed, please contact support.';
  //     }
  //
  //     emit(ErrorState(
  //         errorMessage)); // Emit the error state with a custom message
  //     emit(AuthInitial()); // Reset the state after handling the error
  //   } catch (e) {
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: await SharedPref.getString('email'),
  //         password: await SharedPref.getString('password'));
  //
  //     emit(ErrorState("There was a problem logging you in, please try again."));
  //     emit(AuthInitial()); // Reset state
  //   }
  // }

  Future<void> resetPasswordEvent(
      ResetPasswordEvent event, Emitter<AuthState> emit) async {
    try {
      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: event.email);

      // No user credentials are returned from sendPasswordResetEmail
      // Emit a success message for password reset email

      emit(SuccessState(
          "Password reset email sent successfully to ${event.email}.",
          null,
          null));
    } on FirebaseAuthException catch (e) {
      // Handle different FirebaseAuth exceptions during password reset
      print("FirebaseAuthException: ${e.code} - ${e.message}");

      String errorMessage =
          "There was a problem sending the reset email, please try again."; // Default error message

      // Custom error messages for specific cases
      if (e.code == 'invalid-email') {
        print('Invalid email provided.');
        errorMessage = 'The email address is not valid.';
      } else if (e.code == 'user-not-found') {
        print('No user found for that email.');
        errorMessage = 'No account found with this email.';
      } else if (e.code == 'operation-not-allowed') {
        print('Operation not allowed.');
        errorMessage =
            'Password reset operation not allowed, please contact support.';
      }

      emit(ErrorState(
          errorMessage)); // Emit the error state with a specific message
      emit(AuthInitial()); // Reset the state after handling the error
    } catch (e) {
      // Catch any other exceptions
      print("Exception: ${e.toString()}");

      emit(ErrorState("An unexpected error occurred. Please try again later."));
      emit(AuthInitial()); // Reset the state
    }
  }

  FutureOr<void> createUserRoleEventClick(CreateUserRoleEventClick event, Emitter<AuthState> emit) async {
    emit(LoadingState());

    try {
      
      AppUtils().logout();

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: event.email, password: 'Qwerty123@');

      User? newUser = userCredential.user;

      var newUserCollection =
      FirebaseFirestore.instance.collection('Users').doc(newUser!.uid);

      UserModel userModel = UserModel(
          userId: newUser.uid,
          email: event.email,
          fullname: event.fullname,
          imageUrl: '',
          phone: event.phone,
          role: event.role,
          tenantId: event.tenantId,
          createdAt: Timestamp.fromDate(DateTime.now()),
          updatedAt: Timestamp.fromDate(DateTime.now()),
          accountStatus: true);
      await newUserCollection.set(userModel.toFirestore());
      AppUtils().logout();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: await SharedPref.getString('email'),
          password: await SharedPref.getString('password'));

      emit(CreateUserSuccessState("User created successfully"));
    } on FirebaseAuthException catch (e) {
      // Handle different FirebaseAuth exceptions during sign-up
      print(e.toString());
      print(e.code.toString());
     

      String errorMessage =
          "There was a problem signing you up, please try again."; // Default message

      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        errorMessage = 'The account already exists for this email.';
      } else if (e.code == 'invalid-email') {
        print('Invalid email provided.');
        errorMessage = 'Invalid email provided.';
      } else if (e.code == 'operation-not-allowed') {
        print('Operation not allowed.');
        errorMessage = 'Operation not allowed, please contact support.';
      }

      emit(ErrorState(
          errorMessage)); // Emit the error state with a custom message
      emit(AuthInitial()); // Reset the state after handling the error
    } catch (e) {
      print(e.toString());
      emit(ErrorState("An unexpected error occurred, please try again."));
    } finally {
      // Optional cleanup or reset actions if needed
    }
  }
}
