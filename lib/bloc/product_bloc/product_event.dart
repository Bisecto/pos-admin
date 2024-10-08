part of 'product_bloc.dart';

@immutable
abstract class ProductEvent {}
class GetProductEvent extends ProductEvent {
  final String tenantId;
  GetProductEvent(this.tenantId);
}
class AddProductEvent extends ProductEvent {
  final String productName;
  final String sku;
  final double price;
  final String brandId;
  final String categoryId;
  final double discount;
  final File imageFile;

  AddProductEvent(this.productName,this.price,this.sku,this.categoryId,this.brandId,this.discount,this.imageFile);
}
class DeleteProductEvent extends ProductEvent {
  final String productId;
  DeleteProductEvent(this.productId);
}
class EditProductEvent extends ProductEvent {
  final String productId;
  final String productEditedName;

  EditProductEvent(this.productId,this.productEditedName);
}
