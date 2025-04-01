import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/printer_setup_screens/printer_table.dart';

import 'package:pos_admin/view/widgets/form_button.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../bloc/printer_bloc/printer_bloc.dart';
import '../../../../model/printer_model.dart';
import '../../../../res/app_colors.dart';
import '../../../important_pages/app_loading_page.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../widgets/app_custom_text.dart';

class MainPrinterScreen extends StatefulWidget {
  UserModel userModel;

  MainPrinterScreen({super.key, required this.userModel});

  @override
  State<MainPrinterScreen> createState() => _MainPrinterScreenState();
}

class _MainPrinterScreenState extends State<MainPrinterScreen> {
  final searchTextEditingController = TextEditingController();

  List<PrinterModel> allPrinters = []; // Holds all products
  List<PrinterModel> filteredPrinters = []; // Holds filtered products
  PrinterBloc printerBloc = PrinterBloc();

  @override
  void initState() {
    printerBloc.add(GetPrinterEvent(widget.userModel.tenantId));
    super.initState();
    // Sample data

    // allPrinters = List.generate(
    //     15,
    //     (index) => {
    //           'index': index,
    //           'printerId': '10$index',
    //           'printerName': 'Printer 10239$index',
    //         });
    // filteredPrinters = allPrinters; // Initially display all products
  }

  void _filterPrinters() {
    print(12345);
    setState(() {
      filteredPrinters = allPrinters.where((printer) {
        final matchesSearch = searchTextEditingController.text.isEmpty ||
            printer.printerName!
                .toLowerCase()
                .contains(searchTextEditingController.text.toLowerCase());

        return matchesSearch;
      }).toList();

      // Debug statement to check if filteredPrinters is being updated
      print("Filtered printers: ${filteredPrinters.length}dgdghb");
    });
  }

  void _addPrinter() {
    bool isPrinterUsb =
        false; // Keep this inside the function to avoid resetting global state

    final TextEditingController printerNameController = TextEditingController();
    final TextEditingController printerPortController = TextEditingController();
    final TextEditingController printerIpController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Add StatefulBuilder to manage state inside the dialog
          builder: (context, setState) {
            return AlertDialog(
              title: TextStyles.textHeadings(
                  textValue: 'Add New Printer',
                  textSize: 20,
                  textColor: AppColors.white),
              backgroundColor: AppColors.darkModeBackgroundContainerColor,
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: printerNameController,
                      label: 'Printer Name',
                      width: 250,
                      hint: 'Enter printer name',
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: CustomText(
                            text: 'Is Printer USB?',
                            size: 15,
                            color: AppColors.white,
                            weight: FontWeight.bold,
                          ),
                        ),
                        Switch(
                          value: isPrinterUsb,
                          onChanged: (value) {
                            setState(() {
                              // This setState is from StatefulBuilder, not the main widget
                              isPrinterUsb = value;
                            });
                          },
                        ),
                      ],
                    ),
                    CustomTextFormField(
                      controller: printerIpController,
                      label: isPrinterUsb ? 'Printer VendorId' : 'Printer IP',
                      width: 250,
                      hint: isPrinterUsb
                          ? 'Enter printer VendorId'
                          : 'Enter printer IP address',
                    ),
                    SizedBox(height: 10),
                    CustomTextFormField(
                      controller: printerPortController,
                      label:
                          isPrinterUsb ? 'Printer ProductId' : 'Printer Port',
                      width: 250,
                      textInputType:isPrinterUsb? TextInputType.text:TextInputType.number,
                      hint: isPrinterUsb
                          ? 'Enter printer ProductId'
                          : 'Enter printer port',
                    ),
                    SizedBox(height: 10),
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
                    if (printerNameController.text.isNotEmpty &&
                        printerIpController.text.isNotEmpty &&
                        printerPortController.text.isNotEmpty) {
                      printerBloc.add(AddPrinterEvent(
                        printerNameController.text.trim(),
                        widget.userModel.tenantId,
                        printerIpController.text,
                        printerPortController.text,
                        'thermal',
                        isPrinterUsb,
                        // Now correctly passes the updated value
                        widget.userModel,
                      ));
                      Navigator.of(context).pop();
                    } else {
                      MSG.warningSnackBar(
                          context, "All fields must be filled.");
                    }
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: BlocConsumer<PrinterBloc, PrinterState>(
          bloc: printerBloc,
          listenWhen: (previous, current) => current is PrinterLoadingState,
          buildWhen: (previous, current) =>
              current is! PrinterLoadingState ||
              current is GetPrinterSuccessState,
          listener: (context, state) {
            print(state);
            if (state is PrinterErrorState) {
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
              case GetPrinterSuccessState:
                final getPrinters = state as GetPrinterSuccessState;
                //print(getPrinters.printerList);
                allPrinters = getPrinters.printerList;
                filteredPrinters = allPrinters.where((printer) {
                  final matchesSearch =
                      searchTextEditingController.text.isEmpty ||
                          printer.printerName!.toLowerCase().contains(
                              searchTextEditingController.text.toLowerCase());

                  return matchesSearch;
                }).toList();

                // Debug statement to check if filteredPrinters is being updated
                print("Filtered printers: ${filteredPrinters.length}dgdghb");
                print('All Printers: ${allPrinters.length}');
                print('Filtered Printers: ${filteredPrinters.length}');

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
                                        textValue: "Printers",
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
                                          _filterPrinters();
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
                              if (widget.userModel.addingEditingPrinters) ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      printerBloc.add(GetPrinterEvent(widget.userModel.tenantId));
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
                                            Icon(Icons.refresh,
                                                color: AppColors.white),
                                            CustomText(
                                              text: "  Refresh",
                                              size: 18,
                                              color: AppColors.white,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ) ,  SizedBox(width: 50,)    ,                         Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      _addPrinter();
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
                                              text: "  Printer",
                                              size: 18,
                                              color: AppColors.white,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (getPrinters.printerList.isEmpty)
                            const Center(
                              child: CustomText(
                                text: "No printers have been added yet.",
                                weight: FontWeight.bold,
                                color: AppColors.white,
                                maxLines: 3,
                                size: 12,
                              ),
                            ),
                          if (getPrinters.printerList.isNotEmpty)
                            PrinterTableScreen(
                              printerList: filteredPrinters,
                              userModel:
                                  widget.userModel, // Display filtered list
                            ),
                        ],
                      ),
                    ),
                  ),
                );

              case PrinterLoadingState || AddPrinterLoadingState:
                return const Center(
                  child: AppLoadingPage("Getting Printers..."),
                );
              default:
                return const Center(
                  child: AppLoadingPage("Getting Printers..."),
                );
            }
          }),
    );
  }
}
