import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pos_admin/model/product_model.dart';
import 'package:pos_admin/utills/app_utils.dart';
import '../../../../model/brand_model.dart';
import '../../../../model/category_model.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../widgets/app_custom_text.dart';
import '../../../widgets/drop_down.dart';
import '../../../widgets/form_button.dart';
import '../../../widgets/form_input.dart';
import '../../../../res/app_colors.dart';

class ProductTableScreen extends StatefulWidget {
  final List<Product> productList;
  final List<Brand> brandList;
  final List<Category> categoryList;

  ProductTableScreen(
      {required this.productList,
      required this.brandList,
      required this.categoryList});

  @override
  _ProductTableScreenState createState() => _ProductTableScreenState();
}

class _ProductTableScreenState extends State<ProductTableScreen> {
  int rowsPerPage = 10;
  int currentPage = 1;

  String? _getBrandName(String brandId) {
    // Check if any brand matches the given brandId
    if (widget.brandList.any((b) => b.brandId == brandId)) {
      return widget.brandList.firstWhere((b) => b.brandId == brandId).brandName;
    }
    // Return a default message if no match is found
    return 'Unknown';
  }

  String? _getCategoryName(String categoryId) {
    // Check if any category matches the given categoryId
    if (widget.categoryList.any((c) => c.categoryId == categoryId)) {
      return widget.categoryList.firstWhere((c) => c.categoryId == categoryId).categoryName;
    }
    // Return a default message if no match is found
    return 'Unknown';
  }

  List<Product> get paginatedProducts {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return widget.productList.sublist(start,
        end > widget.productList.length ? widget.productList.length : end);
  }

  void _editProduct(int index) {
    final TextEditingController productNameController = TextEditingController();
    final TextEditingController skuController = TextEditingController();
    //final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    // final TextEditingController selectedCategoryName = TextEditingController();
    // final TextEditingController selectedBrandName = TextEditingController();
    // final TextEditingController selectedCategoryId = TextEditingController();
    // final TextEditingController selectedBrandId = TextEditingController();
    productNameController.text = widget.productList[index].productName ?? '';
    skuController.text = widget.productList[index].sku ?? '';
    //quantityController.text = widget.productList[index].qu ?? '';
    priceController.text = widget.productList[index].price.toString() ?? '';
    // selectedBrandId.text=widget.productList[index].brandId;
    // selectedCategoryId.text=widget.productList[index].categoryId;
    //selectedBrandName.text=widget.productList[index].;
    // List<String> brands = [];
    // List<String> ids = [];
    // for (int i = 0; i < widget.brandList.length; i++) {
    //   brands.add(widget.brandList[i].brandName.toString());
    //   ids.add(widget.brandList[i].brandId.toString());
    // }
    // List<String> categories = [];
    // List<String> categoriesIds = [];
    // for (int i = 0; i < widget.categoryList.length; i++) {
    //   categories.add(widget.categoryList[i].categoryName.toString());
    //   categoriesIds.add(widget.categoryList[i].categoryId.toString());
    // }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextStyles.textHeadings(
              textValue: 'Edit Product',
              textSize: 22,
              textColor: AppColors.white),
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          content: SingleChildScrollView(
            child: Column(
              children: [
                // String productImageUrl;

                CustomTextFormField(
                  controller: skuController,
                  label: 'SKU(optional)',
                  width: 250,
                  hint: 'Enter sku',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: productNameController,
                  label: 'Product Name*',
                  width: 250,
                  hint: 'Enter product name',
                ),
                SizedBox(
                  height: 10,
                ),
                // CustomTextFormField(
                //   controller: quantityController,
                //   label: 'Quantity(optional)',
                //   width: 250,
                //   hint: 'Enter product name',
                //   textInputType: TextInputType.number,
                // ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: priceController,
                  label: 'Price',
                  width: 250,
                  hint: 'Enter product name',
                  textInputType: TextInputType.number,
                ),
                // DropDown(
                //   width: 250,
                //   borderColor: AppColors.white,
                //   borderRadius: 10,
                //   hint: "Brand(optional)",
                //   selectedValue: selectedBrandName.text,
                //   items: brands,
                //   onChanged: (value) {
                //     int index = brands.indexOf(value);
                //
                //     setState(() {
                //       selectedBrandId.text = categoriesIds[index];
                //     });
                //   },
                // ),
                // DropDown(
                //   width: 250,
                //   borderColor: AppColors.white,
                //   selectedValue: selectedCategoryName.text,
                //   borderRadius: 10,
                //   hint: "Category*",
                //   items: categories,
                //   onChanged: (value) {
                //     int index = categories.indexOf(value);
                //
                //     setState(() {
                //       selectedCategoryId.text = categoriesIds[index];
                //     });
                //   },
                // ),

                SizedBox(
                  height: 10,
                ),
              ],
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
                String userId = FirebaseAuth.instance.currentUser!.uid;
                if (productNameController.text.isNotEmpty) {
                  Product newProduct = Product(
                    productName: productNameController.text,
                    updatedBy: userId,
                    createdAt: widget.productList[index].createdAt,
                    updatedAt: Timestamp.fromDate(DateTime.now()),
                    productId: widget.productList[index].productId,
                    createdBy: widget.productList[index].createdBy,
                    categoryId: widget.productList[index].categoryId,
                    brandId: widget.productList[index].brandId,
                    productImageUrl: widget.productList[index].productImageUrl,
                    price: double.parse(priceController.text.toString()),
                    sku: skuController.text,
                  );
                  FirebaseFirestore.instance
                      .collection('Enrolled Entities')
                      .doc('8V8YTiKWyObO7tppMHeP') // Replace with tenant ID
                      .collection('Products')
                      .doc(widget.productList[index].productId)
                      .update(newProduct.toFirestore());
                  setState(() {
                    widget.productList[index].productName =
                        productNameController.text;
                  });
                  print(
                      'Product ${widget.productList[index].productName} edited');
                } else {
                  MSG.warningSnackBar(context, "Product name cannot be empty.");
                }
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

  void _deleteProduct(int index, String productId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text(
              'Are you sure you want to delete ${widget.productList[index].productName}?'),
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
                  widget.productList
                      .removeAt(index); // Remove product from the list
                });
                await FirebaseFirestore.instance
                    .collection('Enrolled Entities')
                    .doc('8V8YTiKWyObO7tppMHeP') // Replace with tenant ID
                    .collection('Product')
                    .doc(productId)
                    .delete();
                print('Product deleted');
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
            child: DataTable(
              columns: const [
                DataColumn(
                    label:
                        Text('INDEX', style: TextStyle(color: Colors.white))),
                // DataColumn(
                //     label: Text('PRODUCT ID',
                //         style: TextStyle(color: Colors.white))),
                DataColumn(
                    label: Text('PRODUCT NAME',
                        style: TextStyle(color: Colors.white))),
                DataColumn(
                    label:
                        Text('BRAND', style: TextStyle(color: Colors.white))),
                DataColumn(
                    label: Text('CATEGORY',
                        style: TextStyle(color: Colors.white))),
                DataColumn(
                    label: Text('SKU', style: TextStyle(color: Colors.white))),
                DataColumn(
                    label:
                        Text('PRICE', style: TextStyle(color: Colors.white))),
                // DataColumn(
                //     label: Text('CREATED AT',
                //         style: TextStyle(color: Colors.white))),
                DataColumn(
                    label:
                        Text('ACTIONS', style: TextStyle(color: Colors.white))),
              ],
              rows: List.generate(paginatedProducts.length, (index) {
                final productIndex = (currentPage - 1) * rowsPerPage + index;
                return DataRow(cells: [
                  DataCell(Text((index + 1).toString(),
                      style: const TextStyle(color: Colors.white))),
                  // DataCell(Text(paginatedProducts[index].productId!,
                  //     style: const TextStyle(color: Colors.white))),
                  DataCell(Text(paginatedProducts[index].productName ?? '',
                      style: const TextStyle(color: Colors.white))),
                  DataCell(Text(
                      _getBrandName(paginatedProducts[index].brandId ?? '') ??
                          '',
                      style: const TextStyle(color: Colors.white))),
                  DataCell(Text(
                      _getCategoryName(
                              paginatedProducts[index].categoryId ?? '') ??
                          '',
                      style: const TextStyle(color: Colors.white))),
                  DataCell(Text(paginatedProducts[index].sku ?? '',
                      style: const TextStyle(color: Colors.white))),
                  DataCell(Text(paginatedProducts[index].price.toString() ?? '',
                      style: const TextStyle(color: Colors.white))),
                  // DataCell(Text(AppUtils.formatComplexDate(dateTime: DateTime.fromMillisecondsSinceEpoch(int.parse(paginatedProducts[index].createdAt.toString()) * 1000).toString()) ?? '',
                  //     style: const TextStyle(color: Colors.white))),
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
                          _deleteProduct(productIndex,
                              paginatedProducts[index].productId!);
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
      ],
    );
  }
}
