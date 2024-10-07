// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:pos_admin/model/firebase_model.dart'as u;
//
// import 'package:pos_admin/view/app_screens/auth/sign_in_screen.dart';
// import 'package:pos_admin/view/app_screens/landing_page.dart';
//
// //import 'package:wwjs/view/widget/dialog.dart';
//
// import '../utills/app_navigator.dart';
// import '../view/important_pages/dialog_box.dart';
// import 'database_service.dart';
//
// //import 'database.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   u.User? _userFromFirebase(User user) {
//     return user != null ? u.User(user.uid) : null;
//   }
//   /// create user object based on firebase User
//
//   Future<bool> ForgotPassword(email, context) async {
//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//       ScaffoldMessenger.of(context).showSnackBar(MSG.snackBar(context,
//         'A password reset link has been sent to $email'
//       ));
//       return true;
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(context).showSnackBar(
//           MSG.errorSnackBar(e.toString().split(']')[1], context));
//       return false;
//     }
//   }
//
//   Future<bool> ChangePassword(newPassword, context) async {
//     try {
//       await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
//       return true;
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(context).showSnackBar(
//           MSG.errorSnackBar(e.toString().split(']')[1], context));
//       return false;
//     }
//   }
//
//   /// sign in with email and pasword
//   Future SignInWithEmailAndPassword(
//       String email, String password, BuildContext context) async {
//     try {
//       UserCredential result = await _auth.signInWithEmailAndPassword(
//           email: email, password: password);
//       User? user = result.user;
//
//       await FirebaseFirestore.instance
//           .collection('Admin_User')
//           .doc(user!.uid)
//           .get()
//           .then((DocumentSnapshot documentSnapshot) async {
//         if (documentSnapshot.exists) {
//           ScaffoldMessenger
//               .of(context)
//               .showSnackBar(
//               MSG.errorSnackBar('No registered User for this account', context));
//           await signOut(context, user.uid);
//           return null;
//         }else{
//           //FirebaseMessaging.instance.subscribeToTopic(user.uid);
//           AppNavigator.pushAndReplacePage(context,
//               page:  const LandingPage());
//           return user;
//         }
//
//       });
//
//     } on FirebaseAuthException catch (e) {
//       print(e.toString());
//       if (e.code == 'user-not-found') {
//         print('No user found for that email.');
//         ScaffoldMessenger.of(context).showSnackBar(
//             MSG.errorSnackBar('No user found for this email.', context));
//       } else if (e.code == 'wrong-password') {
//         print('Wrong password provided for that user.');
//         ScaffoldMessenger.of(context).showSnackBar(
//             MSG.errorSnackBar('Wrong password provided.', context));
//       } else if (e.code == 'user-disabled') {
//         print('Your account has been disabled');
//         ScaffoldMessenger.of(context).showSnackBar(
//             MSG.errorSnackBar('Your account has been disabled', context));
//       } else if (e.code == 'invalid-email') {
//         print('You inserted an invalid email');
//         ScaffoldMessenger.of(context).showSnackBar(
//             MSG.errorSnackBar('You inserted an invalid email.', context));
//       }
//       return null;
//     }
//   }
//
//
//   late String uid;
//
//
//
//   // final CollectionReference collectionReferenceUserInfo =
//   // FirebaseFirestore.instance.collection("Users");
//
//
//   Future registerWithEmailAndPassword(
//       String password,
//       BuildContext context,
//       String email,
//
//       ) async {
//     try {
//       UserCredential result = await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       User? user = result.user;
//
//       /// create a new document for the user with the uid
//       // await DatabaseService(uid: user.uid).addUserData(
//       //     email,
//       //     firstname,
//       //     lastname,
//       //     photoUrl,
//       //     phoneNumber,
//       //     isNormalUser,
//       //     totalBalance,
//       //     totalAmountSent,
//       //     totalAmountDeposited,
//       //     refID,
//       //     isUserBlocked,
//       //     city,
//       //     state,
//       //     country,
//       //     address,
//       //     isUserVerified,
//       //     isRegistrationComplete);
//
//       print(_userFromFirebase);
//       return _userFromFirebase(user!);
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         ScaffoldMessenger.of(context).showSnackBar(
//             MSG.errorSnackBar('The password provided is too weak.', context));
//         print('The password provided is too weak.');
//       } else if (e.code == 'email-already-in-use') {
//         ScaffoldMessenger.of(context).showSnackBar(MSG.errorSnackBar(
//             'The account already exists for that email', context));
//         print('The account already exists for that email.');
//       } else if (e.code == 'invalid-email') {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(MSG.errorSnackBar('Invalid email Provided', context));
//         print('invalid email');
//       }
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }
//
//
//
//
//   /// Sign out
//   Future signOut(BuildContext context, String uid) async {
//     try {
//       //FirebaseMessaging.instance.unsubscribeFromTopic(uid);
//       return await _auth.signOut().whenComplete(() {
//         AppNavigator.pushAndReplacePage(context, page:  const SignInScreen());
//       });
//     } catch (e) {
//       print(e.toString());
//       return null;
//     }
//   }
// }