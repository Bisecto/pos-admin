import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_admin/bloc/auth_bloc/auth_bloc.dart';
import 'package:pos_admin/bloc/category_bloc/category_bloc.dart';
import 'package:pos_admin/model/category_model.dart';
import 'package:pos_admin/model/tenant_model.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/utills/app_utils.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/products_page_screens/product_table.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_button.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../res/app_colors.dart';
import '../../../important_pages/app_loading_page.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../widgets/app_custom_text.dart';

import 'package:flutter/material.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/products_page_screens/product_table.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../res/app_colors.dart';
import '../../../widgets/app_custom_text.dart';
import 'category_table.dart';

class MainCategoryScreen extends StatefulWidget {
  UserModel userModel;
   MainCategoryScreen({super.key,required this.userModel});

  @override
  State<MainCategoryScreen> createState() => _MainCategoryScreenState();
}

class _MainCategoryScreenState extends State<MainCategoryScreen> {
  final searchTextEditingController = TextEditingController();

  List<Category> allCategorys = []; // Holds all products
  List<Category> filteredCategorys = []; // Holds filtered products
  CategoryBloc categoryBloc = CategoryBloc();

  @override
  void initState() {
    categoryBloc.add(GetCategoryEvent(widget.userModel.tenantId));
    super.initState();
    // Sample data

    // allCategorys = List.generate(
    //     15,
    //     (index) => {
    //           'index': index,
    //           'categoryId': '10$index',
    //           'categoryName': 'Category 10239$index',
    //         });
    // filteredCategorys = allCategorys; // Initially display all products
  }

  void _filterCategorys() {
    print(12345);
    setState(() {
      filteredCategorys = allCategorys.where((category) {
        final matchesSearch = searchTextEditingController.text.isEmpty ||
            category.categoryName!
                .toLowerCase()
                .contains(searchTextEditingController.text.toLowerCase());

        return matchesSearch;
      }).toList();

      // Debug statement to check if filteredCategorys is being updated
      print("Filtered categories: ${filteredCategorys.length}dgdghb");
    });
  }

  void _addCategory() {
    final TextEditingController categoryNameController =
    TextEditingController();

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
                if (categoryNameController.text.isNotEmpty) {
                  categoryBloc.add(
                      AddCategoryEvent(categoryNameController.text.trim(),widget.userModel.tenantId));
                } else {
                  MSG.warningSnackBar(
                      context, "Category name cannot be empty.");
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
    final isSmallScreen = MediaQuery
        .of(context)
        .size
        .width < 600;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: BlocConsumer<CategoryBloc, CategoryState>(
          bloc: categoryBloc,
          listenWhen: (previous, current) =>
          current is CategoryLoadingState,
          buildWhen: (previous, current) => current is! CategoryLoadingState|| current is GetCategorySuccessState,
          listener: (context, state) {
            print(state);
            if (state is CategoryErrorState) {
              MSG.warningSnackBar(context, state.error);
              //Navigator.pop(context);
            }
          },
          builder: (context, state) {
            switch (state.runtimeType) {
            // case PostsFetchingState:
            //   return const Center(
            //     child: CircularProgressIndicator(),
            //   );
              case GetCategorySuccessState:
                final getCategories = state as GetCategorySuccessState;
                //print(getCategories.categoryList);
                allCategorys = getCategories.categoryList;
                filteredCategorys = allCategorys.where((category) {
                  final matchesSearch =
                      searchTextEditingController.text.isEmpty ||
                          category.categoryName!.toLowerCase().contains(
                              searchTextEditingController.text.toLowerCase());

                  return matchesSearch;
                }).toList();

                // Debug statement to check if filteredCategorys is being updated
                print("Filtered categories: ${filteredCategorys.length}dgdghb");
                print('All Categories: ${allCategorys.length}');
                print('Filtered Categories: ${filteredCategorys.length}');

                return Container(
                  //height: 200,
                  child: Padding(
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
                                        textValue: "Categories",
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

                              if(widget.userModel.addingEditingProductsDetails)

                                Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: GestureDetector(
                                  onTap: () {
                                    _addCategory();
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: AppColors.darkYellow,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(0.0),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add,
                                              color: AppColors.white),
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
                          if (getCategories.categoryList.isEmpty)
                            const Center(
                              child: CustomText(
                                text: "No categories have been added yet.",
                                weight: FontWeight.bold,
                                color: AppColors.white,
                                maxLines: 3,
                                size: 12,
                              ),
                            ),
                          if (getCategories.categoryList.isNotEmpty)

                            CategoryTableScreen(
                              categoryList:
                              filteredCategorys, userModel: widget.userModel, // Display filtered list
                            ),
                        ],
                      ),
                    ),
                  ),
                );

              case CategoryLoadingState || AddCategoryLoadingState:
                return const Center(
                  child: AppLoadingPage("Getting Categories..."),
                );
              default:
                return const Center(
                  child: AppLoadingPage("Getting Categories..."),
                );
            }
          }),
    );
  }
}
