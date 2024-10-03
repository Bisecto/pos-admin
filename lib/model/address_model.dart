class Address {
  String country;
  String city;
  String state;
  String streetAddress;
  String zipCode;

  Address({
    required this.country,
    required this.city,
    required this.state,
    required this.streetAddress,
    required this.zipCode,
  });

  // Factory method to create Address from Firestore DocumentSnapshot
  factory Address.fromFirestore(Map<String, dynamic> data) {
    return Address(
      country: data['country'],
      city: data['city'],
      state: data['state'],
      streetAddress: data['streetAddress'],
      zipCode: data['zipCode'],
    );
  }

  // Method to convert Address object to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'country': country,
      'city': city,
      'state': state,
      'streetAddress': streetAddress,
      'zipCode': zipCode,
    };
  }
}
