import 'package:flutter/material.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/products_page_screens/product_table.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../res/app_colors.dart';
import '../../../widgets/app_custom_text.dart';

import 'package:flutter/material.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/products_page_screens/product_table.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../res/app_colors.dart';
import '../../../widgets/app_custom_text.dart';

class MainProductScreen extends StatefulWidget {
  const MainProductScreen({super.key});

  @override
  State<MainProductScreen> createState() => _MainProductScreenState();
}

class _MainProductScreenState extends State<MainProductScreen> {
  final searchTextEditingController = TextEditingController();
  String selectedBrand = 'Brand';
  String selectedCategory = 'Category';

  List<Map<String, dynamic>> allProducts = []; // Holds all products
  List<Map<String, dynamic>> filteredProducts = []; // Holds filtered products

  @override
  void initState() {
    super.initState();
    // Sample data
    allProducts = List.generate(15, (index) => {
      'id': index,
      'sku': '10239$index',
      'name': 'Product $index',
      'quantity': '10',
      'price': '199.99 Php',
      'location': 'Talavera',
      'brand': index % 2 == 0 ? 'Brand A' : 'Brand B',
      'category': index % 2 == 0 ? 'Category A' : 'Category B'
    });
    filteredProducts = allProducts; // Initially display all products
  }

  void _filterProducts() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        // Apply search query
        bool matchesSearch = searchTextEditingController.text.isEmpty ||
            product['name'].toLowerCase().contains(
                searchTextEditingController.text.toLowerCase());

        // Apply brand and category filter
        bool matchesBrand = selectedBrand == 'Brand' ||
            product['brand'] == selectedBrand;
        bool matchesCategory = selectedCategory == 'Category' ||
            product['category'] == selectedCategory;

        return matchesSearch && matchesBrand && matchesCategory;
      }).toList();
    });
  }

  // Simulated method to add a new product
  void _addProduct() {
    setState(() {
      int newProductId = allProducts.length + 1;
      allProducts.add({
        'id': newProductId,
        'sku': 'New1023$newProductId',
        'name': 'New Product $newProductId',
        'quantity': '5',
        'price': '299.99 Php',
        'location': 'Manila',
        'brand': 'Brand A',
        'category': 'Category A'
      });
      _filterProducts(); // Update displayed products
    });
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
                            textValue: "Products",
                            textSize: 25,
                            textColor: AppColors.white,
                          ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CustomTextFormField(
                            controller: searchTextEditingController,
                            hint: 'Search',
                            label: '',
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
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: DropDown(
                            width: 150,
                            borderColor: AppColors.white,
                            borderRadius: 20,
                            hint: "Brand",
                            selectedValue: selectedBrand,
                            items: const ['Brand', 'Brand A', 'Brand B'],
                            onChanged: (value) {
                              setState(() {
                                selectedBrand = value!;
                                _filterProducts(); // Trigger filter logic
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: DropDown(
                            width: 150,
                            borderColor: AppColors.white,
                            selectedValue: selectedCategory,
                            borderRadius: 20,
                            hint: "Category",
                            items: const ['Category', 'Category A', 'Category B'],
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                                _filterProducts(); // Trigger filter logic
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: Padding(
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
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              ProductTableScreen(products: filteredProducts) // Pass filtered products
            ],
          ),
        ),
      ),
    );
  }
}
