import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pos_admin/model/category_model.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/widgets/app_custom_text.dart';

import '../../../../bloc/category_bloc/category_bloc.dart';
import '../../../../model/user_model.dart';
import '../../../../res/app_colors.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../widgets/form_button.dart';
import '../../../widgets/form_input.dart';

class CategoryTableScreen extends StatefulWidget {
  final List<Category> categoryList;
  final UserModel userModel;

  CategoryTableScreen({required this.categoryList,required this.userModel});

  @override
  _CategoryTableScreenState createState() => _CategoryTableScreenState();
}

class _CategoryTableScreenState extends State<CategoryTableScreen> {
  int rowsPerPage = 10; // Control pagination size
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    print(
        "Category table received list of length: ${widget.categoryList.length}");
  }

  int get totalItems => widget.categoryList.length;

  List<Category> get paginatedcategorys {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return widget.categoryList.sublist(start,
        end > widget.categoryList.length ? widget.categoryList.length : end);
  }

  @override
  void didUpdateWidget(covariant CategoryTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    print(
        "Category table updated with list of length: ${widget.categoryList.length}");
  }

  CategoryBloc categoryBloc = CategoryBloc();

  void _editCategory(int index) {
    final TextEditingController categoryNameController =
        TextEditingController();
    categoryNameController.text = widget.categoryList[index].categoryName!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextStyles.textHeadings(
              textValue: 'Edit Category',
              textSize: 20,
              textColor: AppColors.white),
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextFormField(
                  controller: categoryNameController,
                  label: 'Category Name',
                  width: 250,
                  hint: 'Enter category name',
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

                if (categoryNameController.text.isNotEmpty) {
                  Category newCategory = Category(
                    categoryName: categoryNameController.text,
                    updatedBy: userId,
                    createdAt: widget.categoryList[index].createdAt,
                    updatedAt: Timestamp.fromDate(DateTime.now()),
                    categoryId: widget.categoryList[index].categoryId, createdBy: widget.categoryList[index].createdBy,
                  );
                  FirebaseFirestore.instance
                      .collection('Enrolled Entities')
                      .doc(widget.userModel.tenantId) // Replace with the tenant ID
                      .collection('Category')
                      .doc(widget.categoryList[index].categoryId)
                      .update(newCategory.toFirestore());
                  setState(() {
                    widget.categoryList[index].categoryName =
                        categoryNameController.text;
                  });
                  print(
                      'Category ${widget.categoryList[index].categoryName} edited');
                } else {
                  MSG.warningSnackBar(
                      context, "Category name cannot be empty.");
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

  // void _editCategory(int index) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title:
  //             Text('Edit Category ${widget.categoryList[index].categoryName}'),
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
  //                   'Category ${widget.categoryList[index].categoryName} edited');
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _deleteCategory(int index, String categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          title: TextStyles.textSubHeadings(
              textValue: 'Delete Category', textColor: AppColors.white),
          content: CustomText(
              text:
                  'Are you sure you want to delete ${widget.categoryList[index].categoryName}?',
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
                  widget.categoryList
                      .removeAt(index); // Remove Category from the list
                });
                try {
                  print(categoryId);
                  FirebaseFirestore.instance
                      .collection('Enrolled Entities')
                      .doc(widget.userModel.tenantId) // Replace with the tenant ID
                      .collection('Category')
                      .doc(categoryId)
                      .delete();
                } catch (e) {
                  print(e);
                }
                print('Category deleted');
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
                  minWidth: MediaQuery.of(context).size.width, // Ensure full width
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
                      //   label: Text('CATEGORY ID',
                      //       style: TextStyle(color: Colors.white)),
                      // ),
                      DataColumn(
                        label: Text('CATEGORY NAME',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DataColumn(
                        label: Text('ACTIONS', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    rows: List.generate(paginatedcategorys.length, (index) {
                      final categoryIndex = (currentPage - 1) * rowsPerPage + index;
                      return DataRow(cells: [
                        // DataCell(Text(
                        //   (index + 1).toString(),
                        //   style: const TextStyle(color: Colors.white),
                        // )),
                        // DataCell(Text(
                        //   paginatedcategorys[index].categoryId!,
                        //   style: const TextStyle(color: Colors.white),
                        // )),
                        DataCell(Text(
                          paginatedcategorys[index].categoryName.toString(),
                          style: const TextStyle(color: Colors.white),
                        )),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _editCategory(categoryIndex);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteCategory(
                                  categoryIndex,
                                  paginatedcategorys[index].categoryId!,
                                );
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
