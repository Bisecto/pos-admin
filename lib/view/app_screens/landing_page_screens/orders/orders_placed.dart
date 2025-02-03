import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pos_admin/model/user_model.dart';
import 'package:pos_admin/view/widgets/form_input.dart';
import '../../../../model/activity_model.dart';
import '../../../../model/log_model.dart';
import '../../../../model/order_model.dart';
import '../../../../model/printer_model.dart';
import '../../../../model/table_model.dart';
import '../../../../model/tenant_model.dart';
import '../../../../model/void_model.dart';
import '../../../../repository/log_actions.dart';
import '../../../../repository/voided_products_action.dart';
import '../../../../res/app_colors.dart';
import '../../../../res/app_enums.dart';
import '../../../../res/app_images.dart';
import '../../../../utills/app_utils.dart';
import '../../../../utills/enums/order_status_enums.dart';
import '../../../important_pages/dialog_box.dart';
import '../../../widgets/app_custom_text.dart';
import '../../../widgets/form_button.dart';

class OrderManagementPage extends StatefulWidget {
  final String tenantId;
  final TenantModel tenantModel;
  final UserModel userModel;

  OrderManagementPage(
      {required this.tenantId,
      required this.tenantModel,
      required this.userModel});

  @override
  _OrderManagementPageState createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> ordersStream;
  TextEditingController searchController = TextEditingController();
  DateTimeRange? dateRange;
  String searchQuery = '';
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredOrders = [];
  int currentPage = 0;
  final int rowsPerPage = 10; // Number of rows per page
  late int totalPages = 0;

  @override
  void initState() {
    super.initState();
    fetchPrinters();
    ordersStream = FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.tenantId)
        .collection('Orders')
        .orderBy('createdAt', descending: true)
        .snapshots();

    // Listen for updates in the orders stream
    ordersStream.listen((snapshot) {
      setState(() {
        filteredOrders = snapshot.docs;
        totalPages = (filteredOrders.length / rowsPerPage).ceil();
      });
    });
  }

  // Function to format dates
  String formatDate(Timestamp timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate());
  }

  // Function to pick date range
  Future<void> pickDateRange(BuildContext context) async {
    DateTimeRange? newRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: dateRange,
    );

    if (newRange != null) {
      setState(() {
        dateRange = newRange;
      });
    }
  }

  double calculateTax(double totalPrice, double taxRate) {
    return totalPrice * taxRate;
  }

  String getStatusText(int statusIndex) {
    return OrderStatus.values[statusIndex].toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    final startIndex = currentPage * rowsPerPage;
    final endIndex = startIndex + rowsPerPage < filteredOrders.length
        ? startIndex + rowsPerPage
        : filteredOrders.length;

    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Order Management'),
        // ),
        appBar: AppBar(
          title: TextStyles.textHeadings(
            textValue: 'Invoice',
            textColor: AppColors.white,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: AppColors.scaffoldBackgroundColor,
        body: Column(children: [
          // if(!widget.userModel.voidingTableOrder)
          //   Container(),
          // if(widget.userModel.voidingTableOrder)

          ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextFormField(
                    controller: searchController,
                    // decoration: InputDecoration(
                    //   labelText: 'Search by Order ID',
                    //   suffixIcon: IconButton(
                    //     icon: const Icon(Icons.clear),
                    //     onPressed: () {
                    //       setState(() {
                    //         searchController.clear();
                    //         searchQuery = '';
                    //       });
                    //     },
                    //   ),
                    //   border: const OutlineInputBorder(),
                    // ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    width: 250,
                    hint: 'Search by ID',
                    label: 'Search',
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => pickDateRange(context),
                  ),
                ],
              ),
            ),
            if (dateRange != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Filtered by date: ${DateFormat('yyyy/MM/dd').format(dateRange!.start)} - ${DateFormat('yyyy/MM/dd').format(dateRange!.end)}',
                  style: const TextStyle(color: AppColors.white),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      MaterialStateProperty.all<Color>(AppColors.darkYellow),
                  columns: [
                    // DataColumn(
                    //   label: Container(
                    //     padding: EdgeInsets.all(8.0),
                    //     child:
                    //         CustomText(text: 'Order No', color: AppColors.white),
                    //   ),
                    // ),DataColumn(
                    //   label: Container(
                    //     padding: EdgeInsets.all(8.0),
                    //     child:
                    //         CustomText(text: 'Sent To', color: AppColors.white),
                    //   ),
                    //),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: const CustomText(
                            text: 'Table Number', color: AppColors.white),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: const CustomText(
                            text: 'Ordered By', color: AppColors.white),
                      ),
                    ),

                    if (widget.userModel.viewFinance)
                      DataColumn(
                        label: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const CustomText(
                              text: 'Amount Paid', color: AppColors.white),
                        ),
                      ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: const CustomText(
                            text: 'Created At', color: AppColors.white),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: const CustomText(
                            text: 'Updated At', color: AppColors.white),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: const CustomText(
                            text: 'Status', color: AppColors.white),
                      ),
                    ),
                    DataColumn(
                      label: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: const CustomText(
                            text: 'Actions', color: AppColors.white),
                      ),
                    ),
                  ],
                  rows: filteredOrders
                      .sublist(startIndex, endIndex)
                      .map((orderDoc) {
                    final orderData = orderDoc.data();
                    final orderId = orderDoc.id;
                    final createdAt =
                        (orderData['createdAt'] as Timestamp).toDate();
                    final statusIndex = orderData['status'] as int;

                    return DataRow(
                      color: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                        return states.contains(MaterialState.selected)
                            ? Colors.purple.withOpacity(0.08)
                            : null; // Use default value for unselected rows
                      }),
                      cells: [
                        // DataCell(
                        //   Container(
                        //     padding: EdgeInsets.all(8.0),
                        //     child: CustomText(
                        //         text: orderData['orderCode'],
                        //         color: AppColors.white),
                        //   ),
                        // ),
                        // DataCell(
                        //   Container(
                        //     padding: EdgeInsets.all(8.0),
                        //     child: CustomText(
                        //         text: orderData['orderTo'],
                        //         color: AppColors.white),
                        //   ),
                        // ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder<String>(
                              future: getTableName(orderDoc['tableNo']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // Show a loading indicator
                                } else if (snapshot.hasError) {
                                  return const Text(
                                      'Error'); // Handle error case
                                } else {
                                  return CustomText(
                                    text: "Table ${snapshot.data}" ?? 'Settled',
                                    color: AppColors.white,
                                  );
                                }
                              },
                            ),
                          ),

                          // Container(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: CustomText(
                          //     text:
                          //         "Table ${AppUtils().extractNumbers(orderDoc['tableNo'].toString().isEmpty ? 'TTHHJH' : orderDoc['tableNo'].toString().substring(0, 3))}",
                          //     color: AppColors.white,
                          //     weight: FontWeight.bold,
                          //     size: 16,
                          //   ),
                          // ),
                        ),

                        DataCell(
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder<String>(
                              future: getUserFullName(orderData['createdBy']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // Show a loading indicator
                                } else if (snapshot.hasError) {
                                  return const Text(
                                      'Error'); // Handle error case
                                } else {
                                  return CustomText(
                                    text: snapshot.data ?? 'Unknown',
                                    color: AppColors.white,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        if (widget.userModel.viewFinance)
                          DataCell(
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomText(
                                  text: orderData['amountPaid'] ?? 'NAN',
                                  color: AppColors.white),
                            ),
                          ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomText(
                                text: formatDate(orderData['createdAt']),
                                color: AppColors.white),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomText(
                                text: formatDate(orderData['updatedAt']),
                                color: AppColors.white),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomText(
                                text: getStatusText(statusIndex).toUpperCase(),
                                color: AppColors.white),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              // IconButton(
                              //   icon:
                              //       Icon(Icons.edit, color: AppColors.darkYellow),
                              //   onPressed: () async {
                              //     await fetchOrderDetails(orderId);
                              //     showEditPopup(
                              //         context,
                              //         orderId,
                              //         orderData['tableNo'],
                              //         orderData['createdBy']);
                              //   },
                              //   tooltip: 'Edit Order',
                              // ),
                              // if (getStatusText(statusIndex).toLowerCase() != 'pending')
                              if (!widget.userModel.voidingTableOrder)
                                Container(),
                              if (widget.userModel.voidingTableOrder)
                                FormButton(
                                  onPressed: () async {
                                    await fetchOrderDetails(orderId);
                                    showEditPopup(
                                        context,
                                        orderId,
                                        orderData['tableNo'],
                                        orderData['createdBy'],
                                        statusIndex);
                                    // await fetchOrderDetails(orderId);
                                    // showEditPopup(
                                    //     context,
                                    //     orderId,
                                    //     orderData['tableNo'],
                                    //     orderData['createdBy']);
                                    // await fetchOrderDetails(orderId);
                                    // _printReceipt();
                                  },
                                  text: "View Order",
                                  bgColor: AppColors.darkYellow,
                                  width: 150,
                                  textColor: AppColors.white,
                                  borderRadius: 10,
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            // Pagination controls
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                'Page ${currentPage + 1} of $totalPages',
                style: const TextStyle(color: AppColors.white),
              ),
              Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.chevron_left, color: AppColors.white),
                    onPressed: currentPage > 0
                        ? () {
                            setState(() {
                              currentPage--;
                            });
                          }
                        : null,
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.chevron_right, color: AppColors.white),
                    onPressed: currentPage < totalPages - 1
                        ? () {
                            setState(() {
                              currentPage++;
                            });
                          }
                        : null,
                  ),
                ],
              )
            ])
          ]
        ]));
  }

  List<OrderProduct> products = [];
  late OrderModel orderModel;
  String selectedStatus = 'Pending'; // Default status
  bool isLoading = true;

//  bool isContainerExpanded = true;
  final List<String> statusOptions = [
    'Pending',
    'Booked',
    'Payment Made',
    'Order Completed',
    'Canceled',
  ];
  Map<String, String> userFullNameCache = {};
  Map<String, String> tableNameCache = {};

  Future<String> getUserFullName(String userId) async {
    if (userFullNameCache.containsKey(userId)) {
      return userFullNameCache[userId]!;
    }
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final fullName = userData['fullname'] ?? 'Unknown';
        userFullNameCache[userId] = fullName; // Cache the result
        return fullName;
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print("Error fetching user full name: $e");
      return 'Unknown';
    }
  }

  Future<String> getTableName(String tableId) async {
    if (tableNameCache.containsKey(tableId)) {
      return tableNameCache[tableId]!;
    }
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(widget.tenantId.trim())
          .collection('Tables')
          //.collection('Users')
          .doc(tableId)
          .get();

      if (userSnapshot.exists) {
        final tableData = userSnapshot.data() as Map<String, dynamic>;
        final tableNam = tableData['tableName'] ?? 'Settled';
        tableNameCache[tableId] = tableNam; // Cache the result
        return tableNam;
      } else {
        return 'Unknown';
      }
    } catch (e) {
      print("Error fetching user full name: $e");
      return 'Unknown';
    }
  }

  Future<void> fetchOrderDetails(String orderId) async {
    final orderRef = FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.tenantId)
        .collection('Orders')
        .doc(orderId);

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await orderRef.get();
      Map<String, dynamic> orderData = snapshot.data() ?? {};
      orderModel = OrderModel.fromFirestore(orderData);
      print(orderModel);
      print(orderModel);
      print(orderModel);
      print(orderModel);
      print(orderModel);
      List<dynamic> productList = orderData['products'] ?? [];
      int orderStatusIndex =
          orderData['status'] ?? 0; // Default to 'Pending' status

      setState(() {
        selectedStatus = statusOptions[orderStatusIndex];
        products = productList
            .where((productJson) =>
                productJson['isProductVoid'] != true) // Exclude voided products
            .map((productJson) => OrderProduct.fromJson(productJson))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching order details: $e');
      MSG.warningSnackBar(context, 'Failed to fetch order details.');
    }
  }
  Future<void> restoreProductQuantities(Map<OrderProduct, int> productsToRestore) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    productsToRestore.forEach((product, qtyToRestore) {
      DocumentReference productRef = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(widget.tenantId)
          .collection('Products')
          .doc(product.productId);

      batch.update(productRef, {
        'qty': FieldValue.increment(qtyToRestore), // Add back the quantity
      });
    });

    try {
      await batch.commit();
      print('Product quantities restored successfully.');
    } catch (e) {
      print('Failed to restore product quantities: $e');
    }
  }
  Future<void> updateOrderStatus(
      String status, orderId, tableId, createdBy, previousStatusIndex) async {
    final orderRef = FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.tenantId)
        .collection('Orders')
        .doc(orderId);

    int statusIndex = statusOptions.indexOf(status);
    await orderRef.update({'status': statusIndex});

    if (previousStatusIndex == 4) {
      MSG.warningSnackBar(context,
          'Status is already canceled and its status cannot be changed');
      Navigator.pop(context);
      return;
    }

    if (statusIndex == 1) {
      // Order is now active, update table activity
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
      await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(widget.tenantId.trim())
          .collection('Tables')
          .doc(tableId)
          .get();

      TableModel retrievedTableModel = TableModel.fromFirestore(docSnapshot);
      DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(createdBy.trim())
          .get();

      UserModel userModel = UserModel.fromFirestore(userDocSnapshot);

      final tableModel = TableModel(
        activity: ActivityModel(
          attendantId: userModel.userId,
          attendantName: userModel.fullname,
          isActive: true,
          currentOrderId: orderId,
          isMerged: true,
        ),
        tableId: retrievedTableModel.tableId,
        tableName: retrievedTableModel.tableName,
        createdAt: retrievedTableModel.createdAt,
        updatedAt: Timestamp.now(),
      );

      await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(widget.tenantId)
          .collection('Tables')
          .doc(retrievedTableModel.tableId)
          .update(tableModel.toFirestore());
    } else if (statusIndex == 4) {
      // Order is being canceled, restore product quantities
      DocumentSnapshot<Map<String, dynamic>> docSnapshot =
      await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(widget.tenantId.trim())
          .collection('Tables')
          .doc(tableId)
          .get();

      TableModel retrievedTableModel = TableModel.fromFirestore(docSnapshot);

      final tableModel = TableModel(
        activity: ActivityModel(
          attendantId: '',
          attendantName: '',
          isActive: false,
          currentOrderId: '',
          isMerged: false,
        ),
        tableId: retrievedTableModel.tableId,
        tableName: retrievedTableModel.tableName,
        createdAt: retrievedTableModel.createdAt,
        updatedAt: Timestamp.now(),
      );

      await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(widget.tenantId)
          .collection('Tables')
          .doc(retrievedTableModel.tableId)
          .update(tableModel.toFirestore());

      // Fetch the order to restore product quantities
      DocumentSnapshot<Map<String, dynamic>> orderSnapshot = await orderRef.get();
      Map<String, dynamic>? orderData = orderSnapshot.data();

      if (orderData != null) {
        OrderModel orderModel = OrderModel.fromFirestore(orderData);

        // Filter out voided products, only restore valid ones
        Map<OrderProduct, int> productsToRestore = {};
        for (var product in orderModel.products) {
          if (!product.isProductVoid) {
            productsToRestore[product] = product.quantity; // Restore full quantity
          }
        }

        // Restore product quantities in Firestore
        await restoreProductQuantities(productsToRestore);

        // Handle voided products separately
        VoidedProductsActivity voidedProductsActivity = VoidedProductsActivity();
        VoidModel voidModel = VoidModel(
          voidedBy: widget.userModel.userId,
          orderedBy: orderData['createdBy'],
          fromOrder: orderId,
          products: orderModel.products,
        );

        setState(() {
          foodProducts = orderModel.products
              .where((orderProduct) =>
          orderProduct.productType.toLowerCase() == 'food')
              .toList();
          drinksProducts = orderModel.products
              .where((orderProduct) =>
          orderProduct.productType.toLowerCase() == 'drinks')
              .toList();
          shishaProducts = orderModel.products
              .where((orderProduct) =>
          orderProduct.productType.toLowerCase() == 'shisha')
              .toList();
        });

        _printDockets(orderModel.orderId);
        voidedProductsActivity.voidAction(
            widget.userModel.tenantId.trim(), voidModel);
      }
    }

    // Log the status change
    LogActivity logActivity = LogActivity();
    LogModel logModel = LogModel(
        actionType: LogActionType.orderStatusChange.toString(),
        actionDescription:
        "${widget.userModel.fullname} changed the order status of order ID $orderId to $status",
        performedBy: widget.userModel.fullname,
        userId: widget.userModel.userId);
    logActivity.logAction(widget.userModel.tenantId.trim(), logModel);

    Navigator.pop(context);
  }

  // Future<void> updateOrderStatus(
  //     String status, orderId, tableId, createdBy, previousStatusIndex) async {
  //   final orderRef = FirebaseFirestore.instance
  //       .collection('Enrolled Entities')
  //       .doc(widget.tenantId)
  //       .collection('Orders')
  //       .doc(orderId);
  //
  //   int statusIndex = statusOptions.indexOf(status);
  //   await orderRef.update({'status': statusIndex});
  //   if (previousStatusIndex == 4) {
  //     MSG.warningSnackBar(context,
  //         'Status is already canceled and its status cannot be changed');
  //     Navigator.pop(context);
  //     return;
  //   } else if (statusIndex == 1) {
  //     DocumentSnapshot<Map<String, dynamic>> docSnapshot =
  //         await FirebaseFirestore.instance
  //             .collection('Enrolled Entities')
  //             .doc(widget.tenantId.trim())
  //             .collection('Tables')
  //             .doc(tableId)
  //             .get();
  //
  //     //if (docSnapshot.exists) {
  //     // Parse the document data into a TableModel
  //     // Map<String, dynamic> data = docSnapshot.data()!;
  //     TableModel retrievedTableModel = TableModel.fromFirestore(docSnapshot);
  //     DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
  //         await FirebaseFirestore.instance
  //             .collection('Users')
  //             .doc(createdBy.trim())
  //             .get();
  //
  //     //if (docSnapshot.exists) {
  //     // Parse the document data into a TableModel
  //     // Map<String, dynamic> data = docSnapshot.data()!;
  //     UserModel userModel = UserModel.fromFirestore(userDocSnapshot);
  //     print(userModel.tenantId);
  //     print(userModel.tenantId);
  //     print(userModel.tenantId);
  //     print(userModel.tenantId);
  //     print(userModel.tenantId);
  //
  //     // return tableModel;
  //     //}
  //     final tableModel = TableModel(
  //       activity: ActivityModel(
  //         attendantId: userModel.userId,
  //         attendantName: userModel.fullname,
  //         isActive: true,
  //         currentOrderId: orderId,
  //         isMerged: true,
  //       ),
  //       tableId: retrievedTableModel.tableId,
  //       tableName: retrievedTableModel.tableName,
  //       createdAt: retrievedTableModel.createdAt,
  //       updatedAt: Timestamp.now(),
  //     );
  //
  //     await FirebaseFirestore.instance
  //         .collection('Enrolled Entities')
  //         .doc(widget.tenantId)
  //         .collection('Tables')
  //         .doc(retrievedTableModel.tableId)
  //         .update(tableModel.toFirestore());
  //   } else if (statusIndex == 4) {
  //     DocumentSnapshot<Map<String, dynamic>> docSnapshot =
  //         await FirebaseFirestore.instance
  //             .collection('Enrolled Entities')
  //             .doc(widget.tenantId.trim())
  //             .collection('Tables')
  //             .doc(tableId)
  //             .get();
  //
  //     //if (docSnapshot.exists) {
  //     // Parse the document data into a TableModel
  //     // Map<String, dynamic> data = docSnapshot.data()!;
  //     TableModel retrievedTableModel = TableModel.fromFirestore(docSnapshot);
  //
  //     //}
  //     final tableModel = TableModel(
  //       activity: ActivityModel(
  //         attendantId: '',
  //         attendantName: '',
  //         isActive: false,
  //         currentOrderId: '',
  //         isMerged: false,
  //       ),
  //       tableId: retrievedTableModel.tableId,
  //       tableName: retrievedTableModel.tableName,
  //       createdAt: retrievedTableModel.createdAt,
  //       updatedAt: Timestamp.now(),
  //     );
  //
  //     await FirebaseFirestore.instance
  //         .collection('Enrolled Entities')
  //         .doc(widget.tenantId)
  //         .collection('Tables')
  //         .doc(retrievedTableModel.tableId)
  //         .update(tableModel.toFirestore());
  //
  //     final DocumentSnapshot<Map<String, dynamic>> orderSnapshot =
  //         await orderRef.get();
  //
  //     //OrderModel orderModel=OrderModel.fromFirestore(orderSnapshot.);
  //     print(orderSnapshot);
  //     Map<String, dynamic>? orderData = orderSnapshot.data();
  //     print(orderData!['products']);
  //     OrderModel orderModel = OrderModel.fromFirestore(orderData);
  //     orderModel.products.removeWhere((product) => product.isProductVoid);
  //     print(orderModel.products);
  //     VoidedProductsActivity voidedProductsActivity = VoidedProductsActivity();
  //     VoidModel voidModel = VoidModel(
  //       voidedBy: widget.userModel.userId,
  //       orderedBy: orderData['createdBy'],
  //       fromOrder: orderId,
  //       products: orderModel.products,
  //     );
  //     setState(() {
  //       //orderProducts = allOrderProducts;
  //       foodProducts = orderModel.products
  //           .where((orderProduct) =>
  //               orderProduct.productType.toLowerCase() == 'food')
  //           .toList();
  //       drinksProducts = orderModel.products
  //           .where((orderProduct) =>
  //               orderProduct.productType.toLowerCase() == 'drinks')
  //           .toList();
  //       shishaProducts = orderModel.products
  //           .where((orderProduct) =>
  //               orderProduct.productType.toLowerCase() == 'shisha')
  //           .toList();
  //     });
  //     _printDockets(orderModel.orderId);
  //     voidedProductsActivity.voidAction(
  //         widget.userModel.tenantId.trim(), voidModel);
  //   }
  //
  //   LogActivity logActivity = LogActivity();
  //   LogModel logModel = LogModel(
  //       actionType: LogActionType.orderStatusChange.toString(),
  //       actionDescription:
  //           "${widget.userModel.fullname} change the order status of order Id $orderId to $status",
  //       performedBy: widget.userModel.fullname,
  //       userId: widget.userModel.userId);
  //   logActivity.logAction(widget.userModel.tenantId.trim(), logModel);
  //   Navigator.pop(context);
  // }

  // Calculate total order price
  double calculateTotalOrderPrice() {
    return products.fold(
        0, (total, product) => total + (product.price * product.quantity));
  }

  // Calculate total amount to pay (after discount)
  double calculateAmtToPay() {
    return products.fold(0, (total, product) {
      double discountedPrice = product.price * (1 - product.discount / 100);
      return total + (discountedPrice * product.quantity);
    });
  }

  void showEditPopup(
      BuildContext context, orderId, tableId, createdBy, orderStatusIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                const BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Order',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      // Row(
                      //   children: [
                      //     GestureDetector(
                      //       onTap: () {
                      //         // Clear all selected products (implement logic)
                      //       },
                      //       child: Icon(
                      //         Icons.delete,
                      //         color: Colors.red,
                      //       ),
                      //     ),
                      //     SizedBox(width: 10),
                      //     GestureDetector(
                      //       onTap: () {
                      //         setState(() {
                      //           isContainerExpanded = !isContainerExpanded;
                      //         });
                      //       },
                      //       child: Icon(
                      //         isContainerExpanded
                      //             ? Icons.expand_less
                      //             : Icons.expand_more,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Order Status',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (newStatus) {
                      setState(() {
                        selectedStatus = newStatus!;
                      });
                    },
                    items: statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 5),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: MediaQuery.of(context).size.height - 300,
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ...products.map((product) {
                          double discountedPrice =
                              product.price * (1 - product.discount / 100);

                          return Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  product.productType.toLowerCase() == 'food'
                                      ? AppImages.food
                                      : AppImages.drink,
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                ),
                                // Image.network(
                                //   product.productImage,
                                //   width: 50,
                                //   height: 50,
                                //   fit: BoxFit.cover,
                                // ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      CustomText(
                                          text: 'Qty: ${product.quantity}',
                                          size: 12,
                                          color: AppColors.black),
                                      CustomText(
                                          text:
                                              'Status: ${product.isProductVoid ? "Voided" : "Booked"}',
                                          size: 12,
                                          color: AppColors.black),
                                      CustomText(
                                        text:
                                            'Price: ₦${product.price.toStringAsFixed(2)}',
                                        size: 12,
                                      ),
                                      CustomText(
                                        text:
                                            'Discounted: ₦${discountedPrice.toStringAsFixed(2)}',
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                                // Row(
                                //   children: [
                                //     IconButton(
                                //       icon: Icon(Icons.remove_circle_outline),
                                //       onPressed: () {
                                //         // Remove product logic
                                //       },
                                //     ),
                                //     CustomText(
                                //       text: product.quantity.toString(),
                                //       size: 12,
                                //     ),
                                //     IconButton(
                                //       icon: Icon(Icons.add_circle_outline),
                                //       onPressed: () {
                                //         // Add product logic
                                //       },
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  //const SizedBox(height: 10),
                  if (products.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:', style: TextStyle(fontSize: 14)),
                        Text(
                            'NGN ${calculateTotalOrderPrice().toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discounted price:',
                            style: TextStyle(fontSize: 14)),
                        Text('NGN ${calculateAmtToPay().toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('VAT(${widget.tenantModel.vat}%):',
                            style: const TextStyle(fontSize: 14)),
                        Text(
                            'NGN ${calculateTax(calculateAmtToPay(), widget.tenantModel.vat / 100).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text('Payment Method:',
                    //         style: TextStyle(fontSize: 14)),
                    //     Text('Cash/Card', style: TextStyle(fontSize: 14)),
                    //   ],
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 15)),
                        Text(
                            'NGN ${(calculateAmtToPay() + calculateTax(calculateAmtToPay(), widget.tenantModel.vat / 100)).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                  FormButton(
                    onPressed: () {
                      //print(selectedStatus);
                      updateOrderStatus(selectedStatus, orderId, tableId,
                          createdBy, orderStatusIndex);
                    },
                    text: "Update Product",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<OrderProduct> foodProducts = [];
  List<OrderProduct> drinksProducts = [];
  List<OrderProduct> shishaProducts = [];

  Future<void> _printDockets(String orderId) async {
    if (foodProducts.isNotEmpty) {
      final foodPrinter = await getPrinter('printerName', 'food');
      await printDockets(foodPrinter.ip, foodPrinter.port, foodProducts,
          'Food Items', orderId);
    }

    if (drinksProducts.isNotEmpty) {
      final drinksPrinter = await getPrinter('printerName', 'drinks');
      await Future.delayed(const Duration(seconds: 3));
      await printDockets(drinksPrinter.ip, drinksPrinter.port, drinksProducts,
          'Drinks Items', orderId);
    }
    if (shishaProducts.isNotEmpty) {
      final shishaPrinter = await getPrinter('printerName', 'shisha');
      await Future.delayed(const Duration(seconds: 3));
      await printDockets(shishaPrinter.ip, shishaPrinter.port, shishaProducts,
          'Shisha Items', orderId);
    }
  }

  PrinterModel? matchingPrinter;
  List<PrinterModel> printerList = [];

  Future<void> fetchPrinters() async {
    try {
      print(
          'Fetching printers for tenant: ${widget.userModel.tenantId.trim()}');

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(widget.userModel.tenantId.trim())
          .collection('Printer')
          .get();

      print('Raw Firestore Documents: ${querySnapshot.docs}');

      List<PrinterModel> fetchedPrinters = querySnapshot.docs.map((doc) {
        print('Document Data: ${doc.data()}');
        return PrinterModel.fromFirestore(doc);
      }).toList();

      setState(() {
        printerList = fetchedPrinters;
        print('Fetched Printers: $printerList');
      });
    } catch (e) {
      print('Error fetching printers: $e');
    }
  }

  Future<PrinterModel> getPrinter(String fieldName, dynamic queryValue) async {
    try {
      print(printerList);
      print(printerList);
      print(printerList);
      matchingPrinter = printerList.firstWhere((printer) {
        switch (fieldName) {
          case 'printerName':
            return printer.printerName.toLowerCase() == queryValue.toString();
          case 'ip':
            return printer.ip == queryValue;
          case 'port':
            return printer.port == queryValue;
          default:
            return false; // No match if the fieldName is unrecognized
        }
      }, orElse: () {
        return matchingPrinter!;
      }); // Return null if no match is found

      return matchingPrinter!;
    } catch (e) {
      print('Error filtering printers: $e');
      return matchingPrinter!;
    }
  }

  Future<void> printDockets(String printerIp, int printerPort,
      List<OrderProduct> products, String title, String orderNo) async {
    try {
      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(PaperSize.mm80, profile);

      final PosPrintResult connectResult =
          await printer.connect(printerIp, port: printerPort);
      if (connectResult != PosPrintResult.success) {
        print("Failed to connect: $connectResult");
        return;
      }
      printer.hr();

      // Print Title (Food or Drinks)
      printer.text(" VOIDED ITEM DOCKET",
          styles: const PosStyles(align: PosAlign.center, bold: true));
      //printer.i
      printer.hr();
      printer.hr();
      // Print Company Logo
      // printer.image(img.decodeImage(companyImage)!);
      printer.row([
        PosColumn(
            text:
                "Date: ${AppUtils.formateSimpleDate(dateTime: DateTime.now().toString())}",
            width: 12,
            styles: const PosStyles(bold: false)),
      ]);
      // printer.row([
      //   PosColumn(
      //       text: "Table: ${widget.tableModel.tableName}",
      //       width: 12,
      //       styles: const PosStyles(bold: false)),
      // ]);
      printer.row([
        PosColumn(
            text: "Ticket No: ${orderNo.substring(0, 6).toUpperCase()}",
            width: 12,
            styles: const PosStyles(bold: false)),
      ]);
      printer.row([
        PosColumn(
            text: "Product Voided by: ${widget.userModel.fullname}",
            width: 12,
            styles: const PosStyles(bold: false)),
      ]);
      printer.hr();

      printer.hr();

      // Print Title (Food or Drinks)
      printer.text("Voided $title",
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.hr();

      // Print Header
      printer.row([
        PosColumn(text: "QTY", width: 2, styles: const PosStyles(bold: true)),
        PosColumn(
            text: "Description",
            width: 10,
            styles: const PosStyles(bold: true)),
        // PosColumn(text: "Price", width: 2, styles: PosStyles(bold: true)),
        // PosColumn(text: "Total", width: 2, styles: PosStyles(bold: true)),
      ]);

      // Print Products
      for (final product in products) {
        printer.row([
          PosColumn(text: product.quantity.toString(), width: 2),
          PosColumn(text: product.productName, width: 10),
          // PosColumn(text: product.price.toStringAsFixed(2), width: 2),
          // PosColumn(
          //   text: (product.price * product.quantity).toStringAsFixed(2),
          //   width: 2,
          // ),
        ]);
      }

      printer.hr();

      // Print Subtotal
      // final subtotal =
      //     products.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
      // printer.row([
      //   PosColumn(text: 'Subtotal:', width: 8),
      //   PosColumn(
      //     text: 'NGN ${subtotal.toStringAsFixed(2)}',
      //     width: 4,
      //     styles: PosStyles(align: PosAlign.right),
      //   ),
      // ]);

      // Print VAT
      // final vatAmount = calculateTax(subtotal, widget.tenantModel.vat / 100);
      // printer.row([
      //   PosColumn(text: 'VAT(${widget.tenantModel.vat}%):', width: 8),
      //   PosColumn(
      //     text: 'NGN ${vatAmount.toStringAsFixed(2)}',
      //     width: 4,
      //     styles: PosStyles(align: PosAlign.right),
      //   ),
      // ]);

      // Print Total
      // final total = subtotal + vatAmount;
      // printer.row([
      //   PosColumn(
      //       text: 'Total:',
      //       width: 8,
      //       styles: PosStyles(bold: true, fontType: PosFontType.fontA)),
      //   PosColumn(
      //     text: 'NGN ${total.toStringAsFixed(2)}',
      //     width: 4,
      //     styles: PosStyles(
      //         align: PosAlign.right, bold: true, fontType: PosFontType.fontA),
      //   ),
      // ]);
      printer.beep();
      printer.feed(2);

      // // Print Footer
      // printer.text(
      //   '* Thank you *',
      //   styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontB),
      // );
      // printer.text(
      //   'Visit us again!',
      //   styles: PosStyles(align: PosAlign.center, fontType: PosFontType.fontB),
      // );

      printer.cut();
      printer.disconnect();
    } catch (e) {
      print("Error in printBill: $e");
    }
  }
}
