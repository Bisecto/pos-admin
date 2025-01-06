import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pos_admin/model/product_model.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/utills/app_utils.dart';
import '../../../../model/brand_model.dart';
import '../../../../model/category_model.dart';
import '../../../../model/log_model.dart';
import '../../../../repository/log_actions.dart';
import '../../../../res/app_enums.dart';
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
  final UserModel userModel;

  ProductTableScreen(
      {required this.productList,
      required this.brandList,
      required this.categoryList,
      required this.userModel});

  @override
  _ProductTableScreenState createState() => _ProductTableScreenState();
}

class _ProductTableScreenState extends State<ProductTableScreen> {
  int rowsPerPage = 10;
  int currentPage = 1;

  int get totalItems => widget.productList.length;

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
      return widget.categoryList
          .firstWhere((c) => c.categoryId == categoryId)
          .categoryName;
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
    final TextEditingController discountController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController selectedProductType = TextEditingController();
    selectedProductType.text=widget.productList[index].productType;
    productNameController.text = widget.productList[index].productName;
    skuController.text = widget.productList[index].sku;
    priceController.text = widget.productList[index].price.toString();
    discountController.text = widget.productList[index].discount.toString();

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
                  hint: 'Enter product sku',
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
                DropDown(
                  width: 250,
                  borderColor: AppColors.white,
                  selectedValue: selectedProductType.text,
                  borderRadius: 10,
                  hint: "Product Type*",
                  items: const ['food', 'drinks'],
                  onChanged: (value) {
                    //int index = categories.indexOf(value);
                    setState(() {
                      selectedProductType.text = value;
                      //_filterProducts();
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: priceController,
                  label: 'Price',
                  width: 250,
                  hint: 'Enter product price',
                  textInputType: TextInputType.number,
                ),
                CustomTextFormField(
                  controller: discountController,
                  label: 'Discount',
                  width: 250,
                  hint: 'Enter Discounted value',
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
            if(widget.userModel.addingEditingProductsDetails)

              FormButton(
              onPressed: () {
                String userId = FirebaseAuth.instance.currentUser!.uid;
                if (productNameController.text.isNotEmpty) {
                  if (double.parse(discountController.text) > 100) {
                    MSG.warningSnackBar(
                        context, "Discount cannot be greater than 100.");
                  } else {
                    Product newProduct = Product(
                      productName: productNameController.text.toLowerCase(),
                      updatedBy: userId,
                      createdAt: widget.productList[index].createdAt,
                      updatedAt: Timestamp.fromDate(DateTime.now()),
                      productId: widget.productList[index].productId,
                      createdBy: widget.productList[index].createdBy,
                      categoryId: widget.productList[index].categoryId,
                      brandId: widget.productList[index].brandId,
                      productImageUrl:
                          widget.productList[index].productImageUrl,
                      price: double.parse(priceController.text.toString()),
                      sku: skuController.text,
                      discount: double.parse(discountController.text),
                      productType:selectedProductType.text,// widget.productList[index].productType,
                    );
                    FirebaseFirestore.instance
                        .collection('Enrolled Entities')
                        .doc(
                            widget.userModel.tenantId) // Replace with tenant ID
                        .collection('Products')
                        .doc(widget.productList[index].productId)
                        .update(newProduct.toFirestore());
                    LogActivity logActivity = LogActivity();
                    LogModel logModel = LogModel(
                        actionType: LogActionType.productEdit.toString(),
                        actionDescription: "${widget.userModel.fullname} edited product with Id from ${widget.productList[index]} to ${newProduct}",
                        performedBy: widget.userModel.fullname,
                        userId: widget.userModel.userId);
                    logActivity.logAction(widget.userModel.tenantId.trim(), logModel);
                    setState(() {
                      widget.productList[index].productName =
                          productNameController.text;
                      widget.productList[index].price =
                          double.parse(priceController.text);
                      widget.productList[index].discount =
                          double.parse(discountController.text);
                    });
                    print(
                        'Product ${widget.productList[index].productName} edited');
                  }
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

  void _deleteProduct(int index, String productId,String productName) {
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
                    .doc(widget.userModel.tenantId) // Replace with tenant ID
                    .collection('Products')
                    .doc(productId)
                    .delete();
                LogActivity logActivity = LogActivity();
                LogModel logModel = LogModel(
                    actionType: LogActionType.systemStartStopDay.toString(),
                    actionDescription: "${widget.userModel.fullname} deleted product with id $productId and name $productName",
                    performedBy: widget.userModel.fullname,
                    userId: widget.userModel.userId);
                logActivity.logAction(widget.userModel.tenantId.trim(), logModel);
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
    return Container(
      height: AppUtils.deviceScreenSize(context).height - 200,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  // Enable horizontal scrolling
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    // Ensure it uses available width
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      // Enable vertical scrolling
                      child: DataTable(
                        columns: const [
                          // DataColumn(
                          //     label: Text('INDEX', style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('PRODUCT NAME',
                                  style: TextStyle(color: Colors.white))),DataColumn(
                              label: Text('PRODUCT TYPE',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('BRAND',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('CATEGORY',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('SKU',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('PRICE',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('Discount(%)',
                                  style: TextStyle(color: Colors.white))),
                          DataColumn(
                              label: Text('ACTIONS',
                                  style: TextStyle(color: Colors.white))),
                        ],
                        rows: List.generate(paginatedProducts.length, (index) {
                          final productIndex =
                              (currentPage - 1) * rowsPerPage + index;
                          return DataRow(cells: [
                            // DataCell(Text((index + 1).toString(),
                            //     style: const TextStyle(color: Colors.white))),
                            DataCell(Text(paginatedProducts[index].productName,
                                style: const TextStyle(color: Colors.white))),DataCell(Text(paginatedProducts[index].productType.toUpperCase(),
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(
                                _getBrandName(
                                        paginatedProducts[index].brandId ??
                                            '') ??
                                    '',
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(
                                _getCategoryName(
                                        paginatedProducts[index].categoryId ??
                                            '') ??
                                    '',
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(paginatedProducts[index].sku,
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(
                                paginatedProducts[index].price.toString(),
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Text(
                                paginatedProducts[index].discount.toString(),
                                style: const TextStyle(color: Colors.white))),
                            DataCell(Row(
                              children: [
                                if(!widget.userModel.addingEditingProductsDetails)
                                  Container(),
                                if(widget.userModel.addingEditingProductsDetails)

                                  ...[IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _editProduct(productIndex);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteProduct(productIndex,
                                        paginatedProducts[index].productId,paginatedProducts[index].productName,);
                                  },
                                ),]
                              ],
                            )),
                          ]);
                        }),
                        headingRowColor: WidgetStateProperty.all(Colors.black),
                        dataRowColor: WidgetStateProperty.all(Colors.grey[850]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
