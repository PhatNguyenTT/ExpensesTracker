part of 'update_category_bloc.dart';

sealed class UpdateCategoryState extends Equatable {
  const UpdateCategoryState();

  @override
  List<Object> get props => [];
}

final class UpdateCategoryInitial extends UpdateCategoryState {}

final class UpdateCategoryFailure extends UpdateCategoryState {
  final String message;

  const UpdateCategoryFailure({required this.message});

  @override
  List<Object> get props => [message];
}

final class UpdateCategoryLoading extends UpdateCategoryState {}

final class UpdateCategorySuccess extends UpdateCategoryState {}
