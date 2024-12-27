import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/log_model.dart';

class LogActivity{
  Future<void> logAction(String tenantId, LogModel log) async {
    try {
      await FirebaseFirestore.instance
          .collection('Enrolled Entities')
          .doc(tenantId)
          .collection('Logs') // The collection where logs are stored
          .add(log.toMap());

      print('Log successfully added for tenant: $tenantId');
    } catch (e) {
      print('Error logging action: $e');
      // Handle errors appropriately
    }
  }

}