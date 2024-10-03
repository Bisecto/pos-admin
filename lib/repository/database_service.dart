// import 'dart:async';
// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:Handypesin/utils/app_util.dart';
//
// import '../../controllers/edit_controller.dart';
// import '../../view/widget/dialog.dart';
// import '../view/important_pages/dialog_box.dart';
//
// class DatabaseService {
//   final String uid;
//
//   DatabaseService({required this.uid});
//
//   /// Collection refrence
//   final CollectionReference collectionReferenceUserInfo =
//   FirebaseFirestore.instance.collection("Users");
//   final CollectionReference collectionReferenceUserRequestedService =
//   FirebaseFirestore.instance.collection("Request_Service");
//   final CollectionReference collectionReferenceServiceProvidersInfo =
//   FirebaseFirestore.instance.collection("Service_Provider");
//   final CollectionReference collectionReferenceChatUsers =
//   FirebaseFirestore.instance.collection("Chat_Users");
//   final CollectionReference historyCollection =
//   FirebaseFirestore.instance.collection("History");
//   final CollectionReference categoryCollection =
//   FirebaseFirestore.instance.collection("App_Categories");
//   final CollectionReference requestServiceCollection =
//   FirebaseFirestore.instance.collection("Request_Service");
//   final CollectionReference errandServiceCollection =
//   FirebaseFirestore.instance.collection("Errand_Service");
//   final CollectionReference notificationCollection =
//   FirebaseFirestore.instance.collection("Notification");
//
//   Future updateUserServiceProviderList(
//       List myListOfRequestedServiceProviders) async {
//     return await collectionReferenceUserInfo.doc(uid).update({
//       'myListOfRequestedServiceProviders': myListOfRequestedServiceProviders
//     });
//   }
//
//   Future sendNotification(
//       String title, String body, String senderId, String receiverId) async {
//     String notificationId = AppUtils.generateRandomString(20);
//     return await notificationCollection.doc(notificationId).set({
//       'title': title,
//       'body': body,
//       'notificationId': notificationId,
//       'mergedId':[senderId,receiverId],
//       'senderId': senderId,
//       'receiverId': receiverId,
//       'createdAt': DateTime.now(),
//       'updatedAt': DateTime.now(),
//     });
//   }
//
//   Future addUserData(
//       String email,
//       String firstname,
//       String lastname,
//       String photoUrl,
//       String phoneNumber,
//       bool isNormalUser,
//       double totalBalance,
//       double totalAmountSent,
//       double totalAmountDeposited,
//       String refID,
//       bool isUserBlocked,
//       String city,
//       String state,
//       String country,
//       String address,
//       bool isUserVerified,
//       bool isRegistrationComplete,
//       ) async {
//     return await collectionReferenceUserInfo.doc(uid).set({
//       'email': email,
//       'firstname': firstname,
//       'lastname': lastname,
//       'id': uid,
//       'myListOfRequestedServiceProviders': [],
//       'isFirstErrand': false,
//       'photoUrl': photoUrl,
//       'phoneNumber': phoneNumber,
//       'isNormalUser': true,
//       'totalBalance': totalBalance,
//       'totalAmountSent': totalAmountSent,
//       'totalAmountDeposited': totalAmountDeposited,
//       'isFirstErrand':false,
//       'refID': refID,
//       'isUserBlocked': isUserBlocked,
//       'city': city,
//       'state': state,
//       'country': country,
//       'address': address,
//       'isUserVerified': isUserVerified,
//       'isHandypesin':false,
//       'isRegistrationComplete': isRegistrationComplete,
//       'createdAt': DateTime.now(),
//       'updatedAt': DateTime.now(),
//     });
//   }
//
//   // Future updateRequestService(
//   //   String status,
//   //   String docId,
//   //   BuildContext context,
//   // ) async {
//   //   return await requestServiceCollection.doc(docId).update(
//   //       {'status': status, 'updatedAt': DateTime.now()}).whenComplete(() {
//   //     ScaffoldMessenger.of(context).showSnackBar(MSG().snackBar(
//   //       'Status updated Successfully',
//   //     ));
//   //   });
//   // }
//   Future ErrandService(
//       String service,
//       String userId,
//       String status,
//       String comment,
//       double totalPrice,
//       String errandServiceId,
//       File imageFile,
//       ) async {
//     String descritionImageUrl='';
//     if(imageFile.path!='path'){
//       descritionImageUrl =await uploadUserImage(imageFile, 'Images/service_descriptive_images', UniqueKey().toString());}
//     await collectionReferenceUserInfo
//         .doc(userId)
//         .update({'isFirstErrand': true});
//     return await errandServiceCollection.doc(errandServiceId).set({
//       'descritionImageUrl':descritionImageUrl,
//       'errandServiceId': errandServiceId,
//       'service': service,
//       'userId': userId,
//       'status': status,
//       'price': totalPrice,
//       'comment': comment,
//       'createdAt': DateTime.now(),
//       'updatedAt': DateTime.now(),
//       'isAssigned': false,
//       'assignedErrandUserId': '',
//       'isRequested': true,
//       'isAccepted': false,
//       'isArrived': false,
//       'isOngoing': false,
//       'isDelivered': false,
//       'isDone': false,
//       'isPaymentDone': false,
//     });
//   }
//
//   Future RequestService(
//       String service,
//       String userId,
//       String serviceUserID,
//       String status,
//       String comment,
//       //double totalPrice,
//       // String dateNeeded,
//       // String timeNeeded,
//       String generatedId,
//       //List userItems,
//       List myListOfRequestedServiceProviders,
//       File imageFile,
//       ) async {
//     String descritionImageUrl='';
//     if(imageFile.path!='path'){
//       descritionImageUrl=await uploadUserImage(imageFile, 'Images/service_descriptive_images', UniqueKey().toString());}
//
//     myListOfRequestedServiceProviders.add(serviceUserID);
//     await updateUserServiceProviderList(myListOfRequestedServiceProviders);
//     return await requestServiceCollection.doc(generatedId).set({
//       'descritionImageUrl':descritionImageUrl,
//       'requestId': generatedId,
//       'service': service,
//       'userId': userId,
//       'serviceUserID': serviceUserID,
//       'status': status,
//       'price': 0.0,
//       // 'dateNeeded': dateNeeded,
//       // 'timeNeeded': timeNeeded,
//       // 'userItems': userItems,
//       'comment': comment,
//       'createdAt': DateTime.now(),
//       'updatedAt': DateTime.now(),
//       'isAssigned': true,
//       'assignedErrandUserId': '',
//       'isRequested': true,
//       'isArrived': false,
//       'isAccepted': false,
//       'isOngoing': false,
//       'isDelivered': false,
//       'isDone': false,
//       'isPaymentDone': false,
//     });
//   }
//
//   Future updateRequestServic(
//       String status,
//       String docId,
//       String field,
//       BuildContext context,
//       ) async {
//     return await requestServiceCollection
//         .doc(docId)
//         .update({field: true, 'status': status})
//         .whenComplete(() {})
//         .catchError((onError) {
//       print(onError);
//       ScaffoldMessenger.of(context).showSnackBar(MSG.errorSnackBar(
//           'Something went wrong please try again', context));
//     });
//   }
//
//   Future uploadUserImage(File imageFile, String path, String name) async {
//
//     String fileName = UniqueKey().toString();
//     final storageRef = FirebaseStorage.instance.ref();
//     Reference? imagesRef = storageRef.child(path);
//     final name = "$fileName $uid";
//     final imageRef = await imagesRef.child(name).putFile(imageFile);
//     var downloadUrl = await imageRef.ref.getDownloadURL();
//
//     return downloadUrl;
//   }
//
//   Future addChatUser(
//       String docId,
//       BuildContext context,
//       String chatId,
//       String userId,
//       String name,
//       String image,
//       String lastMessage,
//       //String lastMessageTime,
//       String sender,
//       bool seen,
//       bool delivered,
//       ) async {
//     return await collectionReferenceChatUsers.doc(docId).set({
//       'chatId': chatId,
//       'userId': userId,
//       'name': name,
//       'lastMessage': lastMessage,
//       'sender': sender,
//       'imageUrl': image,
//       'seen': seen,
//       'docId': docId,
//       'delivered': delivered,
//       'createdAt': DateTime.now(),
//       'updatedAt': DateTime.now(),
//     }).catchError((onError) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           MSG.errorSnackBar('Something went wrong please try again', context));
//     });
//   }
//
//   Future completeRegistrationServiceProvider(
//       BuildContext context,
//       File imageFile,
//       String brandName,
//       String about,
//       String phoneNumber,
//       // double totalBalance,
//       // double totalWithdrawal,
//       // double totalMoney,
//       String refID,
//       String longitude,
//       String latitude,
//       String city,
//       String state,
//       List serviceIds,
//       List serviceNames,
//       String country,
//       String address,
//       bool isServiceProviderVerified,
//       List<dynamic> priceList,
//       // String accountName,
//       // String accountNumber,
//       // String bankCode,
//       // String bankName,
//       File identityImageFile,
//       ) async {
//     String imageUrl='';
//     if(imageFile.path=='path'){
//       imageUrl ='';
//     }else{
//       imageUrl =
//       await uploadUserImage(imageFile, 'Images/users_images', brandName);
//     }
//     String photoIdUrl =
//     await uploadUserImage(identityImageFile, 'Images/id_images', brandName);
//     await collectionReferenceUserInfo.doc(uid).update({'isNormalUser':false});
//     return await collectionReferenceServiceProvidersInfo.doc(uid).set({
//       'identityType': EditCtrl.identityType.value.text,
//       // 'accountName': accountName,
//       // 'accountNumber': accountNumber,
//       // 'bankCode': bankCode,
//       // 'bankName': bankName,
//       'priceList': priceList,
//       'imageUrl': imageUrl,
//       'photoIdUrl': photoIdUrl,
//       'id': uid,
//       'rating': 5,
//       'noJobsCompleted': 0,
//       'noReviews': 0,
//       'brandName': brandName,
//       'phoneNumber': phoneNumber,
//       'refID': refID,
//       'about': about,
//       'serviceIds': serviceIds,
//       'serviceNames': serviceNames,
//       'longitude': longitude,
//       'latitude': latitude,
//       'city': city,
//       'state': state,
//       'country': country,
//       'address': address,
//       'isUserVerified': isServiceProviderVerified,
//       'createdAt': DateTime.now(),
//       'updatedAt': DateTime.now(),
//     }).whenComplete(() {
//       updateUserData(
//           context, phoneNumber, imageUrl, city, state, country, address,true);
//     }).catchError((onError) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           MSG.errorSnackBar('Something went wrong please try again', context));
//     });
//   }
//
//   Future updateUserData(
//       BuildContext context,
//       String phoneNumber,
//       String imageUrl,
//       String city,
//       String state,
//       String country,
//       String address,
//       bool isHandypesin
//       ) async {
//     return await collectionReferenceUserInfo.doc(uid).update({
//       'photoUrl': imageUrl,
//       'phoneNumber': phoneNumber,
//       'city': city,
//       'state': state,
//       'country': country,
//       'address': address,
//       'isRegistrationComplete': true,
//       'isHandypesin':isHandypesin,
//       'updatedAt': DateTime.now()
//     }).catchError((onError) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           MSG.errorSnackBar('Something went wrong please try again', context));
//     });
//   }
//
//   Future<DocumentSnapshot> getData(BuildContext context) async {
//     return collectionReferenceUserInfo.doc(uid).get().catchError((error) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(MSG.errorSnackBar('Something went wrong', context));
//     });
//   }
//
//   Future<DocumentSnapshot> getServiceProviderData(BuildContext context) async {
//     return collectionReferenceServiceProvidersInfo
//         .doc(uid)
//         .get()
//         .catchError((error) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(MSG.errorSnackBar(context,'Something went wrong',));
//     });
//   }
//
//   Future<QuerySnapshot<Object?>> getUserRequestedService(
//       BuildContext context) async {
//     return collectionReferenceUserRequestedService
//         .where('userId', isEqualTo: uid)
//         .get()
//         .catchError((error) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(MSG.errorSnackBar( context,'Something went wrong',));
//     });
//   }
// }