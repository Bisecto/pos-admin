part of 'brand_bloc.dart';

@immutable
abstract class BrandEvent {}
class GetBrandEvent extends BrandEvent {
  final String tenantId;
  GetBrandEvent(this.tenantId);
}
class AddBrandEvent extends BrandEvent {
  final String brandName;
  AddBrandEvent(this.brandName);
}
class DeleteBrandEvent extends BrandEvent {
  final String brandId;
  DeleteBrandEvent(this.brandId);
}
class EditBrandEvent extends BrandEvent {
  final String brandId;
  final String brandEditedName;

  EditBrandEvent(this.brandId,this.brandEditedName);
}
