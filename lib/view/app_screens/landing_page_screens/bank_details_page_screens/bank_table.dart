import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/widgets/app_custom_text.dart';

import '../../../../bloc/bank_bloc/bank_bloc.dart';
import '../../../../model/bank_model.dart';
import '../../../../model/log_model.dart';
import '../../../../repository/log_actions.dart';
import '../../../../res/app_colors.dart';
import '../../../../res/app_enums.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../widgets/form_button.dart';
import '../../../widgets/form_input.dart';

class BankTableScreen extends StatefulWidget {
  final List<Bank> bankList;
  UserModel userModel;

  BankTableScreen({required this.bankList, required this.userModel});

  @override
  _BankTableScreenState createState() => _BankTableScreenState();
}

class _BankTableScreenState extends State<BankTableScreen> {
  int rowsPerPage = 10; // Control pagination size
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    print("Bank table received list of length: ${widget.bankList.length}");
  }

  int get totalItems => widget.bankList.length;

  List<Bank> get paginatedbanks {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return widget.bankList.sublist(
        start, end > widget.bankList.length ? widget.bankList.length : end);
  }

  @override
  void didUpdateWidget(covariant BankTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("Bank table updated with list of length: ${widget.bankList.length}");
  }

  BankBloc bankBloc = BankBloc();

  void _editBank(int index) {
    final TextEditingController bankNameController = TextEditingController();
    final TextEditingController accNameController = TextEditingController();
    final TextEditingController accNumberController = TextEditingController();

    bankNameController.text = widget.bankList[index].bankName;
    accNameController.text = widget.bankList[index].accountName;
    accNumberController.text = widget.bankList[index].accountNumber;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextStyles.textHeadings(
              textValue: 'Edit Bank', textSize: 20, textColor: AppColors.white),
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextFormField(
                  controller: bankNameController,
                  label: 'Bank Name',
                  width: 250,
                  hint: 'Enter bank name',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: accNameController,
                  label: 'Account Name',
                  width: 250,
                  hint: 'Enter account name',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: accNumberController,
                  label: 'Account Number',
                  maxLength: 10,
                  textInputType: TextInputType.number,
                  width: 250,
                  hint: 'Enter account number',
                ),
              ],
            ),
          ),
          actions: [
            FormButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              bgColor: AppColors.red,
              textColor: AppColors.white,
              width: 120,
              text: "Discard",
              iconWidget: Icons.clear,
              borderRadius: 20,
            ),
            FormButton(
              onPressed: () {
                String? userId = FirebaseAuth.instance.currentUser!.uid;

                if (bankNameController.text.isNotEmpty) {
                  Bank newBank = Bank(
                    bankName: bankNameController.text,
                    updatedBy: userId,
                    createdAt: widget.bankList[index].createdAt,
                    updatedAt: Timestamp.fromDate(DateTime.now()),
                    bankId: widget.bankList[index].bankId,
                    createdBy: widget.bankList[index].createdBy,
                    accountNumber: '',
                    accountName: '',
                  );
                  FirebaseFirestore.instance
                      .collection('Enrolled Entities')
                      .doc(widget
                          .userModel.tenantId) // Replace with the tenant ID
                      .collection('Bank')
                      .doc(widget.bankList[index].bankId)
                      .update(newBank.toFirestore());
                  LogActivity logActivity = LogActivity();
                  LogModel logModel = LogModel(
                      actionType: LogActionType.bankEdit.toString(),
                      actionDescription:
                          "${widget.userModel.fullname} edited bank name from${widget.bankList[index].bankName} to ${bankNameController.text}",
                      performedBy: widget.userModel.fullname,
                      userId: widget.userModel.userId);
                  logActivity.logAction(
                      widget.userModel.tenantId.trim(), logModel);
                  setState(() {
                    widget.bankList[index].bankName = bankNameController.text;
                  });

                  print('Bank ${widget.bankList[index].bankName} edited');
                } else {
                  MSG.warningSnackBar(context, "Bank name cannot be empty.");
                }
                Navigator.of(context).pop();
              },
              text: "Update",
              iconWidget: Icons.add,
              bgColor: AppColors.green,
              textColor: AppColors.white,
              width: 120,
              borderRadius: 20,
            )
          ],
        );
      },
    );
  }

  // void _editBank(int index) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title:
  //             Text('Edit Bank ${widget.bankList[index].bankName}'),
  //         content: const Text('Edit form could be placed here.'),
  //         actions: [
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text('Save'),
  //             onPressed: () {
  //               // Handle saving changes
  //               print(
  //                   'Bank ${widget.bankList[index].bankName} edited');
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _deleteBank(int index, String bankId, String bankName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          title: TextStyles.textSubHeadings(
              textValue: 'Delete Bank', textColor: AppColors.white),
          content: CustomText(
              text:
                  'Are you sure you want to delete ${widget.bankList[index].bankName}?',
              color: AppColors.white),
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
                  widget.bankList.removeAt(index); // Remove Bank from the list
                });
                try {
                  print(bankId);
                  FirebaseFirestore.instance
                      .collection('Enrolled Entities')
                      .doc(widget.userModel.tenantId)
                      .collection('Bank')
                      .doc(bankId)
                      .delete();
                  LogActivity logActivity = LogActivity();
                  LogModel logModel = LogModel(
                      actionType: LogActionType.bankDelete.toString(),
                      actionDescription:
                          "${widget.userModel.fullname} deleted bank with id  $bankId and name $bankName",
                      performedBy: widget.userModel.fullname,
                      userId: widget.userModel.userId);
                  logActivity.logAction(
                      widget.userModel.tenantId.trim(), logModel);
                } catch (e) {
                  print(e);
                }
                print('Bank deleted');
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
    return Container(
      height: AppUtils.deviceScreenSize(context).height - 200,
      width: AppUtils.deviceScreenSize(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Allow horizontal scrolling
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context)
                      .size
                      .width, // Ensure the table takes full width
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Allow vertical scrolling
                  child: DataTable(
                    decoration: BoxDecoration(
                      color: AppColors.darkYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    columns: [
                      // DataColumn(
                      //     label:
                      //     Text('INDEX', style: TextStyle(color: Colors.white))),
                      // DataColumn(
                      //     label: Text(' ID',
                      //         style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Bank NAME',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Account Number',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Account Name',
                              style: TextStyle(color: Colors.white))),
                      if (widget.userModel.role.toLowerCase() == 'admin')
                        DataColumn(
                            label: Text('ACTIONS',
                                style: TextStyle(color: Colors.white))),
                    ],
                    rows: List.generate(paginatedbanks.length, (index) {
                      final bankIndex = (currentPage - 1) * rowsPerPage + index;
                      return DataRow(cells: [
                        // DataCell(Text((index + 1).toString(),
                        //     style: const TextStyle(color: Colors.white))),
                        // DataCell(Text(paginatedbanks[index].bankId!,
                        //     style: const TextStyle(color: Colors.white))),
                        DataCell(Text(paginatedbanks[index].bankName.toString(),
                            style: const TextStyle(color: Colors.white))),
                        DataCell(Text(
                            paginatedbanks[index].accountNumber.toString(),
                            style: const TextStyle(color: Colors.white))),
                        DataCell(Text(
                            paginatedbanks[index].accountName.toString(),
                            style: const TextStyle(color: Colors.white))),
                        if (widget.userModel.role.toLowerCase() == 'admin')
                          DataCell(Row(
                            children: [
                              if (!widget.userModel.addingEditingBankDetails)
                                Container(),
                              if (widget
                                  .userModel.addingEditingBankDetails) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _editBank(bankIndex);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteBank(
                                        bankIndex,
                                        paginatedbanks[index].bankId,
                                        paginatedbanks[index].bankName);
                                  },
                                ),
                              ]
                            ],
                          )),
                      ]);
                    }),
                    headingRowColor: WidgetStateProperty.all(Colors.black),
                    dataRowColor: WidgetStateProperty.all(Colors.grey[850]),
                    dividerThickness: 1,
                  ),
                ),
              ),
            ),
          ),
          // Pagination controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                (totalItems / rowsPerPage).ceil(),
                (index) => GestureDetector(
                  onTap: () {
                    setState(() {
                      currentPage = index + 1;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: currentPage == (index + 1)
                          ? Colors.purple
                          : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: currentPage == (index + 1)
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
