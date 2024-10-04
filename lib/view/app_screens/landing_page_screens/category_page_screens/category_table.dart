import 'package:flutter/material.dart';
import 'package:pos_admin/model/category_model.dart';
import 'package:pos_admin/res/app_images.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/widgets/app_custom_text.dart';

import '../../../../res/app_colors.dart';

class CategoryTableScreen extends StatefulWidget {
  final List<Category> categoryList;

  CategoryTableScreen({required this.categoryList});

  @override
  _CategoryTableScreenState createState() => _CategoryTableScreenState();
}

class _CategoryTableScreenState extends State<CategoryTableScreen> {
  int rowsPerPage = 10; // Control pagination size
  int currentPage = 1;

  int get totalItems => widget.categoryList.length;

  List<Category> get paginatedcategorys {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return widget.categoryList.sublist(start, end > totalItems ? totalItems : end);
  }

  // Method to handle edit action
  void _editCategory(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Category ${widget.categoryList[index].categoryName}'),
          content: const Text('Edit form could be placed here.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                // Handle saving changes
                print('Category ${widget.categoryList[index].categoryName} edited');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to handle delete action
  void _deleteCategory(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          title: TextStyles.textSubHeadings(textValue: 'Delete Category',textColor: AppColors.white),
          content: CustomText(
              text:'Are you sure you want to delete ${widget.categoryList[index].categoryName}?',color: AppColors.white),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  widget.categoryList.removeAt(index); // Remove Category from the list
                });
                print('Category ${widget.categoryList[index].categoryName} deleted');
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
              child: DataTable(
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(20),
                ),
                columns: const [
                  DataColumn(label: Text('INDEX', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('CATEGORY ID', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('CATEGORY NAME', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('ACTIONS', style: TextStyle(color: Colors.white))),
                ],
                rows: List.generate(paginatedcategorys.length, (index) {
                  final categoryIndex = (currentPage - 1) * rowsPerPage + index;
                  return DataRow(cells: [

                    DataCell(Text((index+1).toString(), style: const TextStyle(color: Colors.white))),
                    DataCell(Text(paginatedcategorys[index].categoryId, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(paginatedcategorys[index].categoryName.toString(), style: const TextStyle(color: Colors.white))),

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
                            _deleteCategory(categoryIndex);
                          },
                        ),
                      ],
                    )),
                  ]);
                }),
                headingRowColor: MaterialStateProperty.all(Colors.black),
                dataRowColor: MaterialStateProperty.all(Colors.grey[850]),
                dividerThickness: 1,
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
                      color: currentPage == (index + 1) ? Colors.purple : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: currentPage == (index + 1) ? Colors.white : Colors.black,
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