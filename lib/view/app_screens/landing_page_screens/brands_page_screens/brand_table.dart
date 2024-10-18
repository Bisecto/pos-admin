import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/widgets/app_custom_text.dart';

import '../../../../bloc/brand_bloc/brand_bloc.dart';
import '../../../../model/brand_model.dart';
import '../../../../res/app_colors.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../widgets/form_button.dart';
import '../../../widgets/form_input.dart';

class BrandTableScreen extends StatefulWidget {
  final List<Brand> brandList;
  UserModel userModel;

  BrandTableScreen({required this.brandList,required this.userModel});

  @override
  _BrandTableScreenState createState() => _BrandTableScreenState();
}

class _BrandTableScreenState extends State<BrandTableScreen> {
  int rowsPerPage = 10; // Control pagination size
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    print(
        "Brand table received list of length: ${widget.brandList.length}");
  }

  int get totalItems => widget.brandList.length;

  List<Brand> get paginatedbrands {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return widget.brandList.sublist(start,
        end > widget.brandList.length ? widget.brandList.length : end);
  }

  @override
  void didUpdateWidget(covariant BrandTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
        "Brand table updated with list of length: ${widget.brandList.length}");
  }

  BrandBloc brandBloc = BrandBloc();

  void _editBrand(int index) {
    final TextEditingController brandNameController =
    TextEditingController();
    brandNameController.text = widget.brandList[index].brandName!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextStyles.textHeadings(
              textValue: 'Edit Brand',
              textSize: 20,
              textColor: AppColors.white),
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextFormField(
                  controller: brandNameController,
                  label: 'Brand Name',
                  width: 250,
                  hint: 'Enter brand name',
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

                if (brandNameController.text.isNotEmpty) {
                  Brand newBrand = Brand(
                    brandName: brandNameController.text,
                    updatedBy: userId,
                    createdAt: widget.brandList[index].createdAt,
                    updatedAt: Timestamp.fromDate(DateTime.now()),
                    brandId: widget.brandList[index].brandId, createdBy: widget.brandList[index].createdBy,
                  );
                  FirebaseFirestore.instance
                      .collection('Enrolled Entities')
                      .doc(widget.userModel.tenantId) // Replace with the tenant ID
                      .collection('Brand')
                      .doc(widget.brandList[index].brandId)
                      .update(newBrand.toFirestore());
                  setState(() {
                    widget.brandList[index].brandName =
                        brandNameController.text;
                  });
                  print(
                      'Brand ${widget.brandList[index].brandName} edited');
                } else {
                  MSG.warningSnackBar(
                      context, "Brand name cannot be empty.");
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

  // void _editBrand(int index) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title:
  //             Text('Edit Brand ${widget.brandList[index].brandName}'),
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
  //                   'Brand ${widget.brandList[index].brandName} edited');
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _deleteBrand(int index, String brandId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          title: TextStyles.textSubHeadings(
              textValue: 'Delete Brand', textColor: AppColors.white),
          content: CustomText(
              text:
              'Are you sure you want to delete ${widget.brandList[index].brandName}?',
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
                  widget.brandList
                      .removeAt(index); // Remove Brand from the list
                });
                try {
                  print(brandId);
                  FirebaseFirestore.instance
                      .collection('Enrolled Entities')
                      .doc(widget.userModel.tenantId) // Replace with the tenant ID
                      .collection('Brand')
                      .doc(brandId)
                      .delete();
                } catch (e) {
                  print(e);
                }
                print('Brand deleted');
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
              scrollDirection: Axis.horizontal,  // Allow horizontal scrolling
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width, // Ensure the table takes full width
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,  // Allow vertical scrolling
                  child: DataTable(
                    decoration: BoxDecoration(
                      color: AppColors.darkYellow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    columns: const [
                      // DataColumn(
                      //     label:
                      //     Text('INDEX', style: TextStyle(color: Colors.white))),
                      // DataColumn(
                      //     label: Text('CATEGORY ID',
                      //         style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('CATEGORY NAME',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('ACTIONS',
                              style: TextStyle(color: Colors.white))),
                    ],
                    rows: List.generate(paginatedbrands.length, (index) {
                      final brandIndex = (currentPage - 1) * rowsPerPage + index;
                      return DataRow(cells: [
                        // DataCell(Text((index + 1).toString(),
                        //     style: const TextStyle(color: Colors.white))),
                        // DataCell(Text(paginatedbrands[index].brandId!,
                        //     style: const TextStyle(color: Colors.white))),
                        DataCell(Text(
                            paginatedbrands[index].brandName.toString(),
                            style: const TextStyle(color: Colors.white))),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _editBrand(brandIndex);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteBrand(brandIndex,
                                    paginatedbrands[index].brandId!);
                              },
                            ),
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
