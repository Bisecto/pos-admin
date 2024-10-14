import 'package:flutter/material.dart';
import 'package:pos_admin/model/tenant_model.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/utills/app_validator.dart';
import 'package:pos_admin/view/widgets/form_button.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../model/address_model.dart';
import '../../../../model/business_hours_model.dart';
import '../../../../res/app_colors.dart';

class TenantProfilePage extends StatefulWidget {
  final TenantModel tenantModel; // Pass in the tenant profile to the page
  final UserModel userModel;

  TenantProfilePage({required this.tenantModel,required this.userModel});

  @override
  _TenantProfilePageState createState() => _TenantProfilePageState();
}

class _TenantProfilePageState extends State<TenantProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late String logoUrl;
  late Address address;
  late Map<String, BusinessHours> businessHours;
  TextEditingController businessName = TextEditingController();
  TextEditingController businessPhoneNumber = TextEditingController();
  TextEditingController businessType = TextEditingController();
  TextEditingController email = TextEditingController();

  @override
  void initState() {
    super.initState();
    businessName.text = widget.tenantModel.businessName;
    businessPhoneNumber.text = widget.tenantModel.businessPhoneNumber;
    businessType.text = widget.tenantModel.businessType;
    email.text = widget.tenantModel.email;
    logoUrl = widget.tenantModel.logoUrl;
    address = widget.tenantModel.address;
    businessHours = widget.tenantModel.businessHours;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasColor,
      body: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Business Name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextFormField(
                    width: 250,
                    controller: businessName,
                    hint: '',
                    label: 'Business name',
                    validator: AppValidator.validateTextfield,
                  ),

                  // Business Phone Number
                  CustomTextFormField(
                    width: 250,
                    controller: businessPhoneNumber,
                    hint: '',
                    label: 'Business Phone Number',
                    validator: AppValidator.validateTextfield,
                  ),

                  // Business Type
                  CustomTextFormField(
                    width: 250,
                    controller: businessType,
                    hint: '',
                    label: 'Business Type',
                    validator: AppValidator.validateTextfield,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Business Email
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextFormField(
                    width: 250,
                    controller: email,
                    hint: '',
                    label: 'Business Email',
                    validator: AppValidator.validateTextfield,
                  ),

                  // Address Fields
                  CustomTextFormField(
                    width: 250,
                    controller: TextEditingController(text: address.country),
                    hint: '',
                    label: 'Country',
                    validator: AppValidator.validateTextfield,
                  ),

                  CustomTextFormField(
                    width: 250,
                    controller: TextEditingController(text: address.state),
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
                   controller: TextEditingController(text: address.city),
                   hint: '',
                   label: 'City',
                   validator: AppValidator.validateTextfield,
                 ),
                 const SizedBox(height: 10),

                 CustomTextFormField(
                   width: 250,
                   controller: TextEditingController(text: address.streetAddress),
                   hint: '',
                   label: 'Street Address',
                   validator: AppValidator.validateTextfield,
                 ),
                 const SizedBox(height: 10),

                 CustomTextFormField(
                   width: 250,
                   controller: TextEditingController(text: address.zipCode),
                   hint: '',
                   label: 'Zip Code',
                   validator: AppValidator.validateTextfield,
                 ),
               ],
             ),
              const SizedBox(height: 10),

              // Business Hours Widget
              // Container(height: 300,width: 300,
              //     child: BusinessHoursWidget(businessHours: businessHours)),


             Center(child: FormButton(onPressed: (){},text: "Update Profile",width: 300,borderRadius: 20,))
            ],
          ),
        ),
      ),
    );
  }
}
