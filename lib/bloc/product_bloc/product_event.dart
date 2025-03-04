part of 'product_bloc.dart';

@immutable
abstract class ProductEvent {}

class GetProductEvent extends ProductEvent {
  final String tenantId;

  GetProductEvent(this.tenantId);
}

class AddProductEvent extends ProductEvent {
  final String tenantId;

  final String productName;
  final String sku;
  final double price;
  final String brandId;
  final String categoryId;
  final double discount;
  //final File imageFile;
  final String productType;
  final UserModel userModel;
  final int qty;

  AddProductEvent(
      this.productName,
      this.price,
      this.sku,
      this.categoryId,
      this.brandId,
      this.discount,
      //this.imageFile,
      this.tenantId,
      this.productType, this.userModel, this.qty);
}

class DeleteProductEvent extends ProductEvent {
  final String productId;
  final String tenantId;
  final UserModel userModel;

  DeleteProductEvent(this.productId, this.tenantId, this.userModel);
}

class EditProductEvent extends ProductEvent {
  final String productId;
  final String productEditedName;
  final String tenantId;

  EditProductEvent(this.productId, this.productEditedName, this.tenantId);
}
