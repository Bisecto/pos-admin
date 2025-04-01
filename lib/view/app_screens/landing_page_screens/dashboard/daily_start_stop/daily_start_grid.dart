import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_admin/res/app_colors.dart';

import '../../../../../model/start_stop_model.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../model/user_model.dart';
import '../../../../widgets/app_custom_text.dart';
import 'complete_analytics.dart';

class DailyStartHorizontalList extends StatelessWidget {
  final List<DailyStartModel> dailyStartModel;
  final UserModel userModel;

  const DailyStartHorizontalList({
    Key? key,
    required this.dailyStartModel,
    required this.userModel,
  }) : super(key: key);

  Future<Map<String, UserModel?>> fetchUserDetailsSeparately(
      DailyStartModel dailyStart) async {
    try {
      final startedByUserFuture = FirebaseFirestore.instance
          .collection('Users')
          .doc(dailyStart.userId) // Fetch startedByUser
          .get();

      // Only fetch endedByUser if the endTime is not null (i.e., day is ended)
      final endedByUserFuture = dailyStart.endTime != null
          ? FirebaseFirestore.instance
              .collection('Users')
              .doc(dailyStart.endedBy?['userId']) // Fetch endedByUser
              .get()
          : Future.value(null); // Return null if the day has not ended

      final results =
          await Future.wait([startedByUserFuture, endedByUserFuture]);

      final startedByUserDoc = results[0];
      final endedByUserDoc = results[1];

      UserModel startedByUser = UserModel.fromFirestore(startedByUserDoc!);
      UserModel? endedByUser; // Nullable UserModel
      if (endedByUserDoc != null) {
        endedByUser = UserModel.fromFirestore(endedByUserDoc);
      }

      return {
        'startedBy': startedByUser,
        'endedBy': endedByUser, // No force unwrapping
      };
    } catch (e) {
      print("Error fetching user details: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dailyStartModel.length,
        itemBuilder: (context, index) {
          final dailyStart = dailyStartModel[index];

          // Fetch the user details for "startedBy" and "endedBy" separately
          return FutureBuilder<Map<String, UserModel?>>(
            future: fetchUserDetailsSeparately(dailyStart),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: 250,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                print('Error fetching user details: ${snapshot.error}');
                return Container(
                  width: 250,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade800,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Failed to load user details.",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }

              final users = snapshot.data ?? {};
              final startedByUser = users['startedBy'];
              final endedByUser = users['endedBy'] ??
                  UserModel(
                      userId: '',
                      email: '',
                      fullname: '',
                      imageUrl: '',
                      phone: '',
                      role: '',
                      tenantId: '',
                      createdAt: Timestamp.now(),
                      updatedAt: Timestamp.now(),
                      accountStatus: false);

              Widget infoText(String label, String? value) {
                return CustomText(
                  text: "$label: ${value ?? 'N/A'}",
                  //style: const TextStyle(
                  color: Colors.white70,
                  size: 12,
                  //),
                );
              }

              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.darkModeBackgroundContainerColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: CompleteAnalytics(
                          startedUser: startedByUser!,
                          endeduser: endedByUser!,
                          dailyStartModel: dailyStart,
                          userModel: userModel,
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade800,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Started By: ${startedByUser?.fullname ?? 'N/A'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (dailyStart.startTime != null)
                        infoText(
                            "Start Time",
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(dailyStart.startTime!)),
                      const SizedBox(height: 8),
                      if (dailyStart.endTime != null)
                        infoText(
                            "End Time",
                            DateFormat('yyyy-MM-dd HH:mm')
                                .format(dailyStart.endTime!)),
                      const SizedBox(height: 8),
                      infoText("Ended By", endedByUser?.fullname),
                      const SizedBox(height: 8),
                      Text(
                        "Status: ${dailyStart.status.toUpperCase()}",
                        style: TextStyle(
                          color: dailyStart.status.toLowerCase() == 'active'
                              ? AppColors.green
                              : AppColors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
