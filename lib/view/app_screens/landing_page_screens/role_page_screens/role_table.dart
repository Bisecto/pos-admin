import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as u;
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/utills/app_utils.dart';
import '../../../../model/brand_model.dart';
import '../../../../model/category_model.dart';
import '../../../../model/log_model.dart';
import '../../../../repository/log_actions.dart';
import '../../../../res/app_enums.dart';
import '../../../../utills/app_validator.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../important_pages/export_to_excel.dart';
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

  void _editUser(int index, UserModel userModel) {
    //final TextEditingController emailController = TextEditingController();
    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController roleController = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    fullNameController.text = widget.userList[index].fullname;
    phoneController.text = widget.userList[index].phone;
    roleController.text = widget.userList[index].role.toString();
    final List<String> activitiesRoles = [
      'Start/End Day',
      'View Finance',
      'Creating/Editing Profile',
      'Adding/Editing Business Profile',
      'Adding/Editing Products Details',
      'Viewing Logs',
      'Adding/Editing Bank Details',
      'Adding/Editing Printers',
      'Voiding Products',
      'Voiding Table Order',
      'Adding/Editing Table',
    ];

// Retrieve the role states from the UserModel
    List<bool> isSelected = [
      userModel.startEndDay,
      userModel.viewFinance,
      userModel.creatingEditingProfile,
      userModel.addingEditingBusinessProfile,
      userModel.addingEditingProductsDetails,
      userModel.viewingLogs,
      userModel.addingEditingBankDetails,
      userModel.addingEditingPrinters,
      userModel.voidingProducts,
      userModel.voidingTableOrder,
      userModel.addingEditingTable,
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: TextStyles.textHeadings(
                textValue: 'Edit User',
                textSize: 22,
                textColor: AppColors.white,
              ),
              backgroundColor: AppColors.darkModeBackgroundContainerColor,
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextFormField(
                        controller: fullNameController,
                        label: 'Full name',
                        width: 250,
                        hint: 'Enter full name',
                        validator: AppValidator.validateTextfield,
                      ),
                      const SizedBox(height: 10),
                      CustomTextFormField(
                        controller: phoneController,
                        label: 'Phone',
                        width: 250,
                        hint: 'Enter phone number of user',
                        textInputType: TextInputType.number,
                        validator: AppValidator.validateTextfield,
                      ),
                      const SizedBox(height: 10),
                      DropDown(
                        width: 250,
                        borderColor: AppColors.white,
                        borderRadius: 10,
                        hint: "Select role of user",
                        selectedValue: roleController.text,
                        items: widget.userModel.role.toLowerCase() == 'admin'
                            ? const ['Manager', "Admin", "Cashier", "Waiter"]
                            : const ["Cashier", "Waiter"],
                        onChanged: (value) {
                          setState(() {
                            roleController.text = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      if (roleController.text.toLowerCase() == 'manager')
                        SizedBox(
                          height: 200,
                          width: double.maxFinite,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 5.0,
                              mainAxisSpacing: 5.0,
                              childAspectRatio: 3,
                            ),
                            itemCount: activitiesRoles.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    isSelected[index] = !isSelected[index];
                                    print(isSelected[index]);
                                  });
                                },
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected[index],
                                      onChanged: (value) {
                                        setDialogState(() {
                                          isSelected[index] = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.green,
                                    ),
                                    Expanded(
                                      child: CustomText(
                                        text: activitiesRoles[index],
                                        color: AppColors.white,
                                        maxLines: 2,
                                        size: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 10),
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
                    UserModel userModel = UserModel(
                      userId: widget.userList[index].userId,
                      email: widget.userList[index].email,
                      fullname: fullNameController.text,
                      //widget.userList[index].fullname,
                      imageUrl: 'imageUrl',
                      phone: phoneController.text,
                      //widget.userList[index].phone,
                      role: roleController.text,
                      //roleController.text,
                      tenantId: widget.userModel.tenantId,
                      createdAt: widget.userList[index].createdAt,
                      updatedAt: Timestamp.fromDate(DateTime.now()),
                      accountStatus: widget.userList[index].accountStatus,
                      startEndDay: isSelected[0],
                      viewFinance: isSelected[1],
                      creatingEditingProfile: isSelected[2],
                      addingEditingBusinessProfile: isSelected[3],
                      addingEditingProductsDetails: isSelected[4],
                      viewingLogs: isSelected[5],
                      addingEditingBankDetails: isSelected[6],
                      addingEditingPrinters: isSelected[7],
                      voidingProducts: isSelected[8],
                      voidingTableOrder: isSelected[9],
                      addingEditingTable: isSelected[10],
                    );

                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc(widget.userList[index].userId)
                        .update(userModel.toFirestore());
                    LogActivity logActivity = LogActivity();
                    LogModel logModel = LogModel(
                        actionType: LogActionType.userEdit.toString(),
                        actionDescription:
                            "${widget.userModel.fullname} edited user with Id from ${widget.userList[index]} to $userModel",
                        performedBy: widget.userModel.fullname,
                        userId: widget.userModel.userId);
                    logActivity.logAction(
                        widget.userModel.tenantId.trim(), logModel);
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
      },
    );
  }

  void _deleteUser(int index, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deativate User'),
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
                LogActivity logActivity = LogActivity();
                LogModel logModel = LogModel(
                    actionType: LogActionType.userEdit.toString(),
                    actionDescription:
                        "${widget.userModel.fullname} deactivated user with Id  ${widget.userList[index].userId} and name ${widget.userList[index].fullname} ",
                    performedBy: widget.userModel.fullname,
                    userId: widget.userModel.userId);
                logActivity.logAction(
                    widget.userModel.tenantId.trim(), logModel);
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(widget.userModel.creatingEditingProfile)
          Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: GestureDetector(
              onTap:(){
                ExcelExporter.exportToExcel(
                  context: context,
                  items: widget.userList,
                  fileName: 'Staff_list',
                  toJson: (item) => item.toFirestore(),
                    excludeFields: [
                      'userId',
                      'imageUrl',
                      'tenantId',
                      'createdAt',
                      'updatedAt',
                      'startEndDay',
                      'viewFinance',
                      'creatingEditingProfile',
                      'addingEditingBusinessProfile',
                      'addingEditingProductsDetails',
                      'viewingLogs',
                      'addingEditingBankDetails',
                      'addingEditingPrinters',
                      'voidingProducts',
                      'voidingTableOrder',
                      'addingEditingTable',
                    ]

                );
                // filteredProducts();
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
                        Icons.upload,
                        color: AppColors.white,
                      ),
                      CustomText(
                        text: "  Export",
                        size: 18,
                        color: AppColors.white,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        SizedBox(height: 20,),
        if(widget.userModel.creatingEditingProfile)

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
                          if (!widget.userModel.creatingEditingProfile)
                            Container(),
                          if (widget.userModel.creatingEditingProfile) ...[
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _editUser(userIndex, paginatedUsers[index]);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteUser(
                                    userIndex, paginatedUsers[index].userId!);
                              },
                            ),
                          ]
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
