class ErrorResponse {
  final String? timestamp;
  final int status;
  final String error;
  final String message;
  final List<FieldError>? errors;

  ErrorResponse({
    this.timestamp,
    required this.status,
    required this.error,
    required this.message,
    this.errors,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      timestamp: json['timestamp'] as String?,
      status: json['status'] as int,
      error: json['error'] as String,
      message: json['message'] as String,
      errors: json['errors'] != null
          ? (json['errors'] as List).map((i) => FieldError.fromJson(i)).toList()
          : null,
    );
  }
}

class FieldError {
  final String field;
  final String value;
  final String reason;

  FieldError({
    required this.field,
    required this.value,
    required this.reason,
  });

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] as String,
      value: json['value']?.toString() ?? '',
      reason: json['reason'] as String,
    );
  }
}
