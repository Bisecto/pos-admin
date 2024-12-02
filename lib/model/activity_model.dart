class ActivityModel {
  final String attendantId;
  final String attendantName;
  final bool isActive;

  ActivityModel({
    required this.attendantId,
    required this.attendantName,
    required this.isActive,
  });

  // Factory method to create an ActivityModel instance from a Map
  factory ActivityModel.fromMap(Map<String, dynamic> data) {
    return ActivityModel(
      attendantId: data['attendantId'] as String,
      attendantName: data['attendantName'] as String,
      isActive: data['isActive'] as bool,
    );
  }

  // Method to convert ActivityModel instance to Map
  Map<String, dynamic> toMap() {
    return {
      'attendantId': attendantId,
      'attendantName': attendantName,
      'isActive': isActive,
    };
  }
}
