import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pos_admin/view/widgets/form_input.dart';

import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../model/order_model.dart';
import '../../../../res/app_colors.dart';
import '../../../../utills/enums/order_status_enums.dart';
import '../../../widgets/app_custom_text.dart';
import '../../../widgets/form_button.dart';

class OrderManagementPage extends StatefulWidget {
  final String tenantId;

  OrderManagementPage({required this.tenantId});

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
  late int totalPages=0;

  @override
  void initState() {
    super.initState();
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
                  icon: Icon(Icons.filter_list),
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
                headingRowColor: MaterialStateProperty.all<Color>(AppColors.purple),
                columns: [
                  DataColumn(
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      child: CustomText(text: 'Order ID', color: AppColors.white),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      child: CustomText(text: 'Created At', color: AppColors.white),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      child: CustomText(text: 'Status', color: AppColors.white),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      child: CustomText(text: 'Actions', color: AppColors.white),
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
                      DataCell(
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: CustomText(text: orderId, color: AppColors.white),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: CustomText(
                              text: formatDate(orderData['createdAt']),
                              color: AppColors.white),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: CustomText(
                              text: getStatusText(statusIndex).toUpperCase(),
                              color: AppColors.white),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            // IconButton(
                            //   icon: Icon(Icons.edit, color: AppColors.purple),
                            //   onPressed: () async {
                            //     await fetchOrderDetails(orderId);
                            //     showEditPopup(context, orderId);
                            //   },
                            //   tooltip: 'Edit Order',
                            // ),
                           // if (getStatusText(statusIndex).toLowerCase() != 'pending')
                              FormButton(
                                onPressed: () async {
                                  await fetchOrderDetails(orderId);
                                  showEditPopup(context, orderId);
                                  // await fetchOrderDetails(orderId);
                                  // _printReceipt();
                                },
                                text: "View Receipt",
                                bgColor: AppColors.purple,
                                width: 150,
                                textColor: AppColors.white,
                                borderRadius:10,
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
              style: TextStyle(color: AppColors.white),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: AppColors.white),
                  onPressed: currentPage > 0
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: AppColors.white),
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
        ]));
  }

  Future<pw.Document> _generateReceipt() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            // Reduced padding to fit content
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Cash Receipt',
                    style: pw.TextStyle(
                      fontSize: 6,
                      fontWeight: pw.FontWeight.bold,
                      font: pw.Font.courier(),
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Checkpoint Abuja',
                    style: pw.TextStyle(
                      fontSize: 6,
                      fontWeight: pw.FontWeight.bold,
                      font: pw.Font.courier(),
                    ),
                  ),
                ),
                pw.SizedBox(height: 3),
                // pw.Text('Order Status: $selectedStatus',
                //     style: pw.TextStyle(fontSize: 6, font: pw.Font.courier())),
                pw.SizedBox(height: 3),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(children: [
                      pw.Container(
                        width: 10, // Fixed width for "QTY"
                        child: pw.Text(
                          "QTY",
                          style: pw.TextStyle(
                            fontSize: 3,
                            fontWeight: pw.FontWeight.bold,
                            font: pw.Font.courier(),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 27, // Fixed width for "Description"
                        child: pw.Text(
                          "Description",
                          style: pw.TextStyle(
                            fontSize: 3,
                            fontWeight: pw.FontWeight.bold,
                            font: pw.Font.courier(),
                          ),
                        ),
                      ),
                    ]),
                    pw.Row(children: [
                      pw.Container(
                        width: 20, // Fixed width for "Price"
                        child: pw.Text(
                          "Price",
                          style: pw.TextStyle(
                            fontSize: 3,
                            fontWeight: pw.FontWeight.bold,
                            font: pw.Font.courier(),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 5),
                      pw.Container(
                        width: 20, // Fixed width for "Total"
                        child: pw.Text(
                          "Total",
                          style: pw.TextStyle(
                            fontSize: 3,
                            fontWeight: pw.FontWeight.bold,
                            font: pw.Font.courier(),
                          ),
                        ),
                      ),
                    ])
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return pw.Container(
                      margin: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Row(children: [
                            pw.Container(
                              width: 10, // Fixed width for quantity
                              child: pw.Text(
                                product.quantity.toString(),
                                style: pw.TextStyle(
                                  fontSize: 3,
                                  font: pw.Font.courier(),
                                ),
                              ),
                            ),
                            pw.Container(
                              width: 27, // Fixed width for product name
                              child: pw.Text(
                                product.productName,
                                style: pw.TextStyle(
                                  fontSize: 3,
                                  font: pw.Font.courier(),
                                ),
                              ),
                            ),
                          ]),
                          pw.Row(children: [
                            pw.Container(
                              width: 20, // Fixed width for price
                              child: pw.Text(
                                '${product.price.toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontSize: 3,
                                  font: pw.Font.courier(),
                                ),
                              ),
                            ),
                            pw.SizedBox(width: 5),
                            pw.Container(
                              width: 20, // Fixed width for total price
                              child: pw.Text(
                                '${(product.price * product.quantity).toStringAsFixed(2)}',
                                style: pw.TextStyle(
                                  fontSize: 3,
                                  font: pw.Font.courier(),
                                ),
                              ),
                            ),
                          ])
                        ],
                      ),
                    );
                  },
                ),
                pw.Divider(),
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Price:',
                        style:
                            pw.TextStyle(fontSize: 6, font: pw.Font.courier())),
                    pw.Text('${calculateTotalOrderPrice().toStringAsFixed(2)}',
                        style:
                            pw.TextStyle(fontSize: 6, font: pw.Font.courier())),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Amount to Pay:',
                        style:
                            pw.TextStyle(fontSize: 6, font: pw.Font.courier())),
                    pw.Text('${calculateAmtToPay().toStringAsFixed(2)}',
                        style:
                            pw.TextStyle(fontSize: 6, font: pw.Font.courier())),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Center(
                  child: pw.Text(
                    'Thank you for shopping!',
                    style: pw.TextStyle(
                      fontSize: 6,
                      fontStyle: pw.FontStyle.italic,
                      font: pw.Font.courier(),
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    'Visit us again!',
                    style: pw.TextStyle(
                      fontSize: 6,
                      fontStyle: pw.FontStyle.italic,
                      font: pw.Font.courier(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  } // Function to print the receipt

  Future<void> _printReceipt() async {
    final pdf = await _generateReceipt();
    await Printing.directPrintPdf(
        printer: const Printer(url: ''),
        onLayout: (PdfPageFormat format) async => pdf.save());
    // await Printing.layoutPdf(
    //   onLayout: (PdfPageFormat format) async => pdf.save(),
    // );
  }

  List<OrderProduct> products = [];
  String selectedStatus = 'Pending'; // Default status
  bool isLoading = true;
  bool isContainerExpanded = true;
  final List<String> statusOptions = [
    'Pending',
    'Payment Made',
    'Food Served',
    'Order Completed',
  ];

  Future<void> fetchOrderDetails(orderId) async {
    final orderRef = FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.tenantId)
        .collection('Orders')
        .doc(orderId);

    DocumentSnapshot<Map<String, dynamic>> snapshot = await orderRef.get();
    Map<String, dynamic> orderData = snapshot.data() ?? {};

    List<dynamic> productList = orderData['products'] ?? [];
    int orderStatusIndex =
        orderData['status'] ?? 0; // Default to 'Pending' status

    setState(() {
      selectedStatus = statusOptions[orderStatusIndex];
      products = productList.map((productJson) {
        return OrderProduct.fromJson(productJson); // Parse products
      }).toList();
      isLoading = false;
    });
  }

  // Update the status in Firestore
  Future<void> updateOrderStatus(String status, orderId) async {
    final orderRef = FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.tenantId)
        .collection('Orders')
        .doc(orderId);

    int statusIndex = statusOptions.indexOf(status);
    await orderRef.update({'status': statusIndex});
  }

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

  void showEditPopup(BuildContext context, orderId) {
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
                    // setState(() {
                    //   selectedStatus = newStatus!;
                    // });
                    // updateOrderStatus(selectedStatus, orderId);
                  },
                  items: [],
                ),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isContainerExpanded
                      ? MediaQuery.of(context).size.height - 300
                      : 50, // Collapsed height
                  child: ListView(
                    shrinkWrap: true,
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
                              Image.network(
                                product.productImage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                const SizedBox(height: 10),
                if (products.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Order Price",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₦${calculateTotalOrderPrice().toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Amount To Pay",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₦${(calculateAmtToPay().toStringAsFixed(2))}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
