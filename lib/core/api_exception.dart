class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, this.statusCode, this.errors});

  @override
  String toString() => message;
}
