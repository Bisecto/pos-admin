import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http show get;
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:typed_data';

import '../../../../../model/activity_model.dart';
import '../../../../../model/order_model.dart';
import '../../../../../model/product_model.dart';
import '../../../../../model/table_model.dart';
import '../../../../../model/tenant_model.dart';
import '../../../../../model/user_model.dart';
import '../../../../../res/app_colors.dart';
import '../../../../../res/app_images.dart';
import '../../../../../utills/app_utils.dart';
import '../../../../../utills/enums/order_status_enums.dart';
import '../../../../important_pages/dialog_box.dart';
import '../../../../widgets/app_custom_text.dart';
import '../../../../widgets/form_input.dart';

class PaginatedProductList extends StatefulWidget {
  final String tenantId;
  final UserModel userModel;
  final TableModel tableModel;
  final TenantModel tenantModel;
  final List<TableModel> tableList;
  final bool isMoreThanOneOrder;
  final int orderNum;
  String selectedOrderId;

  PaginatedProductList(
      {required this.tenantId,
      required this.userModel,
      required this.tableModel,
      required this.tenantModel,
      required this.tableList,
      required this.isMoreThanOneOrder,
      required this.orderNum,
      required this.selectedOrderId});

  @override
  _PaginatedProductListState createState() => _PaginatedProductListState();
}

class _PaginatedProductListState extends State<PaginatedProductList> {
  static const int pageSize = 20;
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  List<Product> products = [];
  Map<Product, int> selectedProducts = {};
  Offset floatingContainerPosition = const Offset(20, 100);
  bool isContainerExpanded = true; // false;
  bool orderFinalized = false;

  String? selectedBrandId; // Store selected brandId for filtering
  String? selectedCategoryId; // Store selected categoryId for filtering
  String searchQuery = ""; // Store search query
  //TextEditingController tableNumberEditingController = TextEditingController();
  List<DropdownMenuItem<String>> brandItems = [];
  List<DropdownMenuItem<String>> categoryItems = [];

  Stream<Map<Product, int>> getOngoingOrderStream(String orderId) {
    // if (orderId.isEmpty) {
    //   // Return an empty stream if no order IDs are provided
    //   return Stream.value({});
    // }
    if (widget.isMoreThanOneOrder) {
    } else {}
    return FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.tenantId)
        .collection('Orders')
        .where('tableNo', isEqualTo: widget.tableModel.tableId)
        .where('status', isEqualTo: OrderStatus.pending.index)
        // .where('orderId',
        //     isEqualTo: orderId) // Apply filter only if list is non-empty
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // Combine products from all matching documents
        final Map<Product, int> productMap = {};
        for (final doc in querySnapshot.docs) {
          final List<dynamic> products = doc['products'] ?? [];
          for (final product in products) {
            final productObj = Product.fromFirestore(product);
            final quantity = product['quantity'] as int;
            // Aggregate quantities for the same product
            if (productMap.containsKey(productObj)) {
              productMap[productObj] = productMap[productObj]! + quantity;
            } else {
              productMap[productObj] = quantity;
            }
          }
        }
        return productMap;
      }
      return {};
    });
  }

  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
//    downloadAndSaveImage(widget.tenantModel.logoUrl);
    fetchProducts();

    if (widget.orderNum == 1) {
      getCurrentOrder();
    }
    fetchBrands();
    fetchCategories();
  }

  File? _imageFile;

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
  //
  //       print('Image saved to: $filePath');
  //     } else {
  //       setState(() {
  //         _imageFile = File(AppImages.posTerminal);
  //
  //       });
  //       getImageBytes();
  //
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

  Query<Map<String, dynamic>> getPaginatedQuery() {
    var query = FirebaseFirestore.instance
        .collection('Enrolled Entities')
        .doc(widget.tenantId)
        .collection('Products')
        .orderBy('productName') // Order by productName
        .limit(pageSize);

    // Apply search query
    if (searchQuery.isNotEmpty) {
      query = query
          .where('productName', isGreaterThanOrEqualTo: searchQuery)
          .where('productName', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    // Apply brand filter
    if (selectedBrandId != null) {
      query = query.where('brandId', isEqualTo: selectedBrandId);
    }

    // Apply category filter
    if (selectedCategoryId != null) {
      query = query.where('categoryId', isEqualTo: selectedCategoryId);
    }

    // If lastDocument exists, fetch the next batch of data
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }
    return query;
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await getPaginatedQuery().get();

    List<Product> fetchedProducts =
        querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

    if (querySnapshot.docs.isNotEmpty) {
      lastDocument = querySnapshot.docs.last; // Update the last document
    }

    setState(() {
      products.addAll(fetchedProducts);
      isLoading = false;
      print(products);
    });
  }

  void applyFilters(String? brandId, String? categoryId, String query) {
    setState(() {
      selectedBrandId = brandId;
      selectedCategoryId = categoryId;
      searchQuery = query;
      lastDocument = null; // Reset pagination
      products.clear(); // Clear previous results
    });
    fetchProducts();
  }

  Future<void> fetchBrands() async {
    QuerySnapshot<Map<String, dynamic>> brandSnapshot = await FirebaseFirestore
        .instance
        .collection('Enrolled Entities')
        .doc(widget.tenantId)
        .collection('Brand')
        .get();

    List<DropdownMenuItem<String>> brandDropdownItems =
        brandSnapshot.docs.map((doc) {
      var brand = doc.data();
      return DropdownMenuItem<String>(
        value: doc.id,
        child: Text(
          brand['brandName'] ?? 'Unknown Brand',
          style: TextStyle(color: AppColors.white),
        ),
      );
    }).toList();

    setState(() {
      brandItems = [
        const DropdownMenuItem(
            value: null,
            child: Text(
              "All Brands",
              style: TextStyle(color: AppColors.white),
            )),
        ...brandDropdownItems
      ];
    });
  }

  Future<void> fetchCategories() async {
    QuerySnapshot<Map<String, dynamic>> categorySnapshot =
        await FirebaseFirestore.instance
            .collection('Enrolled Entities')
            .doc(widget.tenantId)
            .collection('Category')
            .get();

    List<DropdownMenuItem<String>> categoryDropdownItems =
        categorySnapshot.docs.map((doc) {
      var category = doc.data();
      return DropdownMenuItem<String>(
        value: doc.id,
        child: Text(
          category['categoryName'] ?? 'Unknown Category',
          style: TextStyle(color: AppColors.white),
        ),
      );
    }).toList();

    setState(() {
      categoryItems = [
        const DropdownMenuItem(
            value: null,
            child: Text(
              "All Categories",
              style: TextStyle(color: AppColors.white),
            )),
        ...categoryDropdownItems
      ];
    });
  }

  // Future<void> loadSelectedProducts() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final String? selectedProductsString = prefs.getString('selectedProducts');
  //   if (selectedProductsString != null) {
  //     final Map<String, dynamic> selectedProductsJson =
  //         json.decode(selectedProductsString);
  //     setState(() {
  //       selectedProducts = selectedProductsJson.map((key, value) =>
  //           MapEntry(Product.fromJson(json.decode(key)), value as int));
  //     });
  //   }
  // }
  late StreamSubscription<Map<Product, int>> ongoingOrderSubscription;

  void getCurrentOrder() {
    ongoingOrderSubscription =
        getOngoingOrderStream(widget.selectedOrderId).listen((orderProducts) {
      setState(() {
        selectedProducts = orderProducts;
      });
    });
  }

  // Future<void> clearAllSelectedProducts() async {
  //   final ordersRef = FirebaseFirestore.instance
  //       .collection('Enrolled Entities')
  //       .doc(widget.tenantId)
  //       .collection('Orders');
  //
  //   final querySnapshot = await ordersRef
  //       .where('tableNo', isEqualTo: widget.tableModel.tableId)
  //       .where('status', isEqualTo: OrderStatus.pending.index)
  //       .get();
  //
  //   if (querySnapshot.docs.isNotEmpty) {
  //     final orderDoc = querySnapshot.docs.first;
  //     await ordersRef.doc(orderDoc.id).update({'products': []});
  //   }
  //   setState(() {
  //     selectedProducts.clear();
  //   });
  // }

  // Future<void> saveSelectedProducts() async {
  //   final ordersRef = FirebaseFirestore.instance
  //       .collection('Enrolled Entities')
  //       .doc(widget.tenantId)
  //       .collection('Orders');
  //
  //   final querySnapshot = await ordersRef
  //       .where('tableNo', isEqualTo: widget.tableModel.tableId)
  //       .where('status', isEqualTo: OrderStatus.pending.index)
  //       .get();
  //
  //   if (querySnapshot.docs.isNotEmpty) {
  //     // Update the ongoing order
  //     final orderDoc = querySnapshot.docs.first;
  //     final List<Map<String, dynamic>> updatedProducts =
  //     selectedProducts.entries
  //         .map((entry) => {
  //       'productName': entry.key.productName,
  //       'productId': entry.key.productId,
  //       'quantity': entry.value,
  //       'price': entry.key.price,
  //       'discount': entry.key.discount,
  //       'productImage': entry.key.productImageUrl,
  //       'brandId': entry.key.brandId,
  //       'categoryId': entry.key.categoryId,
  //       'productType': entry.key.productType,
  //       'sku': entry.key.sku,
  //     })
  //         .toList();
  //     await ordersRef.doc(orderDoc.id).update({'products': updatedProducts});
  //   } else {
  //     // Create a new order if none exists
  //     await ordersRef.add({
  //       'products': selectedProducts.entries
  //           .map((entry) => {
  //         'productName': entry.key.productName,
  //         'productId': entry.key.productId,
  //         'quantity': entry.value,
  //         'price': entry.key.price,
  //         'discount': entry.key.discount,
  //         'productImage': entry.key.productImageUrl,
  //         'brandId': entry.key.brandId,
  //         'categoryId': entry.key.categoryId,
  //         'productType': entry.key.productType,
  //         'sku': entry.key.sku,
  //       })
  //           .toList(),
  //       'updatedAt': FieldValue.serverTimestamp(),
  //       'createdAt': FieldValue.serverTimestamp(),
  //       'createdBy': FirebaseAuth.instance.currentUser!.uid,
  //       'updatedBy': FirebaseAuth.instance.currentUser!.uid,
  //       'tableNo': widget.tableModel.tableId,
  //       'status': OrderStatus.pending.index,
  //       'orderId': ordersRef.id
  //     });
  //   }
  // }

  // Clear the selected products from shared preferences
  // Future<void> clearSelectedProducts() async {
  //   final ordersRef = FirebaseFirestore.instance
  //       .collection('Enrolled Entities')
  //       .doc(widget.tenantId)
  //       .collection('Orders');
  //
  //   // Find the pending order for the current table
  //   final querySnapshot = await ordersRef
  //       .where('tableNo', isEqualTo: widget.tableModel.tableId)
  //       .where('status', isEqualTo: OrderStatus.pending.index)
  //       .get();
  //
  //   if (querySnapshot.docs.isNotEmpty) {
  //     // Update the order's products to an empty array
  //     final orderDoc = querySnapshot.docs.first;
  //     await ordersRef.doc(orderDoc.id).update({'products': []});
  //   } else {
  //     print('No ongoing order to clear.');
  //   }
  // }

  // Pagination query

  // void removeProduct(Product product) {
  //   setState(() {
  //     if (selectedProducts.containsKey(product)) {
  //       selectedProducts[product] =
  //           (selectedProducts[product] ?? 1) - 1; // Decrease quantity
  //       if (selectedProducts[product] == 0) {
  //         selectedProducts
  //             .remove(product); // Remove product if quantity is zero
  //       }
  //     }
  //   });
  //   saveSelectedProducts(); // Save changes
  // }

  List<OrderProduct> orderProducts = [];

  double calculateTax(double totalPrice, double taxRate) {
    return totalPrice * taxRate;
  }

  Map<String, Map<String, dynamic>> orderDetailsCache = {};

  Future<void> fetchOrderDetails(String orderId) async {
    print(orderId);
    if (orderId.isEmpty) {
      MSG.warningSnackBar(context, 'Order is not booked yet');
    }
    //else{
    // try{
    if (orderDetailsCache.containsKey(orderId)) {
      // Use cached data if already fetched
      final cachedOrderData = orderDetailsCache[orderId];
      List<dynamic> productList = cachedOrderData?['products'] ?? [];
      int orderStatusIndex = cachedOrderData?['status'] ?? 0;

      setState(() {
        //selectedStatus = statusOptions[orderStatusIndex];

        orderProducts = productList.map((productJson) {
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

      orderProducts = productList.map((productJson) {
        return OrderProduct.fromJson(productJson); // Parse products
      }).toList();
      isLoading = false;
    });
    // }catch(e){
    //
    //   print(e);
    //   //Navigator.pop(context);
    //   return;
    //
    // }
  }

  // late ByteData qrCodeBytes;
  // late Uint8List companyImage;

  void toggleContainer() {
    setState(() {
      isContainerExpanded = true; //!isContainerExpanded; // Toggle expansion
    });
  }

  // void updateFloatingContainerPosition(DragUpdateDetails details) {
  //   setState(() {
  //     floatingContainerPosition +=
  //         details.delta; // Update position based on drag
  //   });
  // }

  double calculateTotalOrderPrice() {
    double total = 0.0;

    selectedProducts.forEach((product, quantity) {
      total += product.price * quantity; // Add product total price
    });

    return total;
  }

  //final specificOrderController = TextEditingController();

  double calculateAmtToPay() {
    double total = 0.0;

    selectedProducts.forEach((product, quantity) {
      total += product.price *
          (1 - product.discount / 100) *
          quantity; // Add product total price
    });

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridWidth =
        widget.isMoreThanOneOrder ? screenWidth * 0.6 : screenWidth;
    final itemWidth = 180;
    final crossAxisCount = (gridWidth / itemWidth).floor().clamp(1, 5);
    return Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.scaffoldBackgroundColor,
          title: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 10),
            child: CustomTextFormField(
              onChanged: (value) {
                applyFilters(selectedBrandId, selectedCategoryId, value);
              },
              width: 200,
              controller: null,
              hint: 'Search...',
              label: '',
            ),
          ),
          actions: [
            // Dropdown to filter by Brand
            DropdownButton<String>(
              value: selectedBrandId,
              hint: const Text(
                "Select Brand",
                style: TextStyle(color: AppColors.white),
              ),
              onChanged: (value) {
                applyFilters(value, selectedCategoryId, searchQuery);
              },

              items: brandItems, // Use Firestore-fetched brands
            ),
            // Dropdown to filter by Category
            DropdownButton<String>(
              value: selectedCategoryId,
              hint: const Text(
                "Select Category",
                style: TextStyle(color: AppColors.white),
              ),
              onChanged: (value) {
                applyFilters(selectedBrandId, value, searchQuery);
              },
              items: categoryItems, // Use Firestore-fetched categories
            ),
          ],
        ),
        body: SizedBox(
            height: MediaQuery.of(context).size.height - 210,
            width: gridWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.2, // Slightly more compact
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: products.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < products.length) {
                        Product product = products[index];

                        return GestureDetector(
                          //onTap: () => _toggleSelection(product),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getGradientColors(index),
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.productName.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '₦${NumberFormat("#,##0").format(product.price)}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Positioned(
                                //   top: 10,
                                //   right: 10,
                                //   child: Container(
                                //     padding: EdgeInsets.all(6),
                                //     decoration: BoxDecoration(
                                //       shape: BoxShape.circle,
                                //       color: Colors.red,
                                //     ),
                                //     child: Text(
                                //       product.productQuantity.toString(),
                                //       style: TextStyle(
                                //         color: Colors.white,
                                //         fontSize: 12,
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  );
                },
              ),
            )));
  }

  List<Color> _getGradientColors(int index) {
    List<List<Color>> gradients = [
      [Colors.blue, Colors.purple],
      [Colors.orange, Colors.red],
      [Colors.green, Colors.teal],
      [Colors.pink, Colors.deepPurple],
      [Colors.yellow, Colors.amber],
      [Colors.cyan, Colors.indigo],
      [Colors.lime, Colors.green],
      [Colors.deepOrange, Colors.brown],
      [Colors.blueGrey, Colors.black],
      [Colors.deepPurple, Colors.blueGrey],
      [Colors.teal, Colors.deepOrange],
      [Colors.purple, Colors.pink],
      [Colors.redAccent, Colors.deepPurpleAccent],
      [Colors.indigo, Colors.cyan],
      [Colors.brown, Colors.deepOrangeAccent],
      [Colors.lightBlue, Colors.blueGrey],
      [Colors.amber, Colors.orangeAccent],
      [Colors.limeAccent, Colors.teal],
      [Colors.deepPurpleAccent, Colors.blueAccent],
      [Colors.black, Colors.blueGrey],
    ];
    return gradients[index % gradients.length];
  }
}
