part of 'category_bloc.dart';

@immutable
abstract class CategoryEvent {}

class GetCategoryEvent extends CategoryEvent {
  final String tenantId;
  GetCategoryEvent(this.tenantId);
}
class AddCategoryEvent extends CategoryEvent {
  final String categoryName;
  AddCategoryEvent(this.categoryName);
}
class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;
  DeleteCategoryEvent(this.categoryId);
}
  class EditCategoryEvent extends CategoryEvent {
    final String categoryId;
    final String categoryEditedName;

    EditCategoryEvent(this.categoryId,this.categoryEditedName);
  }
