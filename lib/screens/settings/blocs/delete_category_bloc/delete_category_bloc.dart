import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'delete_category_event.dart';
part 'delete_category_state.dart';

class DeleteCategoryBloc
    extends Bloc<DeleteCategoryEvent, DeleteCategoryState> {
  final ExpenseRepository expenseRepository;

  DeleteCategoryBloc(this.expenseRepository) : super(DeleteCategoryInitial()) {
    on<DeleteCategory>((event, emit) async {
      emit(DeleteCategoryLoading());
      try {
        await expenseRepository.deleteCategory(event.categoryId);
        emit(DeleteCategorySuccess());
      } catch (e) {
        emit(DeleteCategoryFailure(message: e.toString()));
      }
    });
  }
}
