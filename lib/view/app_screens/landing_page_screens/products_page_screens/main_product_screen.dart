import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
                            // Trigger search logic here
                            print(
                                'Searching for: ${searchTextEditingController.text}');
                          },
                        ),
                        width: 250,
                      ),
                    ),
                  ],
                )),
                Expanded(
                    child: Row(
                  children: [
                    Expanded(
                      child: DropDown(
                        width: 150,
                        borderColor: AppColors.white,
                        borderRadius: 20,
                        hint: "Brand",
                        selectedValue: 'Brand',
                        items: const ['Brand A', 'Brand B'],
                        onChanged: (value) {
                          print('Selected: $value');
                        },
                      ),
                    ),
                    Expanded(
                      child: DropDown(
                        width: 150,
                        borderColor: AppColors.white,
                        selectedValue: 'Category',
                        borderRadius: 20,
                        hint: "Category",
                        items: const ['Category A', 'Category B'],
                        onChanged: (value) {
                          print('Selected: $value');
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
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
                                CustomText(text: "  Product",size: 18,color: AppColors.white,)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ))
              ],
            ),
            const SizedBox(height: 10),
            // Filter Row (Dropdown)
          ],
        ),
      ),
    );
  }
}
