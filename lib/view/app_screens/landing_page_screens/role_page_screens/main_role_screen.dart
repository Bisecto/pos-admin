import 'package:flutter/material.dart';
import 'package:pos_admin/model/category_model.dart';
import 'package:pos_admin/utills/app_navigator.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/utills/app_validator.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/role_page_screens/role_table.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_button.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../bloc/user_bloc/user_bloc.dart';
import '../../../../model/brand_model.dart';
import '../../../../model/tenant_model.dart';
import '../../../../model/user_model.dart';
import '../../../../res/app_colors.dart';
import '../../../important_pages/export_to_excel.dart';
import '../../../widgets/app_custom_text.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as modalSheet;

import 'package:flutter/material.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../res/app_colors.dart';
import '../../../widgets/app_custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_admin/view/widgets/form_input.dart';
import 'package:pos_admin/view/widgets/form_button.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../important_pages/app_loading_page.dart';
import '../../../../res/app_colors.dart';
import '../../auth/create_new_user.dart';

class MainUserScreen extends StatefulWidget {
  TenantModel tenantModel;
  UserModel userModel;

  MainUserScreen({super.key, required this.tenantModel,required this.userModel});

  @override
  State<MainUserScreen> createState() => _MainUserScreenState();
}

class _MainUserScreenState extends State<MainUserScreen> {
  final searchController = TextEditingController();
  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];
  UserBloc userBloc = UserBloc();

  @override
  void initState() {
    userBloc.add(GetUserEvent(widget.userModel.tenantId));
    super.initState();
  }

  void _filterUsers() {
    setState(() {
      filteredUsers = allUsers.where((user) {
        final searchQuery = searchController.text.toLowerCase();
        final matchesUserName =
            user.fullname.toLowerCase().contains(searchQuery);
        final matchesPhone = user.phone.toLowerCase().contains(searchQuery);
        final matchesRole = user.role.toLowerCase().contains(searchQuery);

        return matchesUserName || matchesPhone || matchesRole;
      }).toList();
    });
  }

  // void _addUser() {
  //   final TextEditingController emailController = TextEditingController();
  //   final TextEditingController fullNameController = TextEditingController();
  //   final TextEditingController phoneController = TextEditingController();
  //   final TextEditingController roleController = TextEditingController();
  //   final _formKey = GlobalKey<FormState>();
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: TextStyles.textHeadings(
  //           textValue: 'Add New User',
  //           textSize: 20,
  //           textColor: AppColors.white,
  //         ),
  //         backgroundColor: AppColors.darkModeBackgroundContainerColor,
  //         content: SingleChildScrollView(
  //           child: Form(
  //             key: _formKey,
  //             child: Column(
  //               children: [
  //                 CustomTextFormField(
  //                   controller: emailController,
  //                   label: 'Email Address',
  //                   width: 250,
  //                   hint: 'Enter email address',
  //                   validator: AppValidator.validateTextfield,
  //                 ),
  //                 SizedBox(height: 10),
  //                 CustomTextFormField(
  //                   controller: fullNameController,
  //                   label: 'Full name',
  //                   width: 250,
  //                   hint: 'Enter full name',
  //                   validator: AppValidator.validateTextfield,
  //                 ),
  //                 SizedBox(height: 10),
  //                 CustomTextFormField(
  //                   controller: phoneController,
  //                   label: 'Phone',
  //                   width: 250,
  //                   hint: 'Enter phone number of user',
  //                   textInputType: TextInputType.number,
  //                   validator: AppValidator.validateTextfield,
  //                 ),
  //                 SizedBox(height: 10),
  //                 DropDown(
  //                   width: 250,
  //                   borderColor: AppColors.white,
  //                   borderRadius: 10,
  //                   hint: "Select role of user",
  //                   selectedValue: roleController.text,
  //                   items: const ['Manager', "Admin", "Registerer"],
  //                   onChanged: (value) {
  //                     roleController.text = value;
  //                   },
  //                 ),
  //                 SizedBox(height: 10),
  //               ],
  //             ),
  //           ),
  //         ),
  //         actions: [
  //
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: AppColors.darkModeBackgroundContainerColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (!isSmallScreen)
                        TextStyles.textHeadings(
                          textValue: "Users",
                          textSize: 25,
                          textColor: AppColors.white,
                        ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomTextFormField(
                          controller: searchController,
                          hint: 'Search',
                          label: '',
                          onChanged: (val) {
                            _filterUsers();
                          },
                          widget: IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: AppColors.white,
                            ),
                            onPressed: () {
                              // Trigger search logic
                              _filterUsers();
                            },
                          ),
                          width: 250,
                        ),
                      ),
                    ],
                  ),
                ),


                if(widget.userModel.creatingEditingProfile)

                  Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      // AppNavigator.pushAndStackPage(context, page: CreateNewUser(tenantModel: widget.tenantModel,));
                      modalSheet.showMaterialModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.0),
                          ),
                        ),
                        context: context,
                        builder: (context) => Padding(
                          padding: const EdgeInsets.only(top: 100.0),
                          child: CreateNewUser(tenantModel: widget.tenantModel, userModel: widget.userModel,),
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      height: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.darkYellow),
                      child: const Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: AppColors.white,
                            ),
                            CustomText(
                              text: "  User",
                              size: 18,
                              color: AppColors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: BlocConsumer<UserBloc, UserState>(
                bloc: userBloc,
                listener: (context, state) {
                  if (state is GetUserSuccessState) {
                    allUsers = state.userList;

                    filteredUsers = List.from(allUsers);
                  }
                },
                builder: (context, state) {
                  if (state is UserLoadingState) {
                    return const Center(child: AppLoadingPage(''));
                  }
                  if (state is GetUserSuccessState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        if (filteredUsers.isEmpty)
                          const Center(
                              child: CustomText(
                            text: 'No users found.',
                            color: AppColors.white,
                          )),
                        if (filteredUsers.isNotEmpty)
                          Expanded(
                              child: UserTableScreen(
                            userList: filteredUsers, userModel: widget.userModel,
                          )),
                      ],
                    );
                  }
                  return const Center(
                      child: CustomText(text: 'No users found.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
