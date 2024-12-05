class ActivityModel {
  final String attendantId;
  final String attendantName;
  final String currentOrderId;
  final bool isMerged;
  final bool isActive;

  ActivityModel({
    required this.attendantId,
    required this.attendantName,
    required this.currentOrderId,
    required this.isMerged,
    required this.isActive,
  });

  // Factory method to create an ActivityModel instance from a Map
  factory ActivityModel.fromMap(Map<String, dynamic> data) {
    return ActivityModel(
      attendantId: data['attendantId'] ??'',
      attendantName: data['attendantName'] ??'',
      currentOrderId: data['currentOrderId']??'',
      isMerged: data['isMerged'] ??false,
      isActive: data['isActive'] ?? false,
    );
  }

  // Method to convert ActivityModel instance to Map
  Map<String, dynamic> toMap() {
    return {
      'attendantId': attendantId,
      'attendantName': attendantName,
      'currentOrderId': currentOrderId,
      'isMerged': isMerged,
      'isActive': isActive,
    };
  }
}
