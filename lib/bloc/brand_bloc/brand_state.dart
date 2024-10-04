part of 'brand_bloc.dart';

@immutable
sealed class BrandState {}

final class BrandInitial extends BrandState {}
class BrandLoadingState extends BrandState {}
class AddBrandLoadingState extends BrandState {}
class BrandErrorState extends BrandState {
  final String error;

  BrandErrorState(this.error);
}
class GetBrandSuccessState extends BrandState {
  final List<Brand> brandList;


  GetBrandSuccessState(
      this.brandList,);
}