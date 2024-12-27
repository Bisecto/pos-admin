// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../../model/business_hours_model.dart';
//
// class BusinessHoursPage extends StatefulWidget {
//   @override
//   _BusinessHoursPageState createState() => _BusinessHoursPageState();
// }
//
// class _BusinessHoursPageState extends State<BusinessHoursPage> {
//   Map<String, BusinessHours> businessHours = {};
//
//   @override
//   void initState() {
//     super.initState();
//     fetchBusinessHours(); // Fetch the data when the widget is initialized
//   }
//
//   void fetchBusinessHours() async {
//     // Fetch data from Firestore and populate the businessHours map
//     final snapshot = await FirebaseFirestore.instance.collection('business_hours').get();
//
//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//       String day = data['day']; // Assuming you have a 'day' field
//       businessHours[day] = BusinessHours.fromFirestore(data);
//     }
//
//     setState(() {}); // Refresh the UI
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Business Hours')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded( // Make sure ListView is wrapped in Expanded
//               child: BusinessHoursWidget(businessHours: businessHours),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class BusinessHoursWidget extends StatelessWidget {
//   final Map<String, BusinessHours> businessHours;
//
//   BusinessHoursWidget({required this.businessHours});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: businessHours.length,
//       itemBuilder: (context, index) {
//         String day = businessHours.keys.elementAt(index);
//         final opening = businessHours[day]?.opening;
//         final closing = businessHours[day]?.closing;
//
//         final openingTime = opening != null ? TimeOfDay.fromDateTime(opening.toDate()) : null;
//         final closingTime = closing != null ? TimeOfDay.fromDateTime(closing.toDate()) : null;
//
//         return Card(
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           margin: EdgeInsets.only(bottom: 10),
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   day,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     _buildTimeSection(
//                       context,
//                       label: 'Open',
//                       time: openingTime,
//                       onTimeSelected: (newTime) {
//                         // Handle opening time selection
//                       },
//                     ),
//                     SizedBox(width: 15),
//                     _buildTimeSection(
//                       context,
//                       label: 'Close',
//                       time: closingTime,
//                       onTimeSelected: (newTime) {
//                         // Handle closing time selection
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildTimeSection(
//       BuildContext context, {
//         required String label,
//         required TimeOfDay? time,
//         required Function(TimeOfDay) onTimeSelected,
//       }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Text(label),
//         SizedBox(height: 4),
//         GestureDetector(
//           onTap: () async {
//             TimeOfDay? pickedTime = await showTimePicker(
//               context: context,
//               initialTime: time ?? TimeOfDay.now(),
//             );
//             if (pickedTime != null) {
//               onTimeSelected(pickedTime);
//             }
//           },
//           child: Container(
//             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.grey),
//             ),
//             child: Text(
//               time != null ? time.format(context) : 'Select',
//               style: TextStyle(
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
