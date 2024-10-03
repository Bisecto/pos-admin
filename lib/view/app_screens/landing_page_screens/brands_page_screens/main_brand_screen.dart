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
import 'brand_table.dart';

class MainBrandScreen extends StatefulWidget {
  const MainBrandScreen({super.key});

  @override
  State<MainBrandScreen> createState() => _MainBrandScreenState();
}

class _MainBrandScreenState extends State<MainBrandScreen> {
  final searchTextEditingController = TextEditingController();

  List<Map<String, dynamic>> allBrands = []; // Holds all products
  List<Map<String, dynamic>> filteredBrands = []; // Holds filtered products

  @override
  void initState() {
    super.initState();
    // Sample data
    allBrands = List.generate(
        15,
        (index) => {
              'index': index,
              'brandId': '10$index',
              'brandName': 'Brand 10239$index',
            });
    filteredBrands = allBrands; // Initially display all products
  }

  void _filterBrands() {
    setState(() {
      filteredBrands = allBrands.where((product) {
        // Apply search query
        bool matchesSearch = searchTextEditingController.text.isEmpty ||
            product['name']
                .toLowerCase()
                .contains(searchTextEditingController.text.toLowerCase());

        // Apply brand and category filter

        return matchesSearch;
      }).toList();
    });
  }

  // Simulated method to add a new product
  void _addBrand() {
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
              textValue: 'Add New Brand',
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
                  filteredBrands.add({
                    "id": filteredBrands.length + 101, // Auto-increment ID
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
                            textValue: "Brands",
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
                              _filterBrands();
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
                      onTap: _addBrand,
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
                                text: "  Brand",
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
              BrandTableScreen(brands: filteredBrands)
            ],
          ),
        ),
      ),
    );
  }
}
