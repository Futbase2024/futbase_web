/// Respuesta estandarizada de la API
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
  });

  /// Si la petición fue exitosa
  final bool success;

  /// Datos de la respuesta (si success = true)
  final T? data;

  /// Mensaje descriptivo
  final String? message;

  /// Código de error (si success = false)
  final String? errorCode;

  /// Crea una respuesta exitosa
  factory ApiResponse.ok(T data, [String? message]) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  /// Crea una respuesta de error
  factory ApiResponse.error(String message, [String? errorCode]) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  /// Verifica si hay datos disponibles
  bool get hasData => data != null;

  @override
  String toString() {
    if (success) {
      return 'ApiResponse.success(data: $data, message: $message)';
    }
    return 'ApiResponse.error(message: $message, code: $errorCode)';
  }
}
