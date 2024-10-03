import 'package:flutter/material.dart';
import 'package:pos_admin/res/app_images.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/widgets/app_custom_text.dart';

import '../../../../res/app_colors.dart';

class BrandTableScreen extends StatefulWidget {
  final List<Map<String, dynamic>> brands;

  BrandTableScreen({required this.brands});

  @override
  _BrandTableScreenState createState() => _BrandTableScreenState();
}

class _BrandTableScreenState extends State<BrandTableScreen> {
  int rowsPerPage = 10; // Control pagination size
  int currentPage = 1;

  int get totalItems => widget.brands.length;

  List<Map<String, dynamic>> get paginatedbrands {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return widget.brands.sublist(start, end > totalItems ? totalItems : end);
  }

  // Method to handle edit action
  void _editBrand(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Brand ${widget.brands[index]['brandName']}'),
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
                print('Brand ${widget.brands[index]['brandName']} edited');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to handle delete action
  void _deleteBrand(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          title: TextStyles.textSubHeadings(textValue: 'Delete Brand',textColor: AppColors.white),
          content: CustomText(
              text:'Are you sure you want to delete ${widget.brands[index]['brandName']}?',color: AppColors.white),
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
                  widget.brands.removeAt(index); // Remove brand from the list
                });
                print('Brand ${widget.brands[index]['brandName']} deleted');
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
                  DataColumn(label: Text('BRAND ID', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('BRAND NAME', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('ACTIONS', style: TextStyle(color: Colors.white))),
                ],
                rows: List.generate(paginatedbrands.length, (index) {
                  final brandIndex = (currentPage - 1) * rowsPerPage + index;
                  return DataRow(cells: [

                    DataCell(Text(paginatedbrands[index]['index'].toString(), style: const TextStyle(color: Colors.white))),
                    DataCell(Text(paginatedbrands[index]['brandId'], style: const TextStyle(color: Colors.white))),
                    DataCell(Text(paginatedbrands[index]['brandName'].toString(), style: const TextStyle(color: Colors.white))),

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
                            _deleteBrand(brandIndex);
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