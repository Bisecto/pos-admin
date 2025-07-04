import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_admin/model/tenant_model.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/res/app_enums.dart';
import 'package:pos_admin/res/app_images.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/utills/app_validator.dart';
import 'package:pos_admin/view/widgets/app_custom_text.dart';
import 'package:pos_admin/view/widgets/form_button.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../model/address_model.dart';
import '../../../../model/business_hours_model.dart';
import '../../../../model/log_model.dart';
import '../../../../repository/log_actions.dart';
import '../../../../res/app_colors.dart';
import 'date_time_selector.dart';

class TenantProfilePage extends StatefulWidget {
  final TenantModel tenantModel; // Pass in the tenant profile to the page
  final UserModel userModel;

  TenantProfilePage({required this.tenantModel, required this.userModel});

  @override
  _TenantProfilePageState createState() => _TenantProfilePageState();
}

class _TenantProfilePageState extends State<TenantProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String logoUrl = '';
  late Map<String, BusinessHours> businessHours;
  TextEditingController businessName = TextEditingController();
  TextEditingController businessPhoneNumber = TextEditingController();
  TextEditingController businessType = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController vat = TextEditingController();
  TextEditingController date = TextEditingController();
  late Timestamp timestamp;
  TextEditingController country = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController street = TextEditingController();
  TextEditingController zipCode = TextEditingController();
  File? _imageFile;
  final picker = ImagePicker();
  Future<void> downloadAndSaveImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      print(response.statusCode);
      print(response.statusCode);
      print(response.statusCode);
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Get app's directory
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/downloaded_image.jpg';

        // Save file
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        // Update your _imageFile variable
        setState(() {
          _imageFile = file;

        });

        print('Image saved to: $filePath');
      } else {
        setState(() {
          _imageFile = File(AppImages.posTerminal);

        });
        print('Failed to download image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    downloadAndSaveImage(widget.tenantModel.logoUrl);

    businessName.text = widget.tenantModel.businessName;
    businessPhoneNumber.text = widget.tenantModel.businessPhoneNumber;
    businessType.text = widget.tenantModel.businessType;
    email.text = widget.tenantModel.email;
    vat.text = widget.tenantModel.vat.toString();
    country.text = widget.tenantModel.address.country;
    state.text = widget.tenantModel.address.state;
    city.text = widget.tenantModel.address.city;
    street.text = widget.tenantModel.address.streetAddress;
    zipCode.text = widget.tenantModel.address.zipCode;
    logoUrl = widget.tenantModel.logoUrl;
    //address = widget.tenantModel.address;
    businessHours = widget.tenantModel.businessHours;
  }
  Future<String> uploadImageToStorage(File imageFile) async {
    final fileName = 'logos/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    final uploadTask = await ref.putFile(imageFile);
    final downloadUrl = await uploadTask.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> updateTenantProfile() async {
    print(logoUrl);
    if (_formKey.currentState!.validate()) {
      try {
        // Prepare the updated tenant data
        TenantModel updatedTenant = TenantModel(
          businessName: businessName.text,
          businessPhoneNumber: businessPhoneNumber.text,
          businessType: businessType.text,
          email: email.text,
          logoUrl: logoUrl,
          vat: double.parse(vat.text.toString()),
          // Keep the original VAT value
          createdAt: widget.tenantModel.createdAt,
          updatedAt: Timestamp.now(),
          // Update timestamp
          address: Address(
              country: country.text,
              city: city.text,
              state: state.text,
              streetAddress: street.text,
              zipCode: zipCode.text),
          businessHours: businessHours,
          subscriptionPlan: widget.tenantModel.subscriptionPlan,
          subscriptionStart: widget.tenantModel.subscriptionStart,
          subscriptionEnd: widget.tenantModel.subscriptionEnd,
          isSubscriptionActive: widget.tenantModel
              .isSubscriptionActive, // Assuming businessHours is updated through UI
        );

        // Update tenant data in Firestore
        await FirebaseFirestore.instance
            .collection('Enrolled Entities')
            .doc(widget.userModel.tenantId)
            .update(updatedTenant.toFirestore());
        LogActivity logActivity = LogActivity();
        LogModel logModel = LogModel(
            actionType: LogActionType.businessProfileUpdate.toString(),
            actionDescription:
                "${widget.userModel.fullname}  updated Business profile from ${widget.tenantModel} to ${updatedTenant}  ",
            performedBy: widget.userModel.fullname,
            userId: widget.userModel.userId);
        logActivity.logAction(widget.userModel.tenantId.trim(), logModel);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        // setState(() {
        //   businessName.text = widget.tenantModel.businessName;
        //   businessPhoneNumber.text = widget.tenantModel.businessPhoneNumber;
        //   businessType.text = widget.tenantModel.businessType;
        //   email.text = widget.tenantModel.email;
        //   country.text = widget.tenantModel.address.country;
        //   state.text = widget.tenantModel.address.state;
        //   city.text = widget.tenantModel.address.city;
        //   street.text = widget.tenantModel.address.streetAddress;
        //   zipCode.text = widget.tenantModel.address.zipCode;
        //   logoUrl = widget.tenantModel.logoUrl;
        //   //address = widget.tenantModel.address;
        //   businessHours = widget.tenantModel.businessHours;
        // });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      // appBar: AppBar(
      //   title: TextStyles.textHeadings(
      //     textValue: 'Tenant Profile',
      //     textColor: AppColors.white,
      //   ),
      //   backgroundColor: Colors.transparent,
      // ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Business Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkYellow,
                  ),
                ),
                const SizedBox(height: 20),

                // Business Information Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.canvasColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextFormField(
                            width: 250,
                            controller: businessName,
                            hint: '',
                            label: 'Business Name',
                            validator: AppValidator.validateTextfield,
                          ),
                          CustomTextFormField(
                            width: 250,
                            controller: businessPhoneNumber,
                            hint: '',
                            label: 'Phone Number',
                            validator: AppValidator.validateTextfield,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_imageFile != null)
                            Image.file(_imageFile!, height: 150, width: 150, fit: BoxFit.contain)
                          else
                            const SizedBox(
                              height: 150,
                              width: 150,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              await _pickImage();

                              if (_imageFile != null) {
                                final uploadedUrl = await uploadImageToStorage(_imageFile!);
                                setState(() {
                                  logoUrl = uploadedUrl;
                                });
                              }
                            },
                            child: const Text('Select Image'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextFormField(
                            width: 250,
                            controller: businessType,
                            hint: '',
                            label: 'Business Type',
                            validator: AppValidator.validateTextfield,
                          ),
                          CustomTextFormField(
                            width: 250,
                            controller: email,
                            hint: '',
                            label: 'Business Email',
                            validator: AppValidator.validateTextfield,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (widget.userModel.fullname
                              .toLowerCase()
                              .contains('humble'))
                            SizedBox(
                                width: 250,
                                child: DatePickerWidget(
                                    tenantId:
                                        widget.userModel.tenantId.trim())),
                          SizedBox(
                            // Ensures CustomTextFormField has a fixed width
                            width: 250,
                            child: CustomTextFormField(
                              controller: vat,
                              hint: '',
                              label: 'Business VAT(%)',
                              textInputType: TextInputType.number,
                              validator: AppValidator.validateTextfield,
                              width: 250,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Address Section
                const Text(
                  'Address',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkYellow,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.canvasColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextFormField(
                            width: 250,
                            controller: country,
                            hint: '',
                            label: 'Country',
                            validator: AppValidator.validateTextfield,
                          ),
                          CustomTextFormField(
                            width: 250,
                            controller: state,
                            hint: '',
                            label: 'State',
                            validator: AppValidator.validateTextfield,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextFormField(
                            width: 250,
                            controller: city,
                            hint: '',
                            label: 'City',
                            validator: AppValidator.validateTextfield,
                          ),
                          CustomTextFormField(
                            width: 250,
                            controller: street,
                            hint: '',
                            label: 'Street Address',
                            validator: AppValidator.validateTextfield,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CustomTextFormField(
                            width: 250,
                            controller: zipCode,
                            hint: '',
                            label: 'Zip Code',
                            validator: AppValidator.validateTextfield,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (widget.userModel.role.toLowerCase() == 'admin')
                  Center(
                    child: FormButton(
                      onPressed: updateTenantProfile,
                      text: "Update Profile",
                      width: 300,
                      borderRadius: 20,
                      bgColor: AppColors.darkYellow,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
