import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_admin/model/start_stop_model.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/res/app_colors.dart';
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
  int selectedLimit = 3; // Default limit

  @override
  void initState() {
    super.initState();
    loadDayStartStop();
  }

  Future<void> loadDayStartStop() async {
    setState(() => isLoading = true);
    dailyStartModel = await fetchDayStartStop(widget.tenantId, selectedLimit);
    setState(() => isLoading = false);
  }

  Future<List<DailyStartModel>> fetchDayStartStop(String tenantId, int limit) async {
    try {
      final dailyStart = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId.trim())
          .collection('dailyStart');

      final querySnapshot = await dailyStart
          .orderBy('startTime', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => DailyStartModel.fromFirestore(doc.data(), doc.id)).toList();
    } catch (e) {
      print("Failed to fetch logs: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      color: AppColors.darkModeBackgroundContainerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            const Text(
              "Daily Start Logs",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.green),
            ),
            const SizedBox(height: 5),
            const Text(
              "View recent start-stop logs for better tracking.",
              style: TextStyle(fontSize: 14, color: AppColors.white),
            ),

            const SizedBox(height: 15),

            // Dropdown Selector
            Row(
              children: [
                const Text("Show Last:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: AppColors.white)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedLimit.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  dropdownColor: AppColors.white,
                  onChanged: (value) {
                    setState(() {
                      selectedLimit = int.parse(value!);
                      loadDayStartStop();
                    });
                  },
                  items: List.generate(
                    30,
                        (index) => DropdownMenuItem(
                      value: (index + 1).toString(),
                      child: Text("${index + 1} Entries", style: TextStyle(color: AppColors.white),),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Log Display Section
            SizedBox(
              height: 210,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : dailyStartModel.isEmpty
                  ? Center(
                child: Text(
                  "No logs available.",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              )
                  : DailyStartHorizontalList(
                dailyStartModel: dailyStartModel,
                userModel: widget.userModel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
