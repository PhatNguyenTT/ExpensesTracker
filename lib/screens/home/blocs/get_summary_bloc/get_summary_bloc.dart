import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:equatable/equatable.dart';

// ========== EVENTS ==========
abstract class GetSummaryEvent extends Equatable {
  const GetSummaryEvent();

  @override
  List<Object> get props => [];
}

class GetOverallSummary extends GetSummaryEvent {
  final String walletId;
  const GetOverallSummary(this.walletId);
  @override
  List<Object> get props => [walletId];
}

class GetMonthlySummary extends GetSummaryEvent {
  final String walletId;
  final int year;
  final int month;

  const GetMonthlySummary(this.walletId, this.year, this.month);

  @override
  List<Object> get props => [walletId, year, month];
}

class GetYearlySummary extends GetSummaryEvent {
  final String walletId;
  final int year;

  const GetYearlySummary(this.walletId, this.year);

  @override
  List<Object> get props => [walletId, year];
}

class RefreshSummaries extends GetSummaryEvent {
  final String walletId;
  const RefreshSummaries(this.walletId);
  @override
  List<Object> get props => [walletId];
}

// ========== STATES ==========
abstract class GetSummaryState extends Equatable {
  const GetSummaryState();

  @override
  List<Object?> get props => [];
}

class GetSummaryInitial extends GetSummaryState {}

class GetSummaryLoading extends GetSummaryState {}

class GetSummaryFailure extends GetSummaryState {
  final String error;

  const GetSummaryFailure(this.error);

  @override
  List<Object> get props => [error];
}

class GetOverallSummarySuccess extends GetSummaryState {
  final OverallSummary summary;

  const GetOverallSummarySuccess(this.summary);

  @override
  List<Object> get props => [summary];
}

class GetMonthlySummarySuccess extends GetSummaryState {
  final MonthlySummary? summary;
  final int year;
  final int month;

  const GetMonthlySummarySuccess(this.summary, this.year, this.month);

  @override
  List<Object?> get props => [summary, year, month];
}

class GetYearlySummarySuccess extends GetSummaryState {
  final YearlySummary? summary;
  final int year;

  const GetYearlySummarySuccess(this.summary, this.year);

  @override
  List<Object?> get props => [summary, year];
}

// ========== BLOC ==========
class GetSummaryBloc extends Bloc<GetSummaryEvent, GetSummaryState> {
  final ExpenseRepository _repository;

  GetSummaryBloc(this._repository) : super(GetSummaryInitial()) {
    on<GetOverallSummary>(_onGetOverallSummary);
    on<GetMonthlySummary>(_onGetMonthlySummary);
    on<GetYearlySummary>(_onGetYearlySummary);
    on<RefreshSummaries>(_onRefreshSummaries);
  }

  Future<void> _onGetOverallSummary(
    GetOverallSummary event,
    Emitter<GetSummaryState> emit,
  ) async {
    emit(GetSummaryLoading());
    try {
      final summary = await _repository.getOverallSummary(event.walletId);
      emit(GetOverallSummarySuccess(summary));
    } catch (e) {
      emit(GetSummaryFailure(e.toString()));
    }
  }

  Future<void> _onGetMonthlySummary(
    GetMonthlySummary event,
    Emitter<GetSummaryState> emit,
  ) async {
    emit(GetSummaryLoading());
    try {
      final summary = await _repository.getMonthlySummary(
          event.walletId, event.year, event.month);
      emit(GetMonthlySummarySuccess(summary, event.year, event.month));
    } catch (e) {
      emit(GetSummaryFailure(e.toString()));
    }
  }

  Future<void> _onGetYearlySummary(
    GetYearlySummary event,
    Emitter<GetSummaryState> emit,
  ) async {
    emit(GetSummaryLoading());
    try {
      final summary =
          await _repository.getYearlySummary(event.walletId, event.year);
      emit(GetYearlySummarySuccess(summary, event.year));
    } catch (e) {
      emit(GetSummaryFailure(e.toString()));
    }
  }

  Future<void> _onRefreshSummaries(
    RefreshSummaries event,
    Emitter<GetSummaryState> emit,
  ) async {
    emit(GetSummaryLoading());
    try {
      // Refresh overall summary by default
      final summary = await _repository.getOverallSummary(event.walletId);
      emit(GetOverallSummarySuccess(summary));
    } catch (e) {
      emit(GetSummaryFailure(e.toString()));
    }
  }
}
