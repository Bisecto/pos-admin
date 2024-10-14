import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_admin/model/user_model.dart';

import 'package:pos_admin/view/widgets/form_button.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../bloc/brand_bloc/brand_bloc.dart';
import '../../../../model/brand_model.dart';
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
import 'brand_table.dart';

class MainBrandScreen extends StatefulWidget {
  final UserModel userModel;
  const MainBrandScreen({super.key,required this.userModel});

  @override
  State<MainBrandScreen> createState() => _MainBrandScreenState();
}

class _MainBrandScreenState extends State<MainBrandScreen> {
  final searchTextEditingController = TextEditingController();

  List<Brand> allBrands = []; // Holds all products
  List<Brand> filteredBrands = []; // Holds filtered products
  BrandBloc brandBloc = BrandBloc();

  @override
  void initState() {
    brandBloc.add(GetBrandEvent(widget.userModel.tenantId));
    super.initState();

  }

  void _filterBrands() {
    print(12345);
    setState(() {
      filteredBrands = allBrands.where((brand) {
        final matchesSearch = searchTextEditingController.text.isEmpty ||
            brand.brandName!
                .toLowerCase()
                .contains(searchTextEditingController.text.toLowerCase());

        return matchesSearch;
      }).toList();

      // Debug statement to check if filteredBrands is being updated
      print("Filtered categories: ${filteredBrands.length}dgdghb");
    });
  }

  void _addBrand() {
    final TextEditingController brandNameController =
    TextEditingController();

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
                  controller: brandNameController,
                  label: 'Brand Name',
                  width: 250,
                  hint: 'Enter brand name',
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
                if (brandNameController.text.isNotEmpty) {
                  brandBloc.add(
                      AddBrandEvent(brandNameController.text.trim(),widget.userModel.tenantId));
                } else {
                  MSG.warningSnackBar(
                      context, "Brand name cannot be empty.");
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
      body: BlocConsumer<BrandBloc, BrandState>(
          bloc: brandBloc,
          listenWhen: (previous, current) =>
          current is BrandLoadingState,
          buildWhen: (previous, current) => current is! BrandLoadingState|| current is GetBrandSuccessState,
          listener: (context, state) {
            print(state);
            if (state is BrandErrorState) {
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
              case GetBrandSuccessState:
                final getCategories = state as GetBrandSuccessState;
                //print(getCategories.BrandList);
                allBrands = getCategories.brandList;
                filteredBrands = allBrands.where((brand) {
                  final matchesSearch =
                      searchTextEditingController.text.isEmpty ||
                          brand.brandName!.toLowerCase().contains(
                              searchTextEditingController.text.toLowerCase());

                  return matchesSearch;
                }).toList();

                // Debug statement to check if filteredBrands is being updated
                print("Filtered categories: ${filteredBrands.length}dgdghb");
                print('All Categories: ${allBrands.length}');
                print('Filtered Categories: ${filteredBrands.length}');

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
                                  onTap: () {
                                    _addBrand();
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: AppColors.purple,
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
                          if (getCategories.brandList.isEmpty)
                            const Center(
                              child: CustomText(
                                text: "No Brands have been added yet.",
                                weight: FontWeight.bold,
                                color: AppColors.white,
                                maxLines: 3,
                                size: 12,
                              ),
                            ),
                          if (getCategories.brandList.isNotEmpty)

                            BrandTableScreen(
                              brandList:
                              filteredBrands, userModel: widget.userModel, // Display filtered list
                            ),
                        ],
                      ),
                    ),
                  ),
                );

              case BrandLoadingState || AddBrandLoadingState:
                return const Center(
                  child: AppLoadingPage("Getting Brands..."),
                );
              default:
                return const Center(
                  child: AppLoadingPage("Getting Brands..."),
                );
            }
          }),
    );
  }
}
