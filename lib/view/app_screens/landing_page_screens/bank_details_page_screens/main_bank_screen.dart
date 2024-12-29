import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_admin/model/user_model.dart';

import 'package:pos_admin/view/widgets/form_button.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../bloc/bank_bloc/bank_bloc.dart';
import '../../../../model/bank_model.dart';
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
import 'bank_table.dart';

class MainBankScreen extends StatefulWidget {
  final UserModel userModel;

  const MainBankScreen({super.key, required this.userModel});

  @override
  State<MainBankScreen> createState() => _MainBankScreenState();
}

class _MainBankScreenState extends State<MainBankScreen> {
  final searchTextEditingController = TextEditingController();

  List<Bank> allBanks = []; // Holds all products
  List<Bank> filteredBanks = []; // Holds filtered products
  BankBloc bankBloc = BankBloc();

  @override
  void initState() {
    bankBloc.add(GetBankEvent(widget.userModel.tenantId));
    super.initState();
  }

  void _filterBanks() {
    print(12345);
    setState(() {
      filteredBanks = allBanks.where((bank) {
        final matchesSearch = searchTextEditingController.text.isEmpty ||
            bank.bankName!
                .toLowerCase()
                .contains(searchTextEditingController.text.toLowerCase());

        return matchesSearch;
      }).toList();

      // Debug statement to check if filteredBanks is being updated
      print("Filtered banks: ${filteredBanks.length}dgdghb");
    });
  }

  void _addBank() {
    final TextEditingController bankNameController = TextEditingController();
    final TextEditingController accNameController = TextEditingController();
    final TextEditingController accNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextStyles.textHeadings(
              textValue: 'Add New Bank',
              textSize: 20,
              textColor: AppColors.white),
          backgroundColor: AppColors.darkModeBackgroundContainerColor,
          content: SingleChildScrollView(
            child: Column(
              children: [
                CustomTextFormField(
                  controller: bankNameController,
                  label: 'Bank Name',
                  width: 250,
                  hint: 'Enter bank name',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: accNameController,
                  label: 'Account Name',
                  width: 250,
                  hint: 'Enter account name',
                ),
                SizedBox(
                  height: 10,
                ),
                CustomTextFormField(
                  controller: accNumberController,
                  label: 'Account Number',
                  width: 250,
                  maxLength: 10,
                  textInputType: TextInputType.number,
                  hint: 'Enter account number',
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
                if (bankNameController.text.isNotEmpty) {
                  bankBloc.add(AddBankEvent(
                    bankNameController.text.trim(),
                    widget.userModel.tenantId,
                    accNumberController.text,
                    accNameController.text,
                  ));
                } else {
                  MSG.warningSnackBar(context, "Bank name cannot be empty.");
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
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: BlocConsumer<BankBloc, BankState>(
          bloc: bankBloc,
          listenWhen: (previous, current) => current is BankLoadingState,
          buildWhen: (previous, current) =>
              current is! BankLoadingState || current is GetBankSuccessState,
          listener: (context, state) {
            print(state);
            if (state is BankErrorState) {
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
              case GetBankSuccessState:
                final getBanks = state as GetBankSuccessState;
                //print(getBanks.BankList);
                allBanks = getBanks.bankList;
                filteredBanks = allBanks.where((bank) {
                  final matchesSearch =
                      searchTextEditingController.text.isEmpty ||
                          bank.bankName!.toLowerCase().contains(
                              searchTextEditingController.text.toLowerCase());

                  return matchesSearch;
                }).toList();

                // Debug statement to check if filteredBanks is being updated
                print("Filtered banks: ${filteredBanks.length}dgdghb");
                print('All Banks: ${allBanks.length}');
                print('Filtered Banks: ${filteredBanks.length}');

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
                                        textValue: "Banks",
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
                                          _filterBanks();
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
                              if (allBanks.length == 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (widget.userModel.role.toLowerCase() ==
                                          'admin') {
                                        _addBank();
                                      } else {
                                        MSG.warningSnackBar(context,
                                            'You dont have any permission for this action');
                                      }
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
                                              text: "  Bank",
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
                          if (getBanks.bankList.isEmpty)
                            const Center(
                              child: CustomText(
                                text: "No Banks have been added yet.",
                                weight: FontWeight.bold,
                                color: AppColors.white,
                                maxLines: 3,
                                size: 12,
                              ),
                            ),
                          if (getBanks.bankList.isNotEmpty)
                            BankTableScreen(
                              bankList: filteredBanks,
                              userModel:
                                  widget.userModel, // Display filtered list
                            ),
                        ],
                      ),
                    ),
                  ),
                );

              case BankLoadingState || AddBankLoadingState:
                return const Center(
                  child: AppLoadingPage("Getting Banks..."),
                );
              default:
                return const Center(
                  child: AppLoadingPage("Getting Banks..."),
                );
            }
          }),
    );
  }
}
