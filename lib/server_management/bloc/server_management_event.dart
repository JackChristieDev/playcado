part of 'server_management_bloc.dart';

abstract class ServerManagementEvent extends Equatable {
  const ServerManagementEvent();

  @override
  List<Object> get props => [];
}

class ServerManagementLoadLastUsed extends ServerManagementEvent {}

class ServerManagementPopulateForm extends ServerManagementEvent {
  final ServerCredentials credentials;

  const ServerManagementPopulateForm(this.credentials);

  @override
  List<Object> get props => [credentials];
}

class ServerManagementClearForm extends ServerManagementEvent {}
