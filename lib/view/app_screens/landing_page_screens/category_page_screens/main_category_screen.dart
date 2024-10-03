import 'package:flutter/material.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/products_page_screens/product_table.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_button.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../res/app_colors.dart';
import '../../../widgets/app_custom_text.dart';

import 'package:flutter/material.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/products_page_screens/product_table.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../res/app_colors.dart';
import '../../../widgets/app_custom_text.dart';
import 'category_table.dart';

class MainCategoryScreen extends StatefulWidget {
  const MainCategoryScreen({super.key});

  @override
  State<MainCategoryScreen> createState() => _MainCategoryScreenState();
}

class _MainCategoryScreenState extends State<MainCategoryScreen> {
  final searchTextEditingController = TextEditingController();

  List<Map<String, dynamic>> allCategorys = []; // Holds all products
  List<Map<String, dynamic>> filteredCategorys = []; // Holds filtered products

  @override
  void initState() {
    super.initState();
    // Sample data
    allCategorys = List.generate(
        15,
        (index) => {
              'index': index,
              'categoryId': '10$index',
              'categoryName': 'Category 10239$index',
            });
    filteredCategorys = allCategorys; // Initially display all products
  }

  void _filterCategorys() {
    setState(() {
      filteredCategorys = allCategorys.where((product) {
        // Apply search query
        bool matchesSearch = searchTextEditingController.text.isEmpty ||
            product['name']
                .toLowerCase()
                .contains(searchTextEditingController.text.toLowerCase());

        // Apply Category and category filter

        return matchesSearch;
      }).toList();
    });
  }

  // Simulated method to add a new product
  void _addCategory() {
    final TextEditingController skuController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextStyles.textHeadings(
              textValue: 'Add New Category',
              textSize: 20,
              textColor: AppColors.white),
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextFormField(
                  controller: skuController,
                  label: 'SKU',
                  width: 250,
                  hint: 'Enter sku',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: nameController,
                  label: 'Product Name',
                  width: 250,
                  hint: 'Enter product name',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: quantityController,
                  label: 'Quantity',
                  width: 250,
                  hint: 'Enter product name',
                  textInputType: TextInputType.number,
                ),
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
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                    controller: locationController,
                    label: 'Location',
                    width: 250,
                    hint: 'Enter product name'),
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
                setState(() {
                  filteredCategorys.add({
                    "id": filteredCategorys.length + 101, // Auto-increment ID
                    "sku": skuController.text,
                    "name": nameController.text,
                    "quantity": int.tryParse(quantityController.text) ?? 0,
                    "price": priceController.text,
                    "location": locationController.text
                  });
                });
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
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Search and Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (!isSmallScreen)
                          TextStyles.textHeadings(
                            textValue: "Categorys",
                            textSize: 25,
                            textColor: AppColors.white,
                          ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CustomTextFormField(
                            controller: searchTextEditingController,
                            hint: 'Search',
                            label: '',
                            onChanged: (val) {
                              _filterCategorys();
                            },
                            widget: const Icon(
                              Icons.search,
                              color: AppColors.white,
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
                      onTap: _addCategory,
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
                                text: "  Category",
                                size: 18,
                                color: AppColors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CategoryTableScreen( categorys: filteredCategorys,)
            ],
          ),
        ),
      ),
    );
  }
}
