import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_admin/model/category_model.dart';
import 'package:pos_admin/model/tenant_model.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/tables_page_screen/list_table.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_button.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../model/activity_model.dart';
import '../../../../model/brand_model.dart';
import '../../../../model/log_model.dart';
import '../../../../model/user_model.dart';
import '../../../../repository/log_actions.dart';
import '../../../../res/app_colors.dart';
import '../../../../res/app_enums.dart';
import '../../../widgets/app_custom_text.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_admin/bloc/table_bloc/table_bloc.dart';
import 'package:pos_admin/model/table_model.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../important_pages/app_loading_page.dart';

class MainTableScreen extends StatefulWidget {
  UserModel userModel;
  final TenantModel tenantModel;

  MainTableScreen(
      {super.key, required this.userModel, required this.tenantModel});

  @override
  State<MainTableScreen> createState() => _MainTableScreenState();
}

class _MainTableScreenState extends State<MainTableScreen> {
  final searchController = TextEditingController();
  List<TableModel> allTables = [];
  List<TableModel> filteredTables = [];
  TableBloc tableBloc = TableBloc();

  Future<void> startDay(BuildContext context, String tenantId, String userId,
      String userRole, Function toggleLoading) async {
    try {
      toggleLoading(true); // Show loading

      final dailyStart = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId.trim())
          .collection('dailyStart');

      // Check if there is any unresolved session
      final unresolvedSession =
          await dailyStart.where('status', isEqualTo: 'active').get();

      if (unresolvedSession.docs.isNotEmpty) {
        MSG.warningSnackBar(
          context,
          "A day is already active and must be ended before starting a new one.",
        );
        toggleLoading(false); // Hide loading
        return;
      }

      // Create a new session
      await dailyStart.add({
        'userId': userId,
        'userRole': userRole,
        'tenantId': tenantId,
        'startTime': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      await checkDayStatus(tenantId); // Update day status
      LogActivity logActivity = LogActivity();
      LogModel logModel = LogModel(
          actionType: LogActionType.systemStartStopDay.toString(),
          actionDescription: "${widget.userModel.fullname} started the day",
          performedBy: widget.userModel.fullname,
          userId: userId);
      logActivity.logAction(tenantId.trim(), logModel);

      MSG.snackBar(context, "Day started successfully.");
    } catch (e) {
      await checkDayStatus(tenantId);
      MSG.warningSnackBar(context, "Failed to start the day: $e");
    } finally {
      toggleLoading(false); // Hide loading
    }
  }

  Future<void> endDay(BuildContext context, String tenantId, String userId,
      String userRole, Function toggleLoading) async {
    try {
      toggleLoading(true); // Show loading

      final dailyStart = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId.trim())
          .collection('dailyStart');

      // Find the active or unresolved session
      final unresolvedSession =
          await dailyStart.where('status', isEqualTo: 'active').get();

      if (unresolvedSession.docs.isEmpty) {
        MSG.warningSnackBar(context, "No active day to end.");
        toggleLoading(false); // Hide loading
        return;
      }

      // Update the session
      final docRef = unresolvedSession.docs.first.reference;
      await docRef.update({
        'endTime': FieldValue.serverTimestamp(),
        'status': 'ended',
        'endedBy': {'userId': userId, 'userRole': userRole},
      });

      // Perform necessary resets
      await resetAllTables(context, tenantId);
      await resetAllOrdersTableNo(context, tenantId);

      await checkDayStatus(tenantId); // Update day status
      LogActivity logActivity = LogActivity();
      LogModel logModel = LogModel(
          actionType: LogActionType.systemStartStopDay.toString(),
          actionDescription: "${widget.userModel.fullname} ended the day",
          performedBy: widget.userModel.fullname,
          userId: userId);
      logActivity.logAction(tenantId.trim(), logModel);

      MSG.snackBar(context, "Day ended successfully.");
    } catch (e) {
      await checkDayStatus(tenantId);
      MSG.warningSnackBar(context, "Failed to end the day: $e");
    } finally {
      toggleLoading(false); // Hide loading
    }
  }

  Future<void> showConfirmationDialog(BuildContext context, String title,
      String message, Function onConfirm) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

// Method to reset all tables
  Future<void> resetAllTables(BuildContext context, String tenantId) async {
    try {
      final tablesCollection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId.trim())
          .collection('Tables');

      final querySnapshot = await tablesCollection.get();

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in querySnapshot.docs) {
        final tableId = doc['tableId'] as String;
        final tableName = doc['tableName'] as String;
        final createdAt = doc['createdAt'] as Timestamp;

        final defaultTableModel = TableModel(
          activity: ActivityModel(
            attendantId: '',
            attendantName: '',
            isActive: false,
            currentOrderId: '',
            isMerged: false,
          ),
          tableId: tableId,
          tableName: tableName,
          createdAt: createdAt,
          updatedAt: Timestamp.now(),
        );

        batch.set(doc.reference, defaultTableModel.toFirestore());
      }

      await batch.commit();
      print("All tables reset successfully.");
    } catch (e) {
      print("Failed to reset tables: $e");
    }
  }

  Future<void> resetAllOrdersTableNo(
      BuildContext context, String tenantId) async {
    try {
      final ordersCollection = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId.trim())
          .collection('Orders');

      final querySnapshot = await ordersCollection.get();

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in querySnapshot.docs) {
        final orderData = doc.data();

        // Change tableNo to a default value or empty
        final updatedOrderData = {
          ...orderData,
          'tableNo': '', // Set tableNo to an empty string or a default value
          'updatedAt': Timestamp.now(), // Optional: Add updated timestamp
        };

        batch.update(doc.reference, updatedOrderData);
      }

      await batch.commit();
      print("All orders' tableNo reset successfully.");
    } catch (e) {
      print("Failed to reset orders: $e");
    }
  }

  bool isLoading = false;

  // bool isDayActive = false;
  String dayStatus = "";

  Future<void> checkDayStatus(String tenantId) async {
    try {
      setState(() {
        isLoading = true; // Start loading
      });

      final dailyStart = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId.trim())
          .collection('dailyStart');

      final now = DateTime.now();

      // Define start and end of the current day based on a 7 AM start time
      final todayStart = DateTime(now.year, now.month, now.day, 7, 0, 0);
      final tomorrowStart = DateTime(now.year, now.month, now.day + 1, 7, 0, 0);

      // Check for sessions in the current day range or unresolved sessions
      final querySnapshot = await dailyStart
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('startTime', isLessThan: Timestamp.fromDate(tomorrowStart))
          .get();

      // Check for unresolved sessions (active status without endTime)
      final unresolvedSessions =
          await dailyStart.where('status', isEqualTo: 'active').get();

      if (unresolvedSessions.docs.isNotEmpty) {
        // If there are unresolved sessions, assume the day is still active
        setState(() {
          dayStatus = 'active';
        });
      } else if (querySnapshot.docs.isNotEmpty) {
        // If there are sessions for today but no active sessions, assume the day has ended
        setState(() {
          dayStatus = 'ended';
        });
      } else {
        // No sessions for today or unresolved sessions
        setState(() {
          dayStatus = ''; // No day started or ended
        });
      }
    } catch (e) {
      print("Error checking day status: $e");
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  void toggleLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  void initState() {
    tableBloc.add(GetTableEvent(widget.userModel.tenantId));
    checkDayStatus(widget.userModel.tenantId.trim());

    super.initState();
  }

  void _filterTables() {
    setState(() {
      filteredTables = allTables.where((table) {
        final searchQuery = searchController.text.toLowerCase();

        // Check if the search query matches the table name, brand name, or category name
        final matchesTableName =
            table.tableName.toLowerCase().contains(searchQuery) ?? false;

        // Return true if any of the conditions match
        return matchesTableName;
      }).toList();
    });
  }

  void _clearFilter() {
    setState(() {
      searchController.clear();
      print(1234567);
    });
    _filterTables();
  }

  void _addTable() {
    final TextEditingController nameController = TextEditingController();
    nameController.text = "T${allTables.length + 1}";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text(
                'Add New Table',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              backgroundColor: Colors.grey[900],
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: nameController,
                      label: 'Table Name*',
                      width: 250,
                      hint: 'Enter table name',
                      enabled: false,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FormButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          bgColor: AppColors.red,
                          textColor: AppColors.white,
                          width: 140,
                          text: "Discard",
                          iconWidget: Icons.clear,
                          borderRadius: 20,
                        ),
                        FormButton(
                          onPressed: () {
                            if (nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Table Name is required.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              setState(() {
                                // Add your table logic here.
                                tableBloc.add(AddTableEvent(
                                    nameController.text,
                                    widget.userModel.tenantId,
                                    widget.userModel));
                              });
                              Navigator.of(context).pop();
                            }
                          },
                          text: "Add",
                          iconWidget: Icons.add,
                          bgColor: AppColors.green,
                          textColor: AppColors.white,
                          width: 140,
                          borderRadius: 20,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: AppColors.darkModeBackgroundContainerColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (!isSmallScreen)
                        TextStyles.textHeadings(
                          textValue: "Tables",
                          textSize: 25,
                          textColor: AppColors.white,
                        ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomTextFormField(
                          controller: searchController,
                          hint: 'Search',
                          label: '',
                          onChanged: (val) {
                            _filterTables();
                          },
                          widget: IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: AppColors.white,
                            ),
                            onPressed: () {
                              // Trigger search logic
                              _filterTables();
                            },
                          ),
                          width: 250,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.userModel.role.toLowerCase() == 'manager'||widget.userModel.role.toLowerCase() == 'admin') ...[
                  //const SizedBox(height: 20),
                  if (!isLoading)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (dayStatus.isEmpty||dayStatus.toLowerCase() == 'ended') ...[
                              FormButton(
                                onPressed: () {
                                  print(dayStatus);

                                  showConfirmationDialog(
                                    context,
                                    "Start Day",
                                    "Are you sure you want to start the day?",
                                    () => startDay(
                                        context,
                                        widget.userModel.tenantId.trim(),
                                        widget.userModel.userId.trim(),
                                        widget.userModel.role,
                                        toggleLoading),
                                  );
                                },
                                width: 120,
                                text: "Start Day",
                                bgColor: Colors.green,
                              ),
                            ] else if (dayStatus == "active") ...[
                              FormButton(
                                onPressed: () {
                                  showConfirmationDialog(
                                    context,
                                    "End Day",
                                    "Are you sure you want to end the day? This will reset all tables.",
                                    () => endDay(
                                        context,
                                        widget.userModel.tenantId.trim(),
                                        widget.userModel.userId.trim(),
                                        widget.userModel.role.trim(),
                                        toggleLoading),
                                  );
                                },
                                width: 120,
                                text: "End Day",
                                bgColor: Colors.red,
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 10),
                  child: GestureDetector(
                    onTap: () {
                      tableBloc.add(GetTableEvent(widget.userModel.tenantId));
                    },
                    child: Container(
                      width: 100,
                      height: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.darkYellow),
                      child: const Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Center(
                          child: CustomText(
                            text: "Refresh",
                            size: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 10),
                  child: GestureDetector(
                    onTap: _addTable,
                    child: Container(
                      width: 100,
                      height: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.darkYellow),
                      child: const Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(
                              text: "Add Table",
                              size: 16,
                              color: AppColors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: BlocConsumer<TableBloc, TableState>(
                bloc: tableBloc,
                listener: (context, state) {
                  if (state is GetTableSuccessState) {
                    allTables = state.tableList;
                    filteredTables = List.from(allTables);
                  }
                },
                builder: (context, state) {
                  if (state is TableLoadingState) {
                    return const Center(child: AppLoadingPage(''));
                  }
                  if (state is GetTableSuccessState) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        if (filteredTables.isEmpty)
                          const Center(
                              child: CustomText(
                            text: 'No tables found.',
                            color: AppColors.white,
                          )),
                        if (filteredTables.isNotEmpty)
                          Expanded(
                              child: ListTable(
                            tableList: filteredTables,
                            userModel: widget.userModel,
                            tenantModel: widget.tenantModel,

                            //userModel: widget.userModel,
                          )),
                      ],
                    );
                  }
                  return const Center(
                      child: CustomText(text: 'No tables found.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
