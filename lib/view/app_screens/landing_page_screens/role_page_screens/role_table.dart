import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as u;
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/utills/app_utils.dart';
import '../../../../model/brand_model.dart';
import '../../../../model/category_model.dart';
import '../../../../utills/app_validator.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../widgets/app_custom_text.dart';
import '../../../widgets/drop_down.dart';
import '../../../widgets/form_button.dart';
import '../../../widgets/form_input.dart';
import '../../../../res/app_colors.dart';

class UserTableScreen extends StatefulWidget {
  final List<UserModel> userList;
  final UserModel userModel;

  UserTableScreen({required this.userList, required this.userModel});

  @override
  _UserTableScreenState createState() => _UserTableScreenState();
}

class _UserTableScreenState extends State<UserTableScreen> {
  int rowsPerPage = 100;
  int currentPage = 1;

  List<UserModel> get paginatedUsers {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return widget.userList.sublist(
        start, end > widget.userList.length ? widget.userList.length : end);
  }

  void _editUser(int index) {
    //final TextEditingController emailController = TextEditingController();
    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController roleController = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    fullNameController.text = widget.userList[index].fullname;
    phoneController.text = widget.userList[index].phone;
    roleController.text = widget.userList[index].role.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextStyles.textHeadings(
              textValue: 'Edit User', textSize: 22, textColor: AppColors.white),
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // String userImageUrl;

                  CustomTextFormField(
                    controller: fullNameController,
                    label: 'Full name',
                    width: 250,
                    hint: 'Enter full name',
                    validator: AppValidator.validateTextfield,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomTextFormField(
                    controller: phoneController,
                    label: 'Phone',
                    width: 250,
                    hint: 'Enter phone number of user',
                    textInputType: TextInputType.number,
                    validator: AppValidator.validateTextfield,
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  DropDown(
                    width: 250,
                    borderColor: AppColors.white,
                    borderRadius: 10,
                    hint: "Select role of user",
                    selectedValue: roleController.text,
                    items: widget.userModel.role.toLowerCase() == 'admin'
                        ? const [
                            'Manager',
                            "Admin",
                            "Cashier",
                            // "Chef",
                            // "Bartender",
                            "Waiter"
                          ]
                        : const [
                            //  "Chef",
                            // "Bartender",
                            "Cashier", "Waiter"
                          ],
                    onChanged: (value) {
                      roleController.text = value;
                    },
                  ),

                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FormButton(
              onPressed: () => Navigator.of(context).pop(),
              text: "Discard",
              bgColor: AppColors.red,
              textColor: AppColors.white,
              width: 120,
              iconWidget: Icons.clear,
              borderRadius: 20,
            ),
            FormButton(
              onPressed: () {
                //String userId = u.FirebaseAuth.instance.currentUser!.uid;
                UserModel userModel = UserModel(
                    userId: widget.userList[index].userId,
                    email: widget.userList[index].email,
                    fullname:fullNameController.text, //widget.userList[index].fullname,
                    imageUrl: 'imageUrl',
                    phone:  phoneController.text,//widget.userList[index].phone,
                    role: roleController.text,//roleController.text,
                    tenantId: widget.userModel.tenantId,
                    createdAt: widget.userList[index].createdAt,
                    updatedAt: Timestamp.fromDate(DateTime.now()),
                    accountStatus: widget.userList[index].accountStatus);

                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(widget.userList[index].userId)
                    .update(userModel.toFirestore());
                setState(() {
                  widget.userList[index].fullname = fullNameController.text;
                  widget.userList[index].phone = phoneController.text;
                  widget.userList[index].role = roleController.text;
                });
                print('User ${widget.userList[index].fullname} edited');

                Navigator.of(context).pop();
              },
              text: "Update",
              bgColor: AppColors.green,
              textColor: AppColors.white,
              width: 120,
              iconWidget: Icons.add,
              borderRadius: 20,
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(int index, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deativate User'),
          content: Text(
              'Are you sure you want to Deativate ${widget.userList[index].fullname}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                setState(() {
                  widget.userList[index].accountStatus = !widget.userList[index]
                      .accountStatus; // Remove user from the list
                });
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(widget.userList[index].userId)
                    .update({"accountStatus": false});

                print('User deleted');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enable horizontal scrolling
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context)
                      .size
                      .width), // Ensure it fits within screen width
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // Enable vertical scrolling
                child: DataTable(
                  columns: const [
                    // DataColumn(
                    //     label: Text('INDEX', style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('EMAIL',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('FULL NAME',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('PHONE',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('ROLE',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('IS ACTIVE',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('ACTIONS',
                            style: TextStyle(color: Colors.white))),
                  ],
                  rows: List.generate(paginatedUsers.length, (index) {
                    final userIndex = (currentPage - 1) * rowsPerPage + index;
                    return DataRow(cells: [
                      // DataCell(Text((index + 1).toString(),
                      //     style: const TextStyle(color: Colors.white))),
                      DataCell(Text(paginatedUsers[index].email ?? '',
                          style: const TextStyle(color: Colors.white))),
                      DataCell(Text(paginatedUsers[index].fullname ?? '',
                          style: const TextStyle(color: Colors.white))),
                      DataCell(Text(paginatedUsers[index].phone ?? '',
                          style: const TextStyle(color: Colors.white))),
                      DataCell(Text(paginatedUsers[index].role.toString() ?? '',
                          style: const TextStyle(color: Colors.white))),
                      DataCell(Icon(
                        paginatedUsers[index].accountStatus
                            ? Icons.verified
                            : Icons.block,
                        color: paginatedUsers[index].accountStatus
                            ? Colors.green
                            : Colors.red,
                      )),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _editUser(userIndex);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteUser(
                                  userIndex, paginatedUsers[index].userId!);
                            },
                          ),
                        ],
                      )),
                    ]);
                  }),
                  headingRowColor: MaterialStateProperty.all(Colors.black),
                  dataRowColor: MaterialStateProperty.all(Colors.grey[850]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
