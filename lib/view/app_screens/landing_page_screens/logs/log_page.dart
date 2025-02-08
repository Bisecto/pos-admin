import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_admin/utills/app_utils.dart';
import '../../../../model/start_stop_model.dart';
import '../../../widgets/app_custom_text.dart';

class UserLogsUI extends StatefulWidget {
  final String tenantId;
  final DailyStartModel dailyStartModel; // Start date

  const UserLogsUI({Key? key, required this.tenantId, required this.dailyStartModel}) : super(key: key);

  @override
  _UserLogsUIState createState() => _UserLogsUIState();
}

class _UserLogsUIState extends State<UserLogsUI> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .where('tenantId', isEqualTo: widget.tenantId.trim())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: CustomText(text: "No users found.", color: Colors.grey),
            );
          }

          List<DocumentSnapshot> users = snapshot.data!.docs;

          return SizedBox(
            height: 120, // Ensures proper height for horizontal scrolling
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                String userName = user['fullname'] ?? 'Unknown User';
                String userRole = user['role'] ?? 'No Role';
                String userId = user.id;

                return GestureDetector(
                  onTap: () => _showUserLogs(userId, userName),
                  child: Card(
                    color: Colors.grey[900], // Dark background
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      width: 200, // Adjust card width as needed
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: userName,
                            weight: FontWeight.bold,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          CustomText(
                            text: "Role: $userRole",
                            size: 14,
                            color: Colors.grey[400]!,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showUserLogs(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: CustomText(
            text: "$userName's Logs",
            weight: FontWeight.bold,
            color: Colors.white,
          ),
          content: SizedBox(
            width:200, //AppUtils.deviceScreenSize(context).width/2,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Enrolled Entities').doc(widget.tenantId.trim())
                  .collection('Logs')
                  .where('userId', isEqualTo: userId) .where('timestamp',
                  isGreaterThanOrEqualTo:
                  widget.dailyStartModel.startTime ?? DateTime(2000))
                  .where('timestamp',
                  isLessThanOrEqualTo:  widget.dailyStartModel.endTime ?? DateTime.now())
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
               // print("Fetched ${snapshot.data!.docs.length} logs");

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                 // print(snapshot);
                  return const CustomText(
                    text: "No logs available.",
                    color: Colors.grey,
                  );
                }

                List<DocumentSnapshot> logs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    var log = logs[index];
                    String description = log['actionDescription'] ?? 'No Description';
                    Timestamp? timestamp = log['timestamp'];
                    String date = timestamp != null ? timestamp.toDate().toString() : 'Unknown';

                    return ListTile(
                      title: CustomText(
                        text: description,
                        color: Colors.white,
                      ),
                      subtitle: CustomText(
                        text: "Date: $date",
                        color: Colors.grey,
                        size: 12,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const CustomText(text: "Close", color: Colors.blue),
            ),
          ],
        );
      },
    );
  }
}
