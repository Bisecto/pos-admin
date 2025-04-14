class Plan {
  final String name;
  final double monthlyPrice;
  final double yearlyPrice;
  final int maxProducts;
  final int maxTransactionsPerMonth;
  final int maxUsers;

  // final bool receiptPrinting;
  final bool cloudSync;
  final bool exportProductsToExcel;

  //final bool printProductsA4;
  // final bool printTransactionsA4;
  final bool exportTransactionsToExcel;

  //final bool printStaffA4;
  final bool exportStaffToExcel;
  final bool accessToMultiTerminal;
  final bool offlineMode;
  final bool customBranding;
  final bool advancedRolesBranding;
  final bool apiAccess;
  final bool stockManagement;
  final bool logs;

  Plan({
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.maxProducts,
    required this.maxTransactionsPerMonth,
    required this.maxUsers,
    // required this.receiptPrinting,
    required this.cloudSync,
    required this.exportProductsToExcel,
    // required this.printProductsA4,
    //required this.printTransactionsA4,
    required this.exportTransactionsToExcel,
    //required this.printStaffA4,
    required this.exportStaffToExcel,
    required this.accessToMultiTerminal,
    required this.offlineMode,
    required this.customBranding,
    required this.advancedRolesBranding,
    required this.apiAccess,
    required this.stockManagement,
    required this.logs,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      name: json['name'],
      monthlyPrice: (json['monthlyPrice'] ?? 0).toDouble(),
      yearlyPrice: (json['yearlyPrice'] ?? 0).toDouble(),
      maxProducts: json['maxProducts'] ?? 0,
      maxTransactionsPerMonth: json['maxTransactionsPerMonth'] ?? 0,
      maxUsers: json['maxUsers'] ?? 0,
      //eceiptPrinting: json['receiptPrinting'] ?? false,
      cloudSync: json['cloudSync'] ?? false,
      exportProductsToExcel: json['exportProductsToExcel'] ?? false,
      // printProductsA4: json['printProductsA4'] ?? false,
      //printTransactionsA4: json['printTransactionsA4'] ?? false,
      exportTransactionsToExcel: json['exportTransactionsToExcel'] ?? false,
      // printStaffA4: json['printStaffA4'] ?? false,
      exportStaffToExcel: json['exportStaffToExcel'] ?? false,
      accessToMultiTerminal: json['accessToMultiTerminal'] ?? false,
      offlineMode: json['offlineMode'] ?? false,
      customBranding: json['customBranding'] ?? false,
      advancedRolesBranding: json['advancedRolesBranding'] ?? false,
      apiAccess: json['apiAccess'] ?? false,
      stockManagement: json['stockManagement'] ?? false,
      logs: json['logs'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'monthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,
      'maxProducts': maxProducts,
      'maxTransactionsPerMonth': maxTransactionsPerMonth,
      'maxUsers': maxUsers,
      //'receiptPrinting': receiptPrinting,
      'cloudSync': cloudSync,
      'exportProductsToExcel': exportProductsToExcel,
      //'printProductsA4': printProductsA4,
      // 'printTransactionsA4': printTransactionsA4,
      'exportTransactionsToExcel': exportTransactionsToExcel,
      //'printStaffA4': printStaffA4,
      'exportStaffToExcel': exportStaffToExcel,
      'accessToMultiTerminal': accessToMultiTerminal,
      'offlineMode': offlineMode,
      'customBranding': customBranding,
      'advancedRolesBranding': advancedRolesBranding,
      'apiAccess': apiAccess,
      'stockManagement': stockManagement,
      'logs': logs,
    };
  }
}
