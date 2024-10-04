part of 'category_bloc.dart';

@immutable
abstract class CategoryEvent {}

class GetCategoryEvent extends CategoryEvent {
  final String tenantId;
  GetCategoryEvent(this.tenantId);
}
