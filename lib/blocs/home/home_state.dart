import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLogoutSuccess extends HomeState {
  final String message;

  const HomeLogoutSuccess({this.message = 'Logout successful'});

  @override
  List<Object> get props => [message];
}

class HomeLogoutFailure extends HomeState {
  final String error;

  const HomeLogoutFailure({required this.error});

  @override
  List<Object> get props => [error];
}
