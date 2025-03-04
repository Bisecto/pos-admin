import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_admin/model/start_stop_model.dart';
import 'package:pos_admin/model/user_model.dart';

import '../../../../../model/log_model.dart';
import 'daily_start_grid.dart';

class DayStartStopPage extends StatefulWidget {
  final String tenantId;
  final UserModel userModel;

  const DayStartStopPage({Key? key, required this.tenantId, required this.userModel}) : super(key: key);

  @override
  _DayStartStopPageState createState() => _DayStartStopPageState();
}

class _DayStartStopPageState extends State<DayStartStopPage> {
  List<DailyStartModel> dailyStartModel = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadDayStartStop();
  }

  Future<void> loadDayStartStop() async {
    setState(() {
      isLoading = true;
    });

    dailyStartModel = await fetchDayStartStop(widget.tenantId);

    setState(() {
      isLoading = false;
    });
  }

  Future<List<DailyStartModel>> fetchDayStartStop(String tenantId) async {
    try {
      final dailyStart = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId.trim())
          .collection('dailyStart');

      // Fetch only the last 5 documents ordered by startTime in descending order
      final querySnapshot = await dailyStart
          .orderBy('startTime', descending: true)
          .limit(5) // Limit to last 5 documents
          .get();

      // Map the fetched documents to the DailyStartModel
      return querySnapshot.docs.map((doc) {
        return DailyStartModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print("Failed to fetch logs: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : dailyStartModel.isEmpty
              ? const Center(
                  child: Text(
                    "No logs available.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : DailyStartHorizontalList(
                  dailyStartModel: dailyStartModel,
        userModel:widget.userModel
                ),
    );
  }
}
