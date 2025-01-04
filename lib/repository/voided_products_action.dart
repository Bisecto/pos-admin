import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/void_model.dart';

class VoidedProductsActivity{
  Future<void> voidAction(String tenantId, VoidModel voidItem) async {
    try {
      await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('VoidedItems') // The collection where voids are stored
          .add(voidItem.toMap());

      print('Voided Product has been added successfully by $tenantId');
    } catch (e) {
      print('Error voidging action: $e');
      // Handle errors appropriately
    }
  }

}