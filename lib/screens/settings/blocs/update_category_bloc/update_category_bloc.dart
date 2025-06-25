import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'update_category_event.dart';
part 'update_category_state.dart';

class UpdateCategoryBloc
    extends Bloc<UpdateCategoryEvent, UpdateCategoryState> {
  final ExpenseRepository expenseRepository;

  UpdateCategoryBloc(this.expenseRepository) : super(UpdateCategoryInitial()) {
    on<UpdateCategory>((event, emit) async {
      emit(UpdateCategoryLoading());
      try {
        await expenseRepository.updateCategory(event.category);
        emit(UpdateCategorySuccess());
      } catch (e) {
        emit(UpdateCategoryFailure());
      }
    });
  }
}
