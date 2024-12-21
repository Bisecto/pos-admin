import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_admin/model/category_model.dart';
import 'package:pos_admin/model/tenant_model.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/tables_page_screen/list_table.dart';
import 'package:pos_admin/view/widgets/drop_down.dart';
import 'package:pos_admin/view/widgets/form_button.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../model/brand_model.dart';
import '../../../../model/user_model.dart';
import '../../../../res/app_colors.dart';
import '../../../widgets/app_custom_text.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_admin/bloc/table_bloc/table_bloc.dart';
import 'package:pos_admin/model/table_model.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../important_pages/app_loading_page.dart';

class MainTableScreen extends StatefulWidget {
  UserModel userModel;
final TenantModel tenantModel;
  MainTableScreen({super.key, required this.userModel, required this.tenantModel});

  @override
  State<MainTableScreen> createState() => _MainTableScreenState();
}

class _MainTableScreenState extends State<MainTableScreen> {
  final searchController = TextEditingController();
  List<TableModel> allTables = [];
  List<TableModel> filteredTables = [];
  TableBloc tableBloc = TableBloc();

  @override
  void initState() {
    tableBloc.add(GetTableEvent(widget.userModel.tenantId));
    super.initState();
  }

  void _filterTables() {
    setState(() {
      filteredTables = allTables.where((table) {
        final searchQuery = searchController.text.toLowerCase();

        // Check if the search query matches the table name, brand name, or category name
        final matchesTableName =
            table.tableName.toLowerCase().contains(searchQuery) ?? false;

        // Return true if any of the conditions match
        return matchesTableName;
      }).toList();
    });
  }

  void _clearFilter() {
    setState(() {
      searchController.clear();
      print(1234567);
    });
    _filterTables();
  }

  void _addTable() {
    final TextEditingController nameController = TextEditingController();
    nameController.text = "T${allTables.length + 1}";
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text(
                'Add New Table',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              backgroundColor: Colors.grey[900],
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: nameController,
                      label: 'Table Name*',
                      width: 250,
                      hint: 'Enter table name',
                      enabled: false,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FormButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          bgColor: AppColors.red,
                          textColor: AppColors.white,
                          width: 140,
                          text: "Discard",
                          iconWidget: Icons.clear,
                          borderRadius: 20,
                        ),
                        FormButton(
                          onPressed: () {
                            if (nameController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Table Name is required.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              setState(() {
                                // Add your table logic here.
                                tableBloc.add(AddTableEvent(nameController.text,
                                    widget.userModel.tenantId));
                              });
                              Navigator.of(context).pop();
                            }
                          },
                          text: "Add",
                          iconWidget: Icons.add,
                          bgColor: AppColors.green,
                          textColor: AppColors.white,
                          width: 140,
                          borderRadius: 20,
                        )
                      ],
                    ),
                  ],
                ),
              ),
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
                          textValue: "Tables",
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
                            _filterTables();
                          },
                          widget: IconButton(
                            icon: const Icon(
                              Icons.search,
                              color: AppColors.white,
                            ),
                            onPressed: () {
                              // Trigger search logic
                              _filterTables();
                            },
                          ),
                          width: 250,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0,left: 10),
                  child: GestureDetector(
                    onTap: (){
                      tableBloc.add(GetTableEvent(widget.userModel.tenantId));
                    },
                    child: Container(
                      width: 100,
                      height: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.darkYellow),
                      child: const Padding(
                        padding: EdgeInsets.all(0.0),
                        child: Center(
                          child: CustomText(
                            text: "Refresh",
                            size: 18,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 20.0,left: 10),
                  child: GestureDetector(
                    onTap: _addTable,
                    child: Container(
                      width: 150,
                      height: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.darkYellow),
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
                              text: "  Table",
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
              child: BlocConsumer<TableBloc, TableState>(
                bloc: tableBloc,
                listener: (context, state) {
                  if (state is GetTableSuccessState) {
                    allTables = state.tableList;
                    filteredTables = List.from(allTables);
                  }
                },
                builder: (context, state) {
                  if (state is TableLoadingState) {
                    return const Center(child: AppLoadingPage(''));
                  }
                  if (state is GetTableSuccessState) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        if (filteredTables.isEmpty)
                          const Center(
                              child: CustomText(
                            text: 'No tables found.',
                            color: AppColors.white,
                          )),
                        if (filteredTables.isNotEmpty)
                          Expanded(
                              child: ListTable(
                            tableList: filteredTables, userModel: widget.userModel, tenantModel: widget.tenantModel,

                            //userModel: widget.userModel,
                          )),
                      ],
                    );
                  }
                  return const Center(
                      child: CustomText(text: 'No tables found.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
