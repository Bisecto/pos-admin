import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  final String tenantId;

  const DatePickerWidget({Key? key, required this.tenantId}) : super(key: key);

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  final TextEditingController _dateController = TextEditingController();
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _loadStartDate();
  }

  /// Fetch current start date from Firestore
  Future<void> _loadStartDate() async {
    var doc = await FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.tenantId)
        .get();

    if (doc.exists && doc.data()?['queryStartDate'] != null) {
      Timestamp timestamp = doc.data()?['queryStartDate'];
      DateTime savedDateTime = timestamp.toDate();

      setState(() {
        selectedDate = savedDateTime;
        selectedTime = TimeOfDay.fromDateTime(savedDateTime);
        _dateController.text = DateFormat.yMMMMd().add_jm().format(savedDateTime);
      });
    }
  }

  /// Show Date Picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });

      // After selecting date, open the time picker
      _selectTime(context);
    }
  }

  /// Show Time Picker
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? const TimeOfDay(hour: 10, minute: 0), // Default 10 AM
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });

      // Save to Firestore
      _updateFirestore();
    } else {
      // If user cancels, use 10 AM as default time
      selectedTime = const TimeOfDay(hour: 10, minute: 0);
      _updateFirestore();
    }
  }

  /// Save the selected date & time to Firestore
  Future<void> _updateFirestore() async {
    if (selectedDate == null) return;

    DateTime fullDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    setState(() {
      _dateController.text = DateFormat.yMMMMd().add_jm().format(fullDateTime);
    });

    await FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.tenantId)
        .update({'queryStartDate': Timestamp.fromDate(fullDateTime)});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // Set fixed width
      child: TextField(
        controller: _dateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Select Date & Time",
          hintText: "Choose a start date & time",
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }
}
