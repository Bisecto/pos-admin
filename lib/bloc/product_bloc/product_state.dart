part of 'product_bloc.dart';

@immutable
sealed class ProductState {}

final class ProductInitial extends ProductState {}
class ProductLoadingState extends ProductState {}
class AddProductLoadingState extends ProductState {}
class ProductErrorState extends ProductState {
  final String error;

  ProductErrorState(this.error);
}
class GetProductSuccessState extends ProductState {
  final List<Product> productList;
  final List<Brand> brandList;
  final List<Category> categoryList;


  GetProductSuccessState(
      this.productList,this.brandList,this.categoryList);
}