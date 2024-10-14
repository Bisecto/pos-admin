part of 'brand_bloc.dart';

@immutable
abstract class BrandEvent {}
class GetBrandEvent extends BrandEvent {
  final String tenantId;
  GetBrandEvent(this.tenantId);
}
class AddBrandEvent extends BrandEvent {
  final String brandName;
  final String tenantId;

  AddBrandEvent(this.brandName,this.tenantId);
}
class DeleteBrandEvent extends BrandEvent {
  final String brandId;
  final String tenantId;

  DeleteBrandEvent(this.brandId,this.tenantId);
}
class EditBrandEvent extends BrandEvent {
  final String brandId;
  final String brandEditedName;
  final String tenantId;


  EditBrandEvent(this.brandId,this.brandEditedName,this.tenantId);
}
