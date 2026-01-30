import 'package:equatable/equatable.dart';

class StatusWrapper<T> extends Equatable {
  const StatusWrapper({
    this.value,
    this.status = Status.initial,
  });

  final T? value;
  final Status status;

  bool get isInitial => status == Status.initial;
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;

  StatusWrapper<T> copyWith({
    T? value,
    Status? status,
  }) {
    return StatusWrapper<T>(
      value: value ?? this.value,
      status: status ?? this.status,
    );
  }

  StatusWrapper<T> toInitial([T? value]) {
    return copyWith(
      value: value,
      status: Status.initial,
    );
  }

  StatusWrapper<T> toLoading([T? value]) {
    return copyWith(
      value: value,
      status: Status.loading,
    );
  }

  StatusWrapper<T> toSuccess([T? value]) {
    return copyWith(
      value: value,
      status: Status.success,
    );
  }

  StatusWrapper<T> toError([T? value]) {
    return copyWith(
      value: value,
      status: Status.error,
    );
  }

  @override
  String toString() {
    // If value is a list, just show the type and length to keep logs clean
    if (value is List) {
      final list = value as List;
      return 'StatusWrapper(status: $status, value: List<${list.isNotEmpty ? list.first.runtimeType : "dynamic"}>(${list.length}))';
    }
    return 'StatusWrapper(status: $status, value: $value)';
  }

  @override
  List<Object?> get props => [value, status];
}

enum Status { initial, loading, success, error }
