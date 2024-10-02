import 'package:flutter/material.dart';
import 'package:pos_admin/res/app_images.dart';
import 'package:pos_admin/utills/app_utils.dart';

import '../../../../res/app_colors.dart';

class ProductTableScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;

  ProductTableScreen({required this.products});

  @override
  _ProductTableScreenState createState() => _ProductTableScreenState();
}

class _ProductTableScreenState extends State<ProductTableScreen> {
  int rowsPerPage = 10; // Control pagination size
  int currentPage = 1;

  int get totalItems => widget.products.length;

  List<Map<String, dynamic>> get paginatedProducts {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return widget.products.sublist(start, end > totalItems ? totalItems : end);
  }

  // Method to handle edit action
  void _editProduct(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Product ${widget.products[index]['name']}'),
          content: Text('Edit form could be placed here.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                // Handle saving changes
                print('Product ${widget.products[index]['name']} edited');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to handle delete action
  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text(
              'Are you sure you want to delete ${widget.products[index]['name']}?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  widget.products.removeAt(index); // Remove product from the list
                });
                print('Product ${widget.products[index]['name']} deleted');
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
                  DataColumn(label: Text('PRODUCT ID', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('SKU', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('PRODUCT NAME', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('QUANTITY', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('PRICE', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('LOCATION', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('ACTIONS', style: TextStyle(color: Colors.white))),
                ],
                rows: List.generate(paginatedProducts.length, (index) {
                  final productIndex = (currentPage - 1) * rowsPerPage + index;
                  return DataRow(cells: [
                    DataCell(
                      CircleAvatar(
                        backgroundImage: AssetImage(AppImages.posTerminal),
                        radius: 20,
                      ),
                    ),
                    DataCell(Text(paginatedProducts[index]['sku'], style: const TextStyle(color: Colors.white))),
                    DataCell(Text(paginatedProducts[index]['name'], style: const TextStyle(color: Colors.white))),
                    DataCell(Text(paginatedProducts[index]['quantity'].toString(), style: const TextStyle(color: Colors.white))),
                    DataCell(Text(paginatedProducts[index]['price'], style: const TextStyle(color: Colors.white))),
                    DataCell(Row(
                      children: [
                        const Icon(Icons.location_pin, color: Colors.purpleAccent),
                        Text(paginatedProducts[index]['location'], style: const TextStyle(color: Colors.white)),
                      ],
                    )),
                    DataCell(Row(
                        children: [

                    IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        _editProduct(productIndex);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteProduct(productIndex);
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