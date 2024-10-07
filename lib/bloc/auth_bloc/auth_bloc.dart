import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import 'package:http/http.dart' as http;

import '../../res/apis.dart';
import '../../utills/app_navigator.dart';
import '../../utills/app_utils.dart';
import '../../utills/shared_preferences.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SignInEventClick>(signInEventClick);
    on<SignUpEventClick>(signUpEventClick);
    // on<AuthEvent>((event, emit) {
    //   // TODO: implement event handler
    // });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FutureOr<void>> signInEventClick(
      SignInEventClick event, Emitter<AuthState> emit) async {
    emit(LoadingState());

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: event.userData, password: event.password);
      User? user = userCredential.user;
       FirebaseAuth.instance.tenantId='';
      // await user!.updateProfile(        'tenantId': newTenantId,
      // );
      print(user!.tenantId);
      print(user.uid);
      if (user.email!.isNotEmpty) {
        emit(SuccessState("Successfully Signed in"));
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

  FutureOr<void> signUpEventClick(SignUpEventClick event, Emitter<AuthState> emit)async {
    emit(LoadingState());

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: event.email, password: event.password);
      User? user = userCredential.user;
      //FirebaseAuth.instance.tenantId='';
      // await user!.updateProfile(        'tenantId': newTenantId,
      // );
      print(user!.tenantId);
      print(user.uid);
      if (user.email!.isNotEmpty) {
        emit(SuccessState("Successfully Signed in"));
      } else {
        emit(ErrorState(
            "There was a problem logging you in, please try again.")); // Emit error message
        emit(AuthInitial()); //
      }

    } on FirebaseAuthException catch (e) {
      // Handle different FirebaseAuth exceptions during sign-up
      print(e.toString());
      print(e.code.toString());

      String errorMessage = "There was a problem signing you up, please try again."; // Default message

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

      emit(ErrorState(errorMessage)); // Emit the error state with a custom message
      emit(AuthInitial()); // Reset the state after handling the error
    } catch (e) {
      emit(ErrorState("There was a problem logging you in, please try again."));
      emit(AuthInitial()); // Reset state
    }
  }
}
