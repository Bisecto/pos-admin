import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../model/log_model.dart';
import '../../../../res/app_enums.dart';
import '../../../widgets/app_custom_text.dart';

class LogUI extends StatefulWidget {
  final String tenantId;

  const LogUI({Key? key, required this.tenantId}) : super(key: key);

  @override
  _LogUIState createState() => _LogUIState();
}

class _LogUIState extends State<LogUI> {
  List<LogModel> logs = [];
  String? selectedUserId;
  LogActionType? selectedActionType;

  @override
  void initState() {
    super.initState();
    fetchLogs(widget.tenantId);
  }

  Future<void> fetchLogs(String tenantId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Enrolled Entities')
              .doc(tenantId)
              .collection('Logs')
              .orderBy('timestamp', descending: true)
              .get();

      List<LogModel> fetchedLogs =
          querySnapshot.docs.map((doc) => LogModel.fromFirestore(doc)).toList();

      // Update logs and rebuild the UI
      setState(() {
        logs = fetchedLogs;
      });
    } catch (e) {
      print('Error fetching logs: $e');
    }
  }

  List<LogModel> _applyFilters() {
    return logs.where((log) {
      bool matchesUser =
          selectedUserId == null || log.performedBy == selectedUserId;
      bool matchesAction =
          selectedActionType == null || log.actionType == selectedActionType;

      return matchesUser && matchesAction;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<LogModel> filteredLogs = _applyFilters();

    return Scaffold(
      appBar: AppBar(
        title: const CustomText(text: "Activity Logs"),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black, // Dark background color
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  text: "Filters",
                  //style: TextStyle(
                  weight: FontWeight.bold,
                  size: 16,
                  color: Colors.white, // Light text color
                  // ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Action Type Filter
                    Expanded(
                      child: DropdownButtonFormField<LogActionType>(
                        decoration: InputDecoration(
                          labelText: "Action Type",
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[800],
                          // Darker field background
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        dropdownColor: Colors.grey[900],
                        // Dropdown background
                        value: selectedActionType,
                        items: LogActionType.values.map((action) {
                          return DropdownMenuItem<LogActionType>(
                            value: action,
                            child: CustomText(
                              text: action.name
                                  .replaceAll('_', ' ')
                                  .toUpperCase(),
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedActionType = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // User Filter
                    Expanded(
                      child: FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('Users')
                            .where('tenantId',
                                isEqualTo: widget.tenantId.trim())
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          List<DropdownMenuItem<String>> userItems =
                              snapshot.data!.docs.map((doc) {
                            final userId = doc.id;
                            final userName = doc['fullname'];
                            return DropdownMenuItem<String>(
                              value: userId,
                              child: CustomText(
                                text: userName,
                                color: Colors.white,
                              ),
                            );
                          }).toList();

                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: "User",
                              labelStyle: const TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.grey[800],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            dropdownColor: Colors.grey[900],
                            value: selectedUserId,
                            items: userItems,
                            onChanged: (value) {
                              setState(() {
                                selectedUserId = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Logs List
          Expanded(
            child: filteredLogs.isEmpty
                ? const Center(
                    child: CustomText(
                      text: "No logs found.",
                      size: 16,
                      color: Colors.grey,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return Card(
                        color: Colors.grey[900],
                        // Card background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.event_note,
                              color: Colors.white,
                            ),
                          ),
                          title: CustomText(
                            text: log.actionDescription,
                            weight: FontWeight.bold,
                            color: Colors.white, // Light text
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              CustomText(
                                text: "Performed By: ${log.performedBy}",
                                color: Colors.white,
                              ),
                              CustomText(
                                text:
                                    "Date: ${log.timestamp?.toLocal().toString() ?? 'N/A'}",
                                size: 12,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Colors.grey[600],
                          ),
                          onTap: () {
                            // Show detailed log view or other actions
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
