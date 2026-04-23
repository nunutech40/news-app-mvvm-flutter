enum ViewStatus { initial, loading, success, error }

class ViewState<T> {
  final ViewStatus status;
  final T? data;
  final String? errorMessage;

  const ViewState({
    this.status = ViewStatus.initial,
    this.data,
    this.errorMessage,
  });

  factory ViewState.initial() => const ViewState(status: ViewStatus.initial);
  
  factory ViewState.loading([T? existingData]) => ViewState(
        status: ViewStatus.loading,
        data: existingData,
      );
      
  factory ViewState.success(T data) => ViewState(
        status: ViewStatus.success,
        data: data,
      );
      
  factory ViewState.error(String message, [T? existingData]) => ViewState(
        status: ViewStatus.error,
        errorMessage: message,
        data: existingData,
      );

  bool get isInitial => status == ViewStatus.initial;
  bool get isLoading => status == ViewStatus.loading;
  bool get isSuccess => status == ViewStatus.success;
  bool get isError => status == ViewStatus.error;
}
