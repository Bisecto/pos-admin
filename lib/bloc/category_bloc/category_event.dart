part of 'category_bloc.dart';

@immutable
abstract class CategoryEvent {}

class GetCategoryEvent extends CategoryEvent {
  final String tenantId;
  GetCategoryEvent(this.tenantId);
}
class AddCategoryEvent extends CategoryEvent {
  final String categoryName;
  final String tenantId;

  AddCategoryEvent(this.categoryName,this.tenantId);
}
class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;
  final String tenantId;

  DeleteCategoryEvent(this.categoryId,this.tenantId);
}
  class EditCategoryEvent extends CategoryEvent {
    final String categoryId;
    final String categoryEditedName;
    final String tenantId;


    EditCategoryEvent(this.categoryId,this.categoryEditedName,this.tenantId);
  }
