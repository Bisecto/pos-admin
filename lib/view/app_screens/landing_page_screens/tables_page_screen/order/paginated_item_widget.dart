import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
    getImageBytes();
    fetchProducts();

    if (widget.orderNum == 1) {
      getCurrentOrder();
    }
    fetchBrands();
    fetchCategories();
  }

  Future<void> getImageBytes() async {
    //setState(()  {
    qrCodeBytes = await rootBundle.load(AppImages.companyLogo);
    companyImage = qrCodeBytes.buffer.asUint8List();
    //});
  }

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
        child: Text(brand['brandName'] ?? 'Unknown Brand'),
      );
    }).toList();

    setState(() {
      brandItems = [
        const DropdownMenuItem(value: null, child: Text("All Brands")),
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
        child: Text(category['categoryName'] ?? 'Unknown Category'),
      );
    }).toList();

    setState(() {
      categoryItems = [
        const DropdownMenuItem(value: null, child: Text("All Categories")),
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

  late ByteData qrCodeBytes;
  late Uint8List companyImage;


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
    Stream<List<MapEntry<Product, int>>> getSelectedProductsStream() {
      return FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(widget.tenantId)
          .collection('SelectedProducts')
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          Product product = Product.fromFirestore(doc);
          int quantity = doc['quantity'] as int;
          return MapEntry(product, quantity);
        }).toList();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.white,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 10),
          child: CustomTextFormField(
            onChanged: (value) {
              applyFilters(selectedBrandId, selectedCategoryId, value);
            },
            width: 250,
            controller: null,
            hint: 'Search products...',
            label: '',
          ),
        ),
        actions: [
          // Dropdown to filter by Brand
          DropdownButton<String>(
            value: selectedBrandId,
            hint: const Text("Select Brand"),
            onChanged: (value) {
              applyFilters(value, selectedCategoryId, searchQuery);
            },
            items: brandItems, // Use Firestore-fetched brands
          ),
          // Dropdown to filter by Category
          DropdownButton<String>(
            value: selectedCategoryId,
            hint: const Text("Select Category"),
            onChanged: (value) {
              applyFilters(selectedBrandId, value, searchQuery);
            },
            items: categoryItems, // Use Firestore-fetched categories
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading && products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
              (MediaQuery.of(context).size.width ~/ 200).toInt() - 1,
              childAspectRatio: 1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: products.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < products.length) {
                Product product = products[index];

                return GestureDetector(
                 // onTap: () => toggleSelection(product),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Card(
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height:
                              !widget.isMoreThanOneOrder ? 120 : 60,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(15)),
                              child: Image.network(
                                product.productImageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.productName.toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text('\₦${product.price.toString()}'),
                                  if (selectedProducts
                                      .containsKey(product))
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),

          // Floating container for the new order

        ],
      ),
    );
  }






}
