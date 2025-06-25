import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:equatable/equatable.dart';

// ========== EVENTS ==========
abstract class GetCategorySummaryEvent extends Equatable {
  const GetCategorySummaryEvent();

  @override
  List<Object?> get props => [];
}

class GetCategorySummariesByMonth extends GetCategorySummaryEvent {
  final int year;
  final int month;

  const GetCategorySummariesByMonth(this.year, this.month);

  @override
  List<Object> get props => [year, month];
}

class GetCategorySummariesByYear extends GetCategorySummaryEvent {
  final int year;

  const GetCategorySummariesByYear(this.year);

  @override
  List<Object> get props => [year];
}

class GetSpecificCategorySummary extends GetCategorySummaryEvent {
  final String categoryId;
  final int year;
  final int? month;

  const GetSpecificCategorySummary(this.categoryId, this.year, this.month);

  @override
  List<Object?> get props => [categoryId, year, month];
}

// ========== STATES ==========
abstract class GetCategorySummaryState extends Equatable {
  const GetCategorySummaryState();

  @override
  List<Object?> get props => [];
}

class GetCategorySummaryInitial extends GetCategorySummaryState {}

class GetCategorySummaryLoading extends GetCategorySummaryState {}

class GetCategorySummaryFailure extends GetCategorySummaryState {
  final String error;

  const GetCategorySummaryFailure(this.error);

  @override
  List<Object> get props => [error];
}

class GetCategorySummariesSuccess extends GetCategorySummaryState {
  final List<CategorySummary> summaries;
  final int year;
  final int? month;

  const GetCategorySummariesSuccess(this.summaries, this.year, this.month);

  @override
  List<Object?> get props => [summaries, year, month];
}

class GetSpecificCategorySummarySuccess extends GetCategorySummaryState {
  final CategorySummary? summary;
  final String categoryId;
  final int year;
  final int? month;

  const GetSpecificCategorySummarySuccess(
      this.summary, this.categoryId, this.year, this.month);

  @override
  List<Object?> get props => [summary, categoryId, year, month];
}

// ========== BLOC ==========
class GetCategorySummaryBloc
    extends Bloc<GetCategorySummaryEvent, GetCategorySummaryState> {
  final ExpenseRepository _repository;

  GetCategorySummaryBloc(this._repository)
      : super(GetCategorySummaryInitial()) {
    on<GetCategorySummariesByMonth>(_onGetCategorySummariesByMonth);
    on<GetCategorySummariesByYear>(_onGetCategorySummariesByYear);
    on<GetSpecificCategorySummary>(_onGetSpecificCategorySummary);
  }

  Future<void> _onGetCategorySummariesByMonth(
    GetCategorySummariesByMonth event,
    Emitter<GetCategorySummaryState> emit,
  ) async {
    emit(GetCategorySummaryLoading());
    try {
      final summaries =
          await _repository.getCategorySummaryByMonth(event.year, event.month);
      emit(GetCategorySummariesSuccess(summaries, event.year, event.month));
    } catch (e) {
      emit(GetCategorySummaryFailure(e.toString()));
    }
  }

  Future<void> _onGetCategorySummariesByYear(
    GetCategorySummariesByYear event,
    Emitter<GetCategorySummaryState> emit,
  ) async {
    emit(GetCategorySummaryLoading());
    try {
      final summaries = await _repository.getCategorySummaryByYear(event.year);
      emit(GetCategorySummariesSuccess(summaries, event.year, null));
    } catch (e) {
      emit(GetCategorySummaryFailure(e.toString()));
    }
  }

  Future<void> _onGetSpecificCategorySummary(
    GetSpecificCategorySummary event,
    Emitter<GetCategorySummaryState> emit,
  ) async {
    emit(GetCategorySummaryLoading());
    try {
      final summary = await _repository.getCategorySummary(
          event.categoryId, event.year, event.month);
      emit(GetSpecificCategorySummarySuccess(
          summary, event.categoryId, event.year, event.month));
    } catch (e) {
      emit(GetCategorySummaryFailure(e.toString()));
    }
  }
}
