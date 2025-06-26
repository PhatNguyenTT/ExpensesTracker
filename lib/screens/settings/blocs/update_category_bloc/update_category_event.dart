part of 'update_category_bloc.dart';

sealed class UpdateCategoryEvent extends Equatable {
  const UpdateCategoryEvent();

  @override
  List<Object> get props => [];
}

class UpdateCategory extends UpdateCategoryEvent {
  final Category category;

  const UpdateCategory(this.category);

  @override
  List<Object> get props => [category];
}
