enum RouteStyle { material, cupertino, fadeIn, slideIn, slideUp }

enum LogActionType {
  // Product Actions
  productAdd,
  productEdit,
  productDelete,

  // Brand Actions
  brandAdd,
  brandEdit,
  brandDelete,

  // Category Actions
  categoryAdd,
  categoryEdit,
  categoryDelete,

  // Table Actions
  tableAdd,
  // tableEdit,
  // tableDelete,

  // User Actions
  userAdd,
  userEdit,
  userDelete,
  userSignIn,
  userSignOut,
  userPasswordChange,
  userModification,

  // Order Actions
  pendingOrderClear,
  orderAdd,
  orderChangeTable,
  orderEdit, // Includes changeOrderTable, bookingOrder
  orderVoid, // Includes voidingOrderProduct, voidingOrder
  orderSettle,
  orderMerge,
  orderStatusChange,

  // Business Actions
  businessProfileUpdate,

  // System Actions
  systemStartStopDay,
  systemChangePassword,

  // Printer Actions
  printerAdd,
  printerEdit,
  printerDelete,
}
