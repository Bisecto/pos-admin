part of 'category_bloc.dart';

@immutable
abstract class CategoryState {}

final class CategoryInitial extends CategoryState {}

class CategoryLoadingState extends CategoryState {}

class AddCategoryLoadingState extends CategoryState {}

class CategoryErrorState extends CategoryState {
  final String error;

  CategoryErrorState(this.error);
}

class GetCategorySuccessState extends CategoryState {
  final List<Category> categoryList;

  GetCategorySuccessState(
    this.categoryList,
  );
}
