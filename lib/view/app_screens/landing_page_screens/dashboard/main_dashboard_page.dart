import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/res/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../../model/activity_model.dart';
import '../../../../model/table_model.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../widgets/app_custom_text.dart';
import '../../../widgets/form_button.dart';
import 'all_metrics.dart';
import 'dashboard_chart.dart';
import 'date_filter.dart';
import 'date_picker.dart';
import 'metrics_overview.dart';
import 'recent_orders.dart';

class Dashboard extends StatefulWidget {
  final String tenantId;
  final UserModel userModel;

  Dashboard({required this.tenantId, required this.userModel});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<void> startDay(BuildContext context, String tenantId, String userId,
      String userRole, Function toggleLoading) async {
    try {
      toggleLoading(true); // Show loading

      // Check if the day has already started or ended
      final isAlreadyStartedOrEnded =
          await isDayAlreadyStartedOrEnded(tenantId);
      if (isAlreadyStartedOrEnded) {
        MSG.warningSnackBar(context,
            "A day has already been started or ended for the current session.");

        toggleLoading(false); // Hide loading
        return;
      }

      final dailyStart = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId.trim())
          .collection('dailyStart');

      // Create a new session
      await dailyStart.add({
        'userId': userId,
        'userRole': userRole,
        'tenantId': tenantId,
        'startTime': FieldValue.serverTimestamp(),
        'status': 'active',
      });
      await checkDayStatus(widget.tenantId.trim());
      MSG.snackBar(context, "Day started successfully.");
    } catch (e) {
      await checkDayStatus(widget.tenantId.trim());
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

      // Find the active session
      final activeSession =
          await dailyStart.where('status', isEqualTo: 'active').get();

      if (activeSession.docs.isEmpty) {
        MSG.warningSnackBar(context, "No active day to end.");

        toggleLoading(false); // Hide loading
        return;
      }

      // Update the session
      final docRef = activeSession.docs.first.reference;
      await docRef.update({
        'endTime': FieldValue.serverTimestamp(),
        'status': 'ended',
        'endedBy': {'userId': userId, 'userRole': userRole},
      });

      // Reset tables after ending the day
      await resetAllTables(context, tenantId);
      await checkDayStatus(widget.tenantId.trim());
      MSG.warningSnackBar(context, "Day ended successfully.");
    } catch (e) {
      await checkDayStatus(widget.tenantId.trim());
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

  bool isLoading = false;

  // bool isDayActive = false;
  String dayStatus = "";

  Future<void> checkDayStatus(String tenantId) async {
    try {
      setState(() {
        isLoading = true;
      });

      final dailyStart = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId.trim())
          .collection('dailyStart');

      final now = DateTime.now();
      final todayStart =
          DateTime(now.year, now.month, now.day, 7); // Start day at 7 AM
      final tomorrowStart =
          DateTime(now.year, now.month, now.day + 1, 7); // Next day start

      // Query logs for the current "day"
      final querySnapshot = await dailyStart
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('startTime',
              isLessThanOrEqualTo: Timestamp.fromDate(tomorrowStart))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final session = querySnapshot.docs.first;
        final status = session['status'];

        setState(() {
          dayStatus = status; // Update day status: "active" or "ended"
        });
      } else {
        setState(() {
          dayStatus = ""; // No session found
        });
      }
    } catch (e) {
      print("Error checking day status: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkDayStatus(widget.tenantId.trim());
  }

  Future<bool> isDayAlreadyStartedOrEnded(String tenantId) async {
    final dailyStart = FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(tenantId.trim())
        .collection('dailyStart');

    final now = DateTime.now();
    final todayStart =
        DateTime(now.year, now.month, now.day, 7); // Start day at 7 AM
    final tomorrowStart =
        DateTime(now.year, now.month, now.day + 1, 7); // Start of next day

    // Query logs to see if there’s an active or ended session for the current "day"
    final querySnapshot = await dailyStart
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('startTime',
            isLessThanOrEqualTo: Timestamp.fromDate(tomorrowStart))
        .get();

    // Check if there's already an active session
    if (querySnapshot.docs.isNotEmpty) {
      final session = querySnapshot.docs.first;
      final status = session['status'];
      if (status == 'active' || status == 'ended') {
        return true; // Day already started or ended
      }
    }

    return false; // Day not started or ended
  }

  void toggleLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DateFilterProvider(),
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          title: const CustomText(
            text: 'Overall Analytics',
            color: AppColors.white,
            weight: FontWeight.bold,
            size: 22,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (widget.userModel.role.toLowerCase() == 'manager' &&
                        dayStatus.toLowerCase() != 'ended') ...[
                      const SizedBox(height: 20),
                      if (!isLoading)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (dayStatus.isEmpty) ...[
                                FormButton(
                                  onPressed: () {
                                    print(dayStatus);

                                    showConfirmationDialog(
                                      context,
                                      "Start Day",
                                      "Are you sure you want to start the day?",
                                      () => startDay(
                                          context,
                                          widget.tenantId.trim(),
                                          widget.userModel.userId.trim(),
                                          widget.userModel.role,
                                          toggleLoading),
                                    );
                                  },
                                  width: 130,
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
                                          widget.tenantId.trim(),
                                          widget.userModel.userId.trim(),
                                          widget.userModel.role.trim(),
                                          toggleLoading),
                                    );
                                  },
                                  width: 130,
                                  text: "End Day",
                                  bgColor: Colors.red,
                                ),
                              ] else if (dayStatus == "ended") ...[
                                const Text(
                                  "Day has already ended.",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      if (isLoading)
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                    ],
                    AllMetricsOverview(tenantId: widget.tenantId),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                            text: 'Daily Analytics',
                            color: AppColors.white,
                            weight: FontWeight.bold,
                            size: 18,
                          ),
                          DatePickerWidget(),
                        ],
                      ),
                    ),
                    MetricsOverview(tenantId: widget.tenantId),
                    OrdersByUsersPage(tenantId: widget.tenantId),
                    RecentOrders(
                      tenantId: widget.tenantId,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
