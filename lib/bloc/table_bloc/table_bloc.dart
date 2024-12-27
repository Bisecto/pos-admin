import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:pos_admin/model/activity_model.dart';
import 'package:pos_admin/model/table_model.dart';

import '../../model/log_model.dart';
import '../../model/user_model.dart';
import '../../repository/log_actions.dart';
import '../../res/app_enums.dart';
import '../../utills/app_utils.dart';

part 'table_event.dart';

part 'table_state.dart';

class TableBloc extends Bloc<TableEvent, TableState> {
  TableBloc() : super(TableInitial()) {
    on<GetTableEvent>(getTableEvent);
    on<AddTableEvent>(addTableEvent);
    on<DeleteTableEvent>(deleteTableEvent);
  }
}

FutureOr<void> getTableEvent(
    GetTableEvent event, Emitter<TableState> emit) async {
  emit(TableLoadingState());
  try {
    // List<Brand> BrandList = brandQuerySnapshot.docs
    //     .map((doc) => Brand.fromFirestore(doc))
    //     .toList();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(event.tenantId)
        .collection('Tables')
        .get();

    print(querySnapshot.docs);

// Convert the fetched documents to a list of `TableModel`
    List<TableModel> tableList =
    querySnapshot.docs.map((doc) => TableModel.fromFirestore(doc)).toList();

// Sort the list by the name property (or adjust based on your property name)
    tableList.sort((a, b) {
      final regExp = RegExp(r'(\d+)');
      final aMatch = regExp.firstMatch(a.tableName)?.group(0) ?? '0';
      final bMatch = regExp.firstMatch(b.tableName)?.group(0) ?? '0';

      // Convert matched numbers to integers and compare them
      return int.parse(aMatch).compareTo(int.parse(bMatch));
    });

    print(tableList); // The list should now be ordered like T1, T2, etc.
    emit(GetTableSuccessState(tableList));
  } catch (e) {
    print(e.toString());
    emit(TableErrorState(e.toString()));
  }
}

Future<void> addTableEvent(
    AddTableEvent event, Emitter<TableState> emit) async {
  emit(TableLoadingState());
  try {
    String? userId = FirebaseAuth.instance.currentUser!.uid;
    String generatedId =
        event.tableName + AppUtils().generateFirestoreUniqueId();
    var collection = FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(event.tenantId)
        .collection('Tables');
    TableModel tableModel = TableModel(
        activity:
            ActivityModel(attendantId: '', attendantName: '', isActive: false, currentOrderId: '', isMerged: false),
        tableId: generatedId,
        tableName: event.tableName,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now());

    await collection.doc(generatedId).set(tableModel.toFirestore());
    LogActivity logActivity = LogActivity();
    LogModel logModel = LogModel(
        actionType: LogActionType.tableAdd.toString(),
        actionDescription: "${event.userModel.fullname} added a new table with id $generatedId",
        performedBy: event.userModel.fullname,
        userId: event.userModel.userId);
    await logActivity.logAction(event.userModel.tenantId.trim(), logModel);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(event.tenantId)
        .collection('Tables')
        .get();

    print(querySnapshot.docs);

// Convert the fetched documents to a list of `TableModel`
    List<TableModel> tableList =
    querySnapshot.docs.map((doc) => TableModel.fromFirestore(doc)).toList();

// Sort the list by the name property (or adjust based on your property name)
    tableList.sort((a, b) {
      final regExp = RegExp(r'(\d+)');
      final aMatch = regExp.firstMatch(a.tableName)?.group(0) ?? '0';
      final bMatch = regExp.firstMatch(b.tableName)?.group(0) ?? '0';

      // Convert matched numbers to integers and compare them
      return int.parse(aMatch).compareTo(int.parse(bMatch));
    });

    emit(GetTableSuccessState(
      tableList,
    ));
    // emit(GetTableSuccessState(tableList));
  } catch (e) {
    print(e.toString());
    emit(TableErrorState(e.toString()));
  }
}

FutureOr<void> deleteTableEvent(
    DeleteTableEvent event, Emitter<TableState> emit) async {
  emit(TableLoadingState());
  try {
    String? userId = FirebaseAuth.instance.currentUser!.uid;

    var collection = FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(event.tenantId) // Replace with the tenant ID
        .collection('Tables')
        .doc(event.tableId);

    await collection.delete();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(event.tenantId)
        .collection('Tables')
        .get();
    print(querySnapshot.docs);
    List<TableModel> tableList =
        querySnapshot.docs.map((doc) => TableModel.fromFirestore(doc)).toList();
    emit(GetTableSuccessState(tableList));
    // emit(GetTableSuccessState(tableList));
  } catch (e) {
    print(e.toString());
    emit(TableErrorState(e.toString()));
  }
}
