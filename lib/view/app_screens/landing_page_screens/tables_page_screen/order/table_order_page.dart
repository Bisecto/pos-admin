import 'dart:io';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';

//import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http show get;
import 'package:path_provider/path_provider.dart';
import 'package:pos_admin/model/void_model.dart';
import 'package:pos_admin/repository/voided_products_action.dart';
import 'package:pos_admin/view/app_screens/landing_page_screens/tables_page_screen/order/paginated_item_widget.dart';

import '../../../../../model/activity_model.dart';
import '../../../../../model/log_model.dart';
import '../../../../../model/order_model.dart';
import '../../../../../model/printer_model.dart';
import '../../../../../model/product_model.dart';
import '../../../../../model/table_model.dart';
import '../../../../../model/tenant_model.dart';
import '../../../../../model/user_model.dart';
import '../../../../../repository/log_actions.dart';
import '../../../../../res/app_colors.dart';
import '../../../../../res/app_enums.dart';
import '../../../../../res/app_images.dart';
import '../../../../../utills/app_utils.dart';
import '../../../../../utills/enums/order_status_enums.dart';
import '../../../../important_pages/dialog_box.dart';
import '../../../../widgets/app_custom_text.dart';
import '../../../../widgets/drop_down.dart';
import '../../../../widgets/form_button.dart';
import 'package:image/image.dart' as img;

class TableOrderPage extends StatefulWidget {
  TableModel tableModel;
  UserModel userModel;
  TenantModel tenantModel;
  final List<TableModel> tableList;

  TableOrderPage(
      {super.key,
      required this.tableModel,
      required this.userModel,
      required this.tenantModel,
      required this.tableList});

  @override
  State<TableOrderPage> createState() => _TableOrderPageState();
}

class _TableOrderPageState extends State<TableOrderPage> {
  List<String> headers = [
    //'',
    //'Change Table',
    // 'Tickets',
    'View Bill',
    //'Print Receipt',
    //'Settle Bill'
  ];

  List<OrderModel> orders = [];
  final Set<String> selectedOrderIds = {};

  // late ByteData qrCodeBytes;
  // late Uint8List companyImage;
  // File? _imageFile;
  // Future<void> downloadAndSaveImage(String imageUrl) async {
  //   try {
  //     final response = await http.get(Uri.parse(imageUrl));
  //     print(response.statusCode);
  //     print(response.statusCode);
  //     print(response.statusCode);
  //     if (response.statusCode == 200) {
  //       final bytes = response.bodyBytes;
  //
  //       // Get app's directory
  //       final dir = await getApplicationDocumentsDirectory();
  //       final filePath = '${dir.path}/downloaded_image.jpg';
  //
  //       // Save file
  //       final file = File(filePath);
  //       await file.writeAsBytes(bytes);
  //
  //       // Update your _imageFile variable
  //       setState(() {
  //         _imageFile = file;
  //
  //       });
  //       getImageBytes();
  //       print('Image saved to: $filePath');
  //     } else {
  //       setState(() {
  //         _imageFile = File(AppImages.posTerminal);
  //
  //       });
  //       getImageBytes();
  //       print('Failed to download image. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error downloading image: $e');
  //   }
  // }
  // Future<void> getImageBytes() async {
  //   if (_imageFile == null) return;
  //
  //   final bytes = await _imageFile!.readAsBytes();
  //   companyImage = bytes;
  // }

  Map<String, Map<String, dynamic>> orderDetailsCache = {};
  bool isLoading = true;

  List<OrderProduct> products = [];
  List<OrderProduct> foodProducts = [];
  List<OrderProduct> drinksProducts = [];
  List<OrderProduct> shishaProducts = [];

  double calculateTax(double totalPrice, double taxRate) {
    return totalPrice * taxRate;
  }

  Future<void> fetchOrderDetails(String orderId) async {
    print(orderId);
    if (orderId.isEmpty) {
      MSG.warningSnackBar(context, 'Order is not booked yet');
    } else {
      try {
        if (orderDetailsCache.containsKey(orderId)) {
          // Use cached data if already fetched
          final cachedOrderData = orderDetailsCache[orderId];
          List<dynamic> productList = cachedOrderData?['products'] ?? [];
          int orderStatusIndex = cachedOrderData?['status'] ?? 0;

          setState(() {
            //selectedStatus = statusOptions[orderStatusIndex];
            // foodProducts = productList
            //     .where((productJson) =>
            //         productJson['productType'].toString().toLowerCase() ==
            //         'food') // Filter by productType
            //     .map((productJson) =>
            //         OrderProduct.fromJson(productJson)) // Parse products
            //     .toList();
            // drinksProducts = productList
            //     .where((productJson) =>
            //         productJson['productType'].toString().toLowerCase() ==
            //         'drinks') // Filter by productType
            //     .map((productJson) =>
            //         OrderProduct.fromJson(productJson)) // Parse products
            //     .toList();
            products = productList.map((productJson) {
              return OrderProduct.fromJson(productJson); // Parse products
            }).toList();
            print(products);
            print(products);
            print(products);
            print(products);
            isLoading = false;
          });
          return;
        }

        final orderRef = FirebaseFirestore.instance
            .collection('Enrolled Entities')
            .doc(widget.userModel.tenantId)
            .collection('Orders')
            .doc(orderId);

        DocumentSnapshot<Map<String, dynamic>> snapshot = await orderRef.get();
        Map<String, dynamic> orderData = snapshot.data() ?? {};

        // Store fetched data in cache
        orderDetailsCache[orderId] = orderData;

        List<dynamic> productList = orderData['products'] ?? [];
        // int orderStatusIndex = orderData['status'] ?? 0;

        setState(() {
          //selectedStatus = statusOptions[orderStatusIndex];
          // foodProducts = productList
          //     .where((productJson) =>
          //         productJson['productType'].toString().toLowerCase() ==
          //         'food')
          //     .map((productJson) =>
          //         OrderProduct.fromJson(productJson)) // Parse products
          //     .toList();
          // drinksProducts = productList
          //     .where((productJson) =>
          //         productJson['productType'].toString().toLowerCase() ==
          //         'drinks') // Filter by productType
          //     .map((productJson) =>
          //         OrderProduct.fromJson(productJson)) // Parse products
          //     .toList();
          products = productList.map((productJson) {
            return OrderProduct.fromJson(productJson); // Parse products
          }).toList();
          isLoading = false;
        });
      } catch (e) {
        print(e);
        //Navigator.pop(context);
        return;
      }
    }
  }

  // Future<void> _printReceipt(
  //     String ipAddress, int port, String printKey) async {
  //   print(3);
  //   final pdf = await _generateReceipt(printKey);
  //   // await Printing.directPrintPdf(
  //   //     printer: const Printer(url: ''),
  //   //     onLayout: (PdfPageFormat format) async => pdf.save());
  //   print(4);
  //   //await printPdfDirectly(ipAddress, port, pdf);
  //   print('http://${"$ipAddress:$port"}');
  //   //print(await Printing.listPrinters());
  //   await Printing.directPrintPdf(
  //     printer: Printer(url: 'http://${"$ipAddress:$port"}'),
  //     onLayout: (PdfPageFormat format) async => pdf.save(),
  //   );
  //   print(5);
  //   print(5);
  // }

  // Future<void> printPdfDirectly(
  //     String printerIp, int printerPort, pw.Document pdf) async {
  //   try {
  //     // Convert Document to bytes
  //     final Uint8List pdfBytes = await pdf.save();
  //
  //     // Send to printer
  //     final socket = await Socket.connect(printerIp, printerPort);
  //     socket.add(pdfBytes); // Pass the bytes to the printer
  //     await socket.flush();
  //     await socket.close();
  //
  //     print('PDF printed successfully to $printerIp:$printerPort');
  //   } catch (e) {
  //     print('Error while printing: $e');
  //   }
  // }

  void showPopup(BuildContext context, orderId) {
    double change = 0.0;
    String? selectedPaymentMethod;
    final TextEditingController cashController = TextEditingController();

    void calculateChange(total) {
      if (selectedPaymentMethod == 'Cash') {
        final cashGiven = double.tryParse(cashController.text) ?? 0.0;
        setState(() {
          change = cashGiven - total;
        });
      }
    }

    showDialog(
        context: context,
        builder: (BuildContext context) {
          // cashController.addListener(() {
          //   // Rebuild the dialog when the text changes
          //   setState(() {
          //     calculateChange(
          //       calculateTax(calculateAmtToPay(), widget.tenantModel.vat / 100) +
          //           calculateAmtToPay(),
          //     );
          //   });
          // });
          return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Container(
                    width: AppUtils.deviceScreenSize(context).width / 2,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkModeBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.white,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextStyles.textHeadings(
                                    textValue: 'Order Bill',
                                    textSize: 20,
                                    textColor: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ],
                            ),
                            const SizedBox(height: 5),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              // height: MediaQuery.of(context).size.height -
                              //     300, // Collapsed height
                              child: ListView(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  ...products.map((product) {
                                    double discountedPrice = product.price *
                                        (1 - product.discount / 100);

                                    return Container(
                                      padding: const EdgeInsets.all(8),
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors
                                            .darkModeBackgroundContainerColor,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          //const SizedBox(width: 2),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.productName,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.white),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                CustomText(
                                                    text:
                                                        'Price: ₦${product.price.toStringAsFixed(2)}',
                                                    size: 12,
                                                    color: AppColors.white),
                                                CustomText(
                                                    text:
                                                        'Discounted: ₦${discountedPrice.toStringAsFixed(2)}',
                                                    size: 12,
                                                    color: AppColors.white),
                                                CustomText(
                                                    text:
                                                        'Quantity: ${product.quantity}',
                                                    size: 12,
                                                    color: AppColors.white),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              //if (product.quantity > 1)
                                              if (!product.isProductVoid) ...[
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      color: AppColors.white),
                                                  onPressed: () async {
                                                    if (product.quantity > 1) {
                                                      await updateProductQuantity(
                                                          product,
                                                          product.quantity - 1);

                                                      OrderProduct
                                                          orderProduct =
                                                          OrderProduct(
                                                        productName:
                                                            product.productName,
                                                        productType:
                                                            product.productType,
                                                        productId:
                                                            product.productId,
                                                        quantity: 1,
                                                        price: product.price,
                                                        discount:
                                                            product.discount,
                                                        productImage: product
                                                            .productImage,
                                                        brandId:
                                                            product.brandId,
                                                        categoryId:
                                                            product.categoryId,
                                                        sku: product.sku,
                                                        isProductVoid: true,
                                                      );
                                                      voidProductInOrder(
                                                          orderProduct,
                                                          orderId,
                                                          false);
                                                    } else {
                                                      voidProductInOrder(
                                                        product,
                                                        orderId,
                                                        true,
                                                      );
                                                      // removeProductFromOrder(product);
                                                    }
                                                  },
                                                ),
                                                // Quantity Display
                                                //if (product.quantity > 1)
                                                CustomText(
                                                    text:
                                                        "X${product.quantity}",
                                                    size: 12,
                                                    color: AppColors.white),
                                                // Increment Button
                                                //if (product.quantity > 1)
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.add_circle_outline,
                                                      color: AppColors.white),
                                                  onPressed: () {
                                                    MSG.warningSnackBar(context,
                                                        ('You cannot increase the qty of this product'));
                                                    // updateProductQuantity(product,
                                                    //     product.quantity + 1);
                                                  },
                                                ),
                                              ],
                                              GestureDetector(
                                                child: FormButton(
                                                  onPressed: () {
                                                    if (widget.userModel
                                                        .voidingProducts) {
                                                      if (product
                                                          .isProductVoid) {
                                                      } else {
                                                        voidProductInOrder(
                                                            product,
                                                            orderId,
                                                            true);
                                                      }
                                                    } else {
                                                      MSG.warningSnackBar(
                                                          context,
                                                          'You dont have permission to void product');
                                                    }
                                                  },
                                                  text: product.isProductVoid
                                                      ? 'Voided'
                                                      : 'Void Product',
                                                  width: 150,
                                                  bgColor: product.isProductVoid
                                                      ? AppColors.grey
                                                      : AppColors.red,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            if (products.isNotEmpty) ...[
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Service charge(5%)",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white),
                                  ),
                                  Text(
                                    "₦${(0.05 * calculateAmtToPay()).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Sub Total",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white),
                                  ),
                                  Text(
                                    "₦${(calculateAmtToPay().toStringAsFixed(2))}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Tax(%${widget.tenantModel.vat})",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white),
                                  ),
                                  Text(
                                    "₦${calculateTax(calculateAmtToPay(), widget.tenantModel.vat / 100).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white),
                                  ),
                                  Text(
                                    "₦${(0.05 * calculateAmtToPay() + calculateTax(calculateAmtToPay(), widget.tenantModel.vat / 100) + calculateAmtToPay()).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ]),
                    ),
                  );
                },
              ));
        });
  }

  Future<void> updateProductQuantity(
      OrderProduct product, int newQuantity) async {
    final ordersRef = FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.userModel.tenantId.trim())
        .collection('Orders');

    // Query the specific order
    final querySnapshot = await ordersRef
        .where('tableNo', isEqualTo: widget.tableModel.tableId)
        .where('status', isEqualTo: OrderStatus.booked.index)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the first ongoing order
      final orderDoc = querySnapshot.docs.first;
      final orderData = orderDoc.data();

      // Retrieve the current list of products
      List<dynamic> products = orderData['products'];

      // Update the product quantity
      products = products.map((item) {
        if (item['productId'] == product.productId) {
          item['quantity'] = newQuantity;
        }
        return item;
      }).toList();

      // Update the order with the modified list
      await ordersRef.doc(orderDoc.id).update({'products': products});
      //Navigator.pop(context);
      //Navigator.pop(context);
      LogActivity logActivity = LogActivity();
      LogModel logModel = LogModel(
          actionType: LogActionType.orderEdit.toString(),
          actionDescription:
              "${widget.userModel.fullname} changed product quantity for order ${orderDoc.id} from ${product.quantity} to $newQuantity ",
          performedBy: widget.userModel.fullname,
          userId: widget.userModel.userId);
      logActivity.logAction(widget.userModel.tenantId.trim(), logModel);
      MSG.snackBar(context, 'Order Updated');
    } else {
      print('No matching order found to update.');
    }
  }

  Future<void> updateProductQuantities(
      Map<OrderProduct, int> orderedProducts) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Iterate through each product and its ordered quantity
    orderedProducts.forEach((product, orderedQuantity) {
      // Reference to the product document in Firestore
      DocumentReference productRef = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(widget.userModel.tenantId.trim())
          .collection('Products')
          .doc(product.productId);

      // Update the 'qty' field by decrementing the ordered quantity
      batch.update(productRef, {
        'qty': FieldValue.increment(orderedQuantity),
      });
    });

    try {
      // Commit the batch update to Firestore
      await batch.commit();
      print('Product quantities updated successfully.');
    } catch (e) {
      print('Failed to update product quantities: $e');
      MSG.snackBar(context, 'Error updating quantities.');
    }
  }

  Future<void> resetSingleTable(BuildContext context, String tenantId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId.trim())
          .collection('Tables')
          .doc(widget.tableModel.tableId);

      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        print("Table with ID ${widget.tableModel.tableId} does not exist.");
        return;
      }

      final data = docSnapshot.data()!;
      final tableName = data['tableName'] as String;
      final createdAt = data['createdAt'] as Timestamp;

      final defaultTableModel = TableModel(
        activity: ActivityModel(
          attendantId: '',
          attendantName: '',
          isActive: false,
          currentOrderId: '',
          isMerged: false,
        ),
        tableId: widget.tableModel.tableId,
        tableName: tableName,
        createdAt: createdAt,
        updatedAt: Timestamp.now(),
      );

      await docRef.set(defaultTableModel.toFirestore());
      print("Table ${widget.tableModel.tableId} reset successfully.");
    } catch (e) {
      print("Failed to reset table: $e");
    }
  }

  Future<void> voidProductInOrder(
    OrderProduct productToVoid,
    orderId,
    bool isAll,
  ) async {
    print('Product to void: ${productToVoid.productId}');

    final ordersRef = FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.userModel.tenantId.trim())
        .collection('Orders');

    // Query the specific order
    final querySnapshot = await ordersRef
        .where('orderId', isEqualTo: orderId)
        .where('status', isEqualTo: OrderStatus.booked.index)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the first ongoing order
      final orderDoc = querySnapshot.docs.first;
      final orderData = orderDoc.data();

      // Retrieve the current list of products
      List<dynamic> products = List.from(orderData['products']);
      print(products);

      // Map to store voided products and their quantities
      Map<OrderProduct, int> voidedProductsWithQuantities = {};

      // Find and update the specific product
      bool productFound = false;

      // **Updated logic for voiding or deleting a product**
      products.removeWhere((product) {
        if (product['productId'] == productToVoid.productId) {
          productFound = true;

          if (isAll) {
            // If isAll is true, remove the product from the list
            return true; // Remove product from the list
          } else {
            // Otherwise, mark it as void
            product['isProductVoid'] = isAll;
            product['voidedBy'] = widget.userModel.userId;
            product['updatedAt'] = Timestamp.now();

            // Track the voided product and its ordered quantity
            voidedProductsWithQuantities[productToVoid] = product['quantity'];
          }
        }
        return false; // Keep product in the list if it's not being removed
      });

      if (productFound) {
        // Update the order with the modified list
        await ordersRef.doc(orderDoc.id).update({'products': products});

        // Call the updateProductQuantities method to update the quantities
        await updateProductQuantities(voidedProductsWithQuantities);

        // Voided products activity
        VoidedProductsActivity voidedProductsActivity =
            VoidedProductsActivity();
        VoidModel voidModel = VoidModel(
          voidedBy: widget.userModel.userId,
          orderedBy: orderData['createdBy'],
          fromOrder: orderData['orderId'],
          products: [productToVoid],
        );

        setState(() {
          // Filter products by type
          foodProducts = [productToVoid]
              .where((orderProduct) =>
                  orderProduct.productType.toLowerCase() == 'food')
              .toList();
          drinksProducts = [productToVoid]
              .where((orderProduct) =>
                  orderProduct.productType.toLowerCase() == 'drinks')
              .toList();
          shishaProducts = [productToVoid]
              .where((orderProduct) =>
                  orderProduct.productType.toLowerCase() == 'shisha')
              .toList();
        });

        // Print dockets
        _printDockets(orderData['orderId']);

        // Log voided product action
        voidedProductsActivity.voidAction(
            widget.userModel.tenantId.trim(), voidModel);

        // Log the action
        LogActivity logActivity = LogActivity();
        LogModel logModel = LogModel(
          actionType: LogActionType.orderVoid.toString(),
          actionDescription:
              "${widget.userModel.fullname} voided product '${productToVoid.productName}' in order '${orderDoc.id}'",
          performedBy: widget.userModel.fullname,
          userId: widget.userModel.userId,
        );
        logActivity.logAction(widget.userModel.tenantId.trim(), logModel);
        if (products.length < 1) {
          MSG.warningSnackBar(context,
              ("This is the last item  so we have gto clear the table"));
          resetSingleTable(context, widget.userModel.tenantId.trim());
        }
        // Notify user
        Navigator.pop(context);
        Navigator.pop(context);
        MSG.snackBar(context, 'Product voided successfully.');
      } else {
        print('Product not found in the order.');
        MSG.snackBar(context, 'Product not found in the order.');
      }
    } else {
      print('No matching order found to update.');
      MSG.snackBar(context, 'No matching order found to update.');
    }
  }

  // Future<void> voidProductInOrder(
  //     OrderProduct productToVoid, orderId, bool isAll) async {
  //   print('Product to void: ${productToVoid.productId}');
  //
  //   final ordersRef = FirebaseFirestore.instance
  //       .collection('Enrolled Entities')
  //       .doc(widget.userModel.tenantId.trim())
  //       .collection('Orders');
  //
  //   // Query the specific order
  //   final querySnapshot = await ordersRef
  //       .where('orderId', isEqualTo: orderId)
  //       .where('status', isEqualTo: OrderStatus.booked.index)
  //       .get();
  //
  //   if (querySnapshot.docs.isNotEmpty) {
  //     // Get the first ongoing order
  //     final orderDoc = querySnapshot.docs.first;
  //     final orderData = orderDoc.data();
  //
  //     // Retrieve the current list of products
  //     List<dynamic> products = List.from(orderData['products']);
  //     print(products);
  //     // Find and update the specific product
  //     bool productFound = false;
  //     for (var product in products) {
  //       if (product['productId'] == productToVoid.productId) {
  //         product['isProductVoid'] = isAll;
  //         product['voidedBy'] = widget.userModel.userId;
  //         product['updatedAt'] = Timestamp.now();
  //         productFound = true;
  //         break; // Exit loop once product is updated
  //       }
  //     }
  //
  //     if (productFound) {
  //       // Update the order with the modified list
  //       await ordersRef.doc(orderDoc.id).update({'products': products});
  //       VoidedProductsActivity voidedProductsActivity =
  //           VoidedProductsActivity();
  //       VoidModel voidModel = VoidModel(
  //           voidedBy: widget.userModel.userId,
  //           orderedBy: orderData['createdBy'],
  //           fromOrder: orderData['orderId'],
  //           products: [productToVoid]);
  //       setState(() {
  //         //orderProducts = allOrderProducts;
  //         foodProducts = [productToVoid]
  //             .where((orderProduct) =>
  //                 orderProduct.productType.toLowerCase() == 'food')
  //             .toList();
  //         drinksProducts = [productToVoid]
  //             .where((orderProduct) =>
  //                 orderProduct.productType.toLowerCase() == 'drinks')
  //             .toList();
  //         shishaProducts = [productToVoid]
  //             .where((orderProduct) =>
  //                 orderProduct.productType.toLowerCase() == 'shisha')
  //             .toList();
  //       });
  //       _printDockets(orderData['orderId']);
  //
  //       voidedProductsActivity.voidAction(
  //           widget.userModel.tenantId.trim(), voidModel);
  //       // Log the action
  //       LogActivity logActivity = LogActivity();
  //       LogModel logModel = LogModel(
  //         actionType: LogActionType.orderVoid.toString(),
  //         actionDescription:
  //             "${widget.userModel.fullname} voided product '${productToVoid.productName}' in order '${orderDoc.id}'",
  //         performedBy: widget.userModel.fullname,
  //         userId: widget.userModel.userId,
  //       );
  //       logActivity.logAction(widget.userModel.tenantId.trim(), logModel);
  //
  //       // Notify user
  //       Navigator.pop(context);
  //       Navigator.pop(context);
  //       MSG.snackBar(context, 'Product voided successfully.');
  //     } else {
  //       print('Product not found in the order.');
  //       MSG.snackBar(context, 'Product not found in the order.');
  //     }
  //   } else {
  //     print('No matching order found to update.');
  //     MSG.snackBar(context, 'No matching order found to update.');
  //   }
  // }

  Stream<List<OrderModel>> streamOrdersByOrderNo() {
    return FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.userModel.tenantId)
        .collection('Orders')
        .where('tableNo', isEqualTo: widget.tableModel.tableId)
        .where('status', whereIn: [0, 1])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromFirestore(doc.data()))
            .toList());
  }

  int selectedIndex = 0;
  int itemLength = 0;
  String selectedOrderId = '';

  void updateOrderField(String orderId, Map<String, dynamic> updates) async {
    try {
      // Query the document matching the orderId
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(widget.userModel.tenantId)
          .collection('Orders')
          .where('orderId', isEqualTo: orderId)
          .get();

      // Ensure only one document is updated
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;

        // Perform the update with the specific fields
        await doc.reference.update(updates);
        print('Fields updated successfully!');
      } else {
        print('No matching order found!');
      }
    } catch (error) {
      print('Failed to update fields: $error');
    }
  }

  fetchItemCount() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.userModel.tenantId)
        .collection('Orders')
        .where('tableNo', isEqualTo: widget.tableModel.tableId)
        .where('status', whereIn: [0, 1]).get();
    setState(() {
      print(querySnapshot.docs.length);
      itemLength = querySnapshot.docs.length;
      print(itemLength);
    });
    //return querySnapshot.docs.length;
  }

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

  @override
  void initState() {
    // TODO: implement initState
    fetchItemCount();
    fetchPrinters();

    //downloadAndSaveImage(widget.tenantModel.logoUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: customAppBar(),
                ),
                Row(
                  children: [
                    if (itemLength == 1)
                      SizedBox(
                        height: AppUtils.deviceScreenSize(context).height - 200,
                        width: 150,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: headers.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                onTap: () async {
                                  // if (index == 0) {
                                  //   if (widget.tableModel.activity.isActive) {
                                  //     _changeTable();
                                  //   } else {
                                  //     MSG.warningSnackBar(context,
                                  //         "This table is not occupied yet.");
                                  //   }
                                  //} else
                                  if (index == 0) {
                                    // if (!orderDetailsCache.containsKey(widget
                                    //     .tableModel.activity.currentOrderId)) {
                                    // Fetch order details only if not cached
                                    await fetchOrderDetails(widget
                                        .tableModel.activity.currentOrderId);
                                    // }
                                    showPopup(
                                      context,
                                      widget.tableModel.activity.currentOrderId,
                                    );
                                  }

                                  // else if (index == 2) {
                                  //   await fetchOrderDetails(widget
                                  //       .tableModel.activity.currentOrderId);
                                  //   // }
                                  //   showPopup(
                                  //       context,
                                  //       widget
                                  //           .tableModel.activity.currentOrderId,
                                  //       true);
                                  // }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Container(
                                    height: 70,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: AppColors.canvasColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.black),
                                    ),
                                    padding: const EdgeInsets.all(0),
                                    child: Center(
                                      child: TextStyles.textSubHeadings(
                                          textValue: headers[index],
                                          textColor: AppColors.white),
                                    ),
                                  ),
                                ));
                          },
                        ),
                      ),
                    if (itemLength > 1)
                      Container(
                        height: AppUtils.deviceScreenSize(context).height - 200,
                        width: 300,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StreamBuilder<List<OrderModel>>(
                              stream: streamOrdersByOrderNo(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Center(
                                      child: Text('No orders found.'));
                                }

                                orders = snapshot.data!;

                                //  // Update itemLength directly here
                                //  //Future.microtask(() {
                                //    if (mounted) {
                                //      setState(() {
                                //        itemLength = orders.length;
                                //      });
                                //    }
                                // // });

                                return SizedBox(
                                  height: AppUtils.deviceScreenSize(context)
                                          .height -
                                      300,
                                  child: ListView.builder(
                                    itemCount: orders.length,
                                    itemBuilder: (context, index) {
                                      final order = orders[index];
                                      final isSelected = selectedOrderIds
                                          .contains(order.orderId);

                                      return GestureDetector(
                                        onTap: () async {
                                          // if (!orderDetailsCache.containsKey(order.orderId)) {
                                          // Fetch order details only if not cached
                                          await fetchOrderDetails(
                                              order.orderId);
                                          // }
                                          showPopup(context, order.orderId);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.darkGreen
                                                  : AppColors.black,
                                              width: isSelected ? 2.0 : 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            color: isSelected
                                                ? AppColors.lightGreen
                                                    .withOpacity(0.1)
                                                : AppColors.white,
                                          ),
                                          child: ListTile(
                                            key: ValueKey(order.orderId),
                                            title: Text(
                                              "Order ID: ${order.status.name.toLowerCase() != 'pending' ? order.orderId.substring(0, 5).toUpperCase() : ''}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? AppColors.darkGreen
                                                    : AppColors.black,
                                              ),
                                            ),
                                            subtitle: Text(
                                              "Order Status: ${order.status.name.toUpperCase()}",
                                              style: TextStyle(
                                                color: isSelected
                                                    ? AppColors.darkGreen
                                                    : Colors.black54,
                                              ),
                                            ),
                                            trailing: order.status.name
                                                        .toLowerCase() !=
                                                    'pending'
                                                ? Checkbox(
                                                    value: isSelected,
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        if (value == true) {
                                                          selectedOrderIds.add(
                                                              order.orderId);
                                                        } else {
                                                          selectedOrderIds
                                                              .remove(order
                                                                  .orderId);
                                                        }
                                                      });
                                                    },
                                                    activeColor:
                                                        AppColors.darkGreen,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            //   children: [
                            //     if (selectedOrderIds.length == 1)
                            //       FormButton(
                            //         onPressed: () async {
                            //           await fetchOrderDetails(
                            //               selectedOrderIds.first);
                            //           // }
                            //           showPopup(
                            //             context,
                            //             selectedOrderIds.first,
                            //           );
                            //         },
                            //         text: "Settle",
                            //         width: 100,
                            //         //disableButton: selectedOrderIds.length,
                            //         borderRadius: 20,
                            //         bgColor: AppColors.green,
                            //       ),
                            //     if (selectedOrderIds.length > 1)
                            //       FormButton(
                            //         onPressed: () {
                            //           mergeSelectedOrdersAndDeleteRest(
                            //               widget.userModel.tenantId.trim());
                            //         },
                            //         text: "Merge",
                            //         width: 100,
                            //         disableButton: selectedOrderIds.length < 2,
                            //         borderRadius: 20,
                            //         bgColor: AppColors.green,
                            //       ),
                            //     // FormButton(
                            //     //   onPressed: () {
                            //     //     _printReceipt();
                            //     //   },
                            //     //   text: "Close",
                            //     //   width: 125,
                            //     //   borderRadius: 20,
                            //     //   bgColor: AppColors.red,
                            //     // ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    SizedBox(
                      height: AppUtils.deviceScreenSize(context).height - 140,
                      width: itemLength > 1
                          ? (AppUtils.deviceScreenSize(context).width - 500)
                          : itemLength == 0
                              ? AppUtils.deviceScreenSize(context).width
                              : AppUtils.deviceScreenSize(context).width - 200,
                      child: PaginatedProductList(
                        tenantId: widget.userModel.tenantId,
                        userModel: widget.userModel,
                        tableModel: widget.tableModel,
                        tableList: widget.tableList,
                        isMoreThanOneOrder: itemLength > 1,
                        selectedOrderId: selectedOrderId,
                        orderNum: itemLength,
                        tenantModel: widget.tenantModel,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> mergeSelectedOrdersAndDeleteRest(String tenantId) async {
    try {
      // Filter orders by selectedOrderIds
      print(orders);
      print(selectedOrderIds);
      final selectedOrders = orders
          .where((order) => selectedOrderIds.contains(order.orderId))
          .toList();

      if (selectedOrders.isEmpty) {
        print("No selected orders to merge.");
        return;
      }

      // Select the first order as the "merged" document
      final primaryOrder = selectedOrders.first;

      // Create a map to aggregate product quantities
      Map<String, OrderProduct> mergedProductsMap = {};

      for (var order in selectedOrders) {
        for (var product in order.products) {
          // Assuming product is an instance of OrderProduct with 'id' and 'quantity'
          String productId = product.productId;
          int quantity = product.quantity;

          if (mergedProductsMap.containsKey(productId)) {
            // Increase quantity if product already exists in the map
            mergedProductsMap[productId] = OrderProduct(
              productId: productId,
              productName: product.productName,
              quantity: mergedProductsMap[productId]!.quantity + quantity,
              price: product.price,
              productType: product.productType,
              discount: product.discount,
              productImage: product.productImage,
              brandId: product.brandId,
              categoryId: product.categoryId,
              sku: product.sku,

              isProductVoid: product.isProductVoid,
              // Add any other necessary fields
            );
          } else {
            // Add new product to the map
            mergedProductsMap[productId] = product;
          }
        }
      }

      // Convert the map back to a list of products
      List<OrderProduct> mergedProducts = mergedProductsMap.values.toList();

      // Update the primary order with the merged products
      await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Orders')
          .doc(primaryOrder.orderId)
          .update({
        'products': mergedProducts.map((product) => product.toJson()).toList(),
      });
      TableModel tableModel = TableModel(
          activity: ActivityModel(
              attendantId: widget.userModel.userId,
              attendantName: widget.userModel.fullname,
              isActive: true,
              currentOrderId: primaryOrder.orderId,
              isMerged:
                  orders.length == selectedOrderIds.length ? false : true),
          tableId: widget.tableModel.tableId,
          tableName: widget.tableModel.tableName,
          createdAt: widget.tableModel.createdAt,
          updatedAt: Timestamp.now());
      await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Tables')
          .doc(widget.tableModel.tableId)
          .update(tableModel.toFirestore());
      // Delete the remaining selected orders except the primary order
      final ordersToDelete = selectedOrders.skip(1).toList();
      for (var order in ordersToDelete) {
        await FirebaseFirestore.instance
            .collection('Enrolled Entities')
            .doc(tenantId)
            .collection('Orders')
            .doc(order.orderId)
            .delete();
      }

      print("Orders merged into '${primaryOrder.orderId}' and others deleted.");
      Navigator.pop(context);
    } catch (e) {
      print("Error merging selected orders: $e");
    }
  }

  Widget customAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              Icon(
                Icons.arrow_back_ios,
                color: AppColors.white,
              ),
              Image.network(
                widget.tenantModel.logoUrl,
                height: 50,
                width: 50,
              ),
            ],
          ),
        ),
        TextStyles.textHeadings(
            textValue: widget.tableModel.tableName,
            textSize: 24,
            textColor: AppColors.white),
        TextStyles.textHeadings(
            textValue:
                AppUtils.formateSimpleDate(dateTime: DateTime.now().toString()),
            textColor: AppColors.white)
      ],
    );
  }

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
          'ShiSha Items', orderId);
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

  Future<void> printDockets(String printerIp, String printerPort,
      List<OrderProduct> products, String title, String orderNo) async {
    try {
      final profile = await CapabilityProfile.load();
      final printer = NetworkPrinter(PaperSize.mm80, profile);

      final PosPrintResult connectResult =
          await printer.connect(printerIp, port: int.parse(printerPort));
      if (connectResult != PosPrintResult.success) {
        print("Failed to connect: $connectResult");
        return;
      }
      printer.hr();

      printer.text("VOIDED PRODUCT DOCKET",
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.hr();
      printer.hr();

      printer.row([
        PosColumn(
            text:
                "Date: ${AppUtils.formateSimpleDate(dateTime: DateTime.now().toString())}",
            width: 12,
            styles: const PosStyles(bold: false)),
      ]);
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
      printer.text("Voided $title",
          styles: const PosStyles(align: PosAlign.center, bold: true));
      printer.hr();
      printer.row([
        PosColumn(text: "QTY", width: 2, styles: const PosStyles(bold: true)),
        PosColumn(
            text: "Description",
            width: 10,
            styles: const PosStyles(bold: true)),
      ]);

      // Print Products
      for (final product in products) {
        printer.row([
          PosColumn(text: product.quantity.toString(), width: 2),
          PosColumn(text: product.productName, width: 10),
        ]);
      }

      printer.hr();

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
