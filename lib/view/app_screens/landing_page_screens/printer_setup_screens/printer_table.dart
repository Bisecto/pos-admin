import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/model/printer_model.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/widgets/app_custom_text.dart';

import '../../../../bloc/printer_bloc/printer_bloc.dart';
import '../../../../model/log_model.dart';
import '../../../../model/printer_model.dart';
import '../../../../model/user_model.dart';
import '../../../../repository/log_actions.dart';
import '../../../../res/app_colors.dart';
import '../../../../res/app_enums.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../widgets/form_button.dart';
import '../../../widgets/form_input.dart';

class PrinterTableScreen extends StatefulWidget {
  final List<PrinterModel> printerList;
  final UserModel userModel;

  PrinterTableScreen({required this.printerList, required this.userModel});

  @override
  _PrinterTableScreenState createState() => _PrinterTableScreenState();
}

class _PrinterTableScreenState extends State<PrinterTableScreen> {
  int rowsPerPage = 10; // Control pagination size
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    print(
        "Printer table received list of length: ${widget.printerList.length}");
  }

  int get totalItems => widget.printerList.length;

  List<PrinterModel> get paginatedprinters {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return widget.printerList.sublist(start,
        end > widget.printerList.length ? widget.printerList.length : end);
  }

  @override
  void didUpdateWidget(covariant PrinterTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
        "Printer table updated with list of length: ${widget.printerList.length}");
  }

  PrinterBloc printerBloc = PrinterBloc();

  void _editPrinter(int index) {
    final TextEditingController printerNameController = TextEditingController();
    final TextEditingController printerPortController = TextEditingController();
    final TextEditingController printerIpController = TextEditingController();
    printerPortController.text = widget.printerList[index].port.toString();
    printerIpController.text = widget.printerList[index].ip.toString();
    printerNameController.text = widget.printerList[index].printerName;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextStyles.textHeadings(
              textValue: 'Edit Printer',
              textSize: 20,
              textColor: AppColors.white),
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextFormField(
                  controller: printerNameController,
                  label: 'Printer Name',
                  width: 250,
                  hint: 'Enter printer name',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: printerIpController,
                  label: 'Printer IP',
                  width: 250,
                  hint: 'Enter printer ip address',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: printerPortController,
                  label: 'Printer Port',
                  width: 250,
                  textInputType: TextInputType.number,
                  hint: 'Enter printer port',
                ),
                SizedBox(
                  height: 10,
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

                if (printerNameController.text.isNotEmpty) {
                  PrinterModel newPrinter = PrinterModel(
                    printerName: printerNameController.text,
                    updatedBy: userId,
                    createdAt: widget.printerList[index].createdAt,
                    updatedAt: Timestamp.fromDate(DateTime.now()),
                    printerId: widget.printerList[index].printerId,
                    createdBy: widget.printerList[index].createdBy,
                    ip: printerIpController.text,
                    port: int.parse(printerPortController.text),
                    type: widget.printerList[index].type,
                  );
                  FirebaseFirestore.instance
                      .collection('Enrolled Entities')
                      .doc(widget
                          .userModel.tenantId) // Replace with the tenant ID
                      .collection('Printer')
                      .doc(widget.printerList[index].printerId)
                      .update(newPrinter.toFirestore());
                  LogActivity logActivity = LogActivity();
                  LogModel logModel = LogModel(
                      actionType: LogActionType.printerEdit.toString(),
                      actionDescription:
                          "${widget.userModel.fullname} changed the pinter details from ${widget.printerList[index]} to ${newPrinter} ",
                      performedBy: widget.userModel.fullname,
                      userId: widget.userModel.userId);
                  logActivity.logAction(
                      widget.userModel.tenantId.trim(), logModel);
                  setState(() {
                    widget.printerList[index].printerName =
                        printerNameController.text;
                    widget.printerList[index].port =
                        int.parse(printerPortController.text);
                    widget.printerList[index].ip = printerIpController.text;
                  });
                  print(
                      'Printer ${widget.printerList[index].printerName} edited');
                } else {
                  MSG.warningSnackBar(context, "Printer name cannot be empty.");
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

  // void _editPrinter(int index) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title:
  //             Text('Edit Printer ${widget.printerList[index].printerName}'),
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
  //                   'Printer ${widget.printerList[index].printerName} edited');
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _deletePrinter(int index, String printerId, String printerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          title: TextStyles.textSubHeadings(
              textValue: 'Delete Printer', textColor: AppColors.white),
          content: CustomText(
              text:
                  'Are you sure you want to delete ${widget.printerList[index].printerName}?',
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
                  widget.printerList
                      .removeAt(index); // Remove Printer from the list
                });
                try {
                  print(printerId);
                  FirebaseFirestore.instance
                      .collection('Enrolled Entities')
                      .doc(widget
                          .userModel.tenantId) // Replace with the tenant ID
                      .collection('Printer')
                      .doc(printerId)
                      .delete();
                  LogActivity logActivity = LogActivity();
                  LogModel logModel = LogModel(
                      actionType: LogActionType.printerDelete.toString(),
                      actionDescription:
                          "${widget.userModel.fullname} deleted a printer with id $printerId and na me $printerName",
                      performedBy: widget.userModel.fullname,
                      userId: widget.userModel.userId);
                  logActivity.logAction(
                      widget.userModel.tenantId.trim(), logModel);
                } catch (e) {
                  print(e);
                }
                print('Printer deleted');
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
      //width: AppUtils.deviceScreenSize(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Allow horizontal scrolling
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth:
                      MediaQuery.of(context).size.width, // Ensure full width
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Allow vertical scrolling
                  child: DataTable(
                    decoration: BoxDecoration(
                      color: AppColors.darkYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    columns: const [
                      // DataColumn(
                      //   label: Text('INDEX', style: TextStyle(color: Colors.white)),
                      // ),
                      // DataColumn(
                      //   label: Text('Printer ID',
                      //       style: TextStyle(color: Colors.white)),
                      // ),
                      DataColumn(
                        label: Text('PRINTER NAME',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DataColumn(
                        label: Text('PRINTER IP ADDRESS',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DataColumn(
                        label: Text('PRINTER PORT',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DataColumn(
                        label: Text('PRINTER TYPE',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DataColumn(
                        label: Text('ACTIONS',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    rows: List.generate(paginatedprinters.length, (index) {
                      final printerIndex =
                          (currentPage - 1) * rowsPerPage + index;
                      return DataRow(cells: [
                        // DataCell(Text(
                        //   (index + 1).toString(),
                        //   style: const TextStyle(color: Colors.white),
                        // )),
                        // DataCell(Text(
                        //   paginatedprinters[index].printerId!,
                        //   style: const TextStyle(color: Colors.white),
                        // )),
                        DataCell(Text(
                          paginatedprinters[index].printerName.toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                        DataCell(Text(
                          paginatedprinters[index].ip.toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                        DataCell(Text(
                          paginatedprinters[index].port.toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                        DataCell(Text(
                          paginatedprinters[index].type.toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                        DataCell(Row(
                          children: [
                            if (!widget.userModel.addingEditingPrinters)
                              Container(),
                            if (widget.userModel.addingEditingPrinters) ...[
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _editPrinter(printerIndex);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deletePrinter(
                                    printerIndex,
                                    paginatedprinters[index].printerId!,
                                    paginatedprinters[index].printerName!,
                                  );
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
