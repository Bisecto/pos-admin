import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_admin/model/tenant_model.dart';
import '../../../../model/address_model.dart';
import '../../../../model/business_hours_model.dart';
import 'tenant_profile.dart'; // Import your models here

class TenantProfilePage extends StatefulWidget {
  final TenantModel tenantModel; // Pass in the tenant profile to the page

  TenantProfilePage({required this.tenantModel});

  @override
  _TenantProfilePageState createState() => _TenantProfilePageState();
}

class _TenantProfilePageState extends State<TenantProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late String businessName;
  late String businessPhoneNumber;
  late String businessType;
  late String email;
  late String logoUrl;
  late Address address;
  late Map<String, BusinessHours> businessHours;

  @override
  void initState() {
    super.initState();
    businessName = widget.tenantModel.businessName;
    businessPhoneNumber = widget.tenantModel.businessPhoneNumber;
    businessType = widget.tenantModel.businessType;
    email = widget.tenantModel.email;
    logoUrl = widget.tenantModel.logoUrl;
    address = widget.tenantModel.address;
    businessHours = widget.tenantModel.businessHours;
  }

  // Time selection helper
  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    return picked;
  }

  Widget _buildBusinessHoursFields(String day) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: TextStyle(color: Colors.white)),
        IconButton(
          icon: Icon(Icons.access_time, color: Colors.white),
          onPressed: () async {
            TimeOfDay? openingTime = await _selectTime(context);
            if (openingTime != null) {
              setState(() {
                businessHours[day]!.opening = Timestamp.fromDate(
                  DateTime(0, 0, 0, openingTime.hour, openingTime.minute),
                );
              });
            }
          },
        ),
        Text(
          businessHours[day]!.opening == null
              ? "Opening"
              : "${businessHours[day]!.opening!.toDate().hour}:${businessHours[day]!.opening!.toDate().minute}",
          style: TextStyle(color: Colors.white),
        ),
        IconButton(
          icon: Icon(Icons.access_time, color: Colors.white),
          onPressed: () async {
            TimeOfDay? closingTime = await _selectTime(context);
            if (closingTime != null) {
              setState(() {
                businessHours[day]!.closing = Timestamp.fromDate(
                  DateTime(0, 0, 0, closingTime.hour, closingTime.minute),
                );
              });
            }
          },
        ),
        Text(
          businessHours[day]!.closing == null
              ? "Closing"
              : "${businessHours[day]!.closing!.toDate().hour}:${businessHours[day]!.closing!.toDate().minute}",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Tenant Profile'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Business Name
              TextFormField(
                initialValue: businessName,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Business Name',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                onChanged: (value) {
                  setState(() {
                    businessName = value;
                  });
                },
              ),
              SizedBox(height: 10),
              // Business Phone Number
              TextFormField(
                initialValue: businessPhoneNumber,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Business Phone Number',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                onChanged: (value) {
                  setState(() {
                    businessPhoneNumber = value;
                  });
                },
              ),
              SizedBox(height: 10),
              // Business Type
              TextFormField(
                initialValue: businessType,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Business Type',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                onChanged: (value) {
                  setState(() {
                    businessType = value;
                  });
                },
              ),
              SizedBox(height: 10),
              // Email
              TextFormField(
                initialValue: email,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              SizedBox(height: 10),
              // Address Fields
              TextFormField(
                initialValue: address.country,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Country',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                onChanged: (value) {
                  setState(() {
                    address.country = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: address.state,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'State',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                onChanged: (value) {
                  setState(() {
                    address.state = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: address.city,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'City',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                onChanged: (value) {
                  setState(() {
                    address.city = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: address.streetAddress,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Street Address',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                onChanged: (value) {
                  setState(() {
                    address.streetAddress = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                initialValue: address.zipCode,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Zip Code',
                  labelStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                onChanged: (value) {
                  setState(() {
                    address.zipCode = value;
                  });
                },
              ),
              SizedBox(height: 10),
              // Business Hours Fields
              ...businessHours.keys.map((day) => _buildBusinessHoursFields(day)),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save data to Firestore or perform other actions
                  }
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
