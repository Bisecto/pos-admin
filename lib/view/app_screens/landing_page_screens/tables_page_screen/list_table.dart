import 'package:flutter/material.dart';
import 'package:pos_admin/model/table_model.dart';
import '../../../../model/tenant_model.dart';
import '../../../../model/user_model.dart';
import '../../../../utills/app_navigator.dart';
import '../../../widgets/app_custom_text.dart';
import '../../../../res/app_colors.dart';
import 'order/table_order_page.dart';

class ListTable extends StatefulWidget {
  final List<TableModel> tableList;
final   UserModel userModel;
 final  TenantModel tenantModel;
  ListTable({required this.tableList, required this.userModel, required this.tenantModel});

  @override
  _ListTableState createState() => _ListTableState();
}

class _ListTableState extends State<ListTable> {
  int rowsPerPage = 10;
  int currentPage = 1;
  int get totalItems => widget.tableList.length;

  List<TableModel> get paginatedTables {
    final start = (currentPage - 1) * rowsPerPage;
    final end = start + rowsPerPage;
    return widget.tableList.sublist(
        start, end > widget.tableList.length ? widget.tableList.length : end);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 200,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of items per row
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 3, // Aspect ratio for each grid item
              ),
              itemCount: widget.tableList.length,
              itemBuilder: (context, index) {
                final table = widget.tableList[index];
                return GestureDetector(
                  onTap: (){
                    AppNavigator.pushAndStackPage(context,
                        page: TableOrderPage(
                          tableModel: table,
                          userModel: widget.userModel,
                          tableList: widget.tableList,
                          tenantModel: widget.tenantModel,
                        ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:table.activity.isActive?AppColors.darkYellow: AppColors.darkModeBackgroundContainerColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white),
                    ),
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          table.tableName,
                          style:  const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if(table.activity.isActive)
                        Text(
                          "${table.activity.attendantName}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: List.generate(
          //       (totalItems / rowsPerPage).ceil(),
          //           (index) => GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             currentPage = index + 1;
          //           });
          //         },
          //         child: Container(
          //           margin: const EdgeInsets.symmetric(horizontal: 4.0),
          //           padding: const EdgeInsets.all(8.0),
          //           decoration: BoxDecoration(
          //             color: currentPage == (index + 1)
          //                 ? Colors.purple
          //                 : Colors.white,
          //             shape: BoxShape.circle,
          //           ),
          //           child: Text(
          //             '${index + 1}',
          //             style: TextStyle(
          //               color: currentPage == (index + 1)
          //                   ? Colors.white
          //                   : Colors.black,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
