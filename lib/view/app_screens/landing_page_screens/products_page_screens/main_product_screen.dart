import 'package:flutter/material.dart';
import 'package:pos_admin/model/category_model.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/products_page_screens/product_table.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_button.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../model/brand_model.dart';
import '../../../../res/app_colors.dart';
import '../../../widgets/app_custom_text.dart';

import 'package:flutter/material.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/products_page_screens/product_table.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../res/app_colors.dart';
import '../../../widgets/app_custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_admin/bloc/product_bloc/product_bloc.dart';
import 'package:pos_admin/model/product_model.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import 'package:pos_admin/view/widgets/form_button.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../important_pages/app_loading_page.dart';
import '../../../../res/app_colors.dart';

class MainProductScreen extends StatefulWidget {
  const MainProductScreen({super.key});

  @override
  State<MainProductScreen> createState() => _MainProductScreenState();
}

class _MainProductScreenState extends State<MainProductScreen> {
  final searchController = TextEditingController();
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  ProductBloc productBloc = ProductBloc();
  String selectedBrand = '';
  String selectedBrandId = '';
  String selectedCategory = '';
  String selectedCategoryId = '';

  @override
  void initState() {
    productBloc.add(GetProductEvent('8V8YTiKWyObO7tppMHeP'));
    super.initState();
  }

  void _filterProducts() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        final searchQuery = searchController.text.toLowerCase();

        // Check if the search query matches the product name, brand name, or category name
        final matchesProductName =
            product.productName?.toLowerCase().contains(searchQuery) ?? false;
        final matchesBrand =
            selectedBrandId.isEmpty || product.brandId == selectedBrandId;
        final matchesCategory = selectedCategoryId.isEmpty ||
            product.categoryId == selectedCategoryId;

        // Return true if any of the conditions match
        return matchesProductName && matchesBrand && matchesCategory;
      }).toList();
    });
  }

  // void _filterProducts() {
  //   setState(() {
  //     filteredProducts = allProducts.where((product) {
  //       return searchController.text.isEmpty ||
  //           product.productName
  //               .toLowerCase()
  //               .contains(searchController.text.toLowerCase());
  //     }).toList();
  //   });
  // }

  List<Brand> brandList = [];
  List<Category> categoryList = [];

  void _addProduct() {
    final TextEditingController skuController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController discountController = TextEditingController();
    final TextEditingController selectedCategoryName = TextEditingController();
    final TextEditingController selectedBrandName = TextEditingController();
    final TextEditingController selectedCategoryId = TextEditingController();
    final TextEditingController selectedBrandId = TextEditingController();
    List<String> brands = [];
    List<String> brandsIds = [];
    for (int i = 0; i < brandList.length; i++) {
      brands.add(brandList[i].brandName.toString());
      brandsIds.add(brandList[i].brandId.toString());
    }
    List<String> categories = [];
    List<String> categoriesIds = [];
    for (int i = 0; i < categoryList.length; i++) {
      categories.add(categoryList[i].categoryName.toString());
      categoriesIds.add(categoryList[i].categoryId.toString());
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextStyles.textHeadings(
              textValue: 'Add New Product',
              textSize: 20,
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
                  controller: nameController,
                  label: 'Product Name*',
                  width: 250,
                  hint: 'Enter product name',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: quantityController,
                  label: 'Quantity(optional)',
                  width: 250,
                  hint: 'Enter qty of product',
                  textInputType: TextInputType.number,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: priceController,
                  label: 'Price',
                  width: 250,
                  hint: 'Enter price',
                  textInputType: TextInputType.number,
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: discountController,
                  label: 'Discount',
                  width: 250,
                  hint: 'Enter price',
                  textInputType: TextInputType.number,
                ),
                DropDown(
                  width: 250,
                  borderColor: AppColors.white,
                  borderRadius: 10,
                  hint: "Brand(optional)",
                  selectedValue: selectedBrandName.text,
                  items: brands,
                  onChanged: (value) {
                    int index = brands.indexOf(value);

                    setState(() {
                      selectedBrandId.text = brandsIds[index];
                      _filterProducts(); // Trigger filter logic
                    });
                  },
                ),
                DropDown(
                  width: 250,
                  borderColor: AppColors.white,
                  selectedValue: selectedCategoryName.text,
                  borderRadius: 10,
                  hint: "Category*",
                  items: categories,
                  onChanged: (value) {
                    int index = categories.indexOf(value);

                    setState(() {
                      selectedCategoryId.text = categoriesIds[index];
                      _filterProducts(); // Trigger filter logic
                    });
                  },
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
                if (double.parse(discountController.text) > 100) {
                  MSG.warningSnackBar(
                      context, "Discount cannot be greater than 100.");
                } else {
                  setState(() {
                    productBloc.add(AddProductEvent(
                        nameController.text,
                        double.parse(priceController.text),
                        skuController.text,
                        selectedCategoryId.text,
                        selectedBrandId.text,
                        double.parse(discountController.text)));
                  });
                }
                Navigator.of(context).pop();
              },
              text: "Add",
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

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: AppColors.darkModeBackgroundContainerColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (!isSmallScreen)
                        TextStyles.textHeadings(
                          textValue: "Products",
                          textSize: 25,
                          textColor: AppColors.white,
                        ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomTextFormField(
                          controller: searchController,
                          hint: 'Search',
                          label: '',
                          onChanged: (val) {
                            _filterProducts();
                          },
                          widget: IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: AppColors.white,
                            ),
                            onPressed: () {
                              // Trigger search logic
                              _filterProducts();
                            },
                          ),
                          width: 250,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: GestureDetector(
                    onTap: _addProduct,
                    child: Container(
                      width: 150,
                      height: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.purple),
                      child: const Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: AppColors.white,
                            ),
                            CustomText(
                              text: "  Product",
                              size: 18,
                              color: AppColors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: BlocConsumer<ProductBloc, ProductState>(
                bloc: productBloc,
                listener: (context, state) {
                  if (state is GetProductSuccessState) {
                    allProducts = state.productList;
                    brandList = state.brandList;
                    categoryList = state.categoryList;
                    print(categoryList);
                    print(brandList);
                    filteredProducts = List.from(allProducts);
                  }
                },
                builder: (context, state) {
                  if (state is ProductLoadingState) {
                    return const Center(child: AppLoadingPage(''));
                  }
                  if (state is GetProductSuccessState) {
                    List<String> brands = [];
                    List<String> ids = [];
                    for (int i = 0; i < brandList.length; i++) {
                      brands.add(brandList[i].brandName.toString());
                      ids.add(brandList[i].brandId.toString());
                    }
                    List<String> categories = [];
                    List<String> categoriesIds = [];
                    for (int i = 0; i < categoryList.length; i++) {
                      categories.add(categoryList[i].categoryName.toString());
                      categoriesIds.add(categoryList[i].categoryId.toString());
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            DropDown(
                              width: 250,
                              borderColor: AppColors.white,
                              borderRadius: 10,
                              hint: "Brands",
                              selectedValue: selectedBrand,
                              items: brands,
                              onChanged: (value) {
                                int index = brands.indexOf(value);

                                setState(() {
                                  selectedBrandId = brandList[index].brandId!;
                                  _filterProducts(); // Trigger filter logic
                                });
                              },
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            DropDown(
                              width: 250,
                              borderColor: AppColors.white,
                              selectedValue: selectedCategory,
                              borderRadius: 10,
                              hint: "Category*",
                              items: categories,
                              onChanged: (value) {
                                int index = categories.indexOf(value);

                                setState(() {
                                  selectedCategoryId =
                                      categoryList[index].categoryId!;
                                  _filterProducts(); // Trigger filter logic
                                });
                              },
                            ),
                            // Expanded(
                            //   child: DropDown(
                            //     width: 250,
                            //     borderColor: AppColors.white,
                            //     borderRadius: 20,
                            //     hint: "Brand",
                            //     selectedValue: selectedBrand,
                            //     items: const ['Brand', 'Brand A', 'Brand B'],
                            //     onChanged: (value) {
                            //       setState(() {
                            //         selectedBrand = value!;
                            //         _filterProducts(); // Trigger filter logic
                            //       });
                            //     },
                            //   ),
                            // ),
                            // Expanded(
                            //   child: DropDown(
                            //     width: 250,
                            //     borderColor: AppColors.white,
                            //     selectedValue: selectedCategory,
                            //     borderRadius: 20,
                            //     hint: "Category",
                            //     items: const [
                            //       'Category',
                            //       'Category A',
                            //       'Category B'
                            //     ],
                            //     onChanged: (value) {
                            //       setState(() {
                            //         selectedCategory = value!;
                            //         _filterProducts(); // Trigger filter logic
                            //       });
                            //     },
                            //   ),
                            // ),
                          ],
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        if (filteredProducts.isEmpty)
                          const Center(
                              child: CustomText(
                            text: 'No products found.',
                            color: AppColors.white,
                          )),
                        if (filteredProducts.isNotEmpty)
                          Expanded(
                              child: ProductTableScreen(
                            productList: filteredProducts,
                            brandList: brandList,
                            categoryList: categoryList,
                          )),
                      ],
                    );
                  }
                  return const Center(
                      child: CustomText(text: 'No products found.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class MainProductScreen extends StatefulWidget {
//   const MainProductScreen({super.key});
//
//   @override
//   State<MainProductScreen> createState() => _MainProductScreenState();
// }
//
// class _MainProductScreenState extends State<MainProductScreen> {
//   // final searchTextEditingController = TextEditingController();
//   // String selectedBrand = 'Brand';
//   // String selectedCategory = 'Category';
//
//   // List<Map<String, dynamic>> allProducts = []; // Holds all products
//   // List<Map<String, dynamic>> filteredProducts = []; // Holds filtered products
//
//   @override
//   void initState() {
//     super.initState();
//     // Sample data
//   }
//
//
//   // Simulated method to add a new product
//
//   @override
//   Widget build(BuildContext context) {
//     final isSmallScreen = MediaQuery.of(context).size.width < 600;
//
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackgroundColor,
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               // Search and Title Row
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Row(
//                       children: [
//                         if (!isSmallScreen)
//                           TextStyles.textHeadings(
//                             textValue: "Products",
//                             textSize: 25,
//                             textColor: AppColors.white,
//                           ),
//                         const SizedBox(width: 20),
//                         Expanded(
//                           child: CustomTextFormField(
//                             controller: searchTextEditingController,
//                             hint: 'Search',
//                             label: '',
//                             onChanged: (val){
//                               _filterProducts();
//                             },
//                             widget: IconButton(
//                               icon: const Icon(
//                                 Icons.search,
//                                 color: AppColors.white,
//                               ),
//                               onPressed: () {
//                                 // Trigger search logic
//                                 _filterProducts();
//                               },
//                             ),
//                             width: 250,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: DropDown(
//                             width: 150,
//                             borderColor: AppColors.white,
//                             borderRadius: 20,
//                             hint: "Brand",
//                             selectedValue: selectedBrand,
//                             items: const ['Brand', 'Brand A', 'Brand B'],
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedBrand = value!;
//                                 _filterProducts(); // Trigger filter logic
//                               });
//                             },
//                           ),
//                         ),
//                         Expanded(
//                           child: DropDown(
//                             width: 150,
//                             borderColor: AppColors.white,
//                             selectedValue: selectedCategory,
//                             borderRadius: 20,
//                             hint: "Category",
//                             items: const [
//                               'Category',
//                               'Category A',
//                               'Category B'
//                             ],
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedCategory = value!;
//                                 _filterProducts(); // Trigger filter logic
//                               });
//                             },
//                           ),
//                         ),
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.only(top: 20.0),
//                             child: GestureDetector(
//                               onTap: _addProduct,
//                               child: Container(
//                                 width: 150,
//                                 height: 45,
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20),
//                                     color: AppColors.purple),
//                                 child: const Padding(
//                                   padding: EdgeInsets.all(0.0),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.add,
//                                         color: AppColors.white,
//                                       ),
//                                       CustomText(
//                                         text: "  Product",
//                                         size: 18,
//                                         color: AppColors.white,
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//               const SizedBox(height: 20),
//               ProductTableScreen(products: filteredProducts)
//               // Pass filtered products
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
