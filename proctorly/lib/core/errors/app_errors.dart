// Application Error Classes
abstract class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic details;
  
  const AppError(this.message, {this.code, this.details});
  
  @override
  String toString() => 'AppError: $message';
}

class NetworkError extends AppError {
  const NetworkError(String message, {String? code, dynamic details}) 
      : super(message, code: code, details: details);
}

class AuthError extends AppError {
  const AuthError(String message, {String? code, dynamic details}) 
      : super(message, code: code, details: details);
}

class DatabaseError extends AppError {
  const DatabaseError(String message, {String? code, dynamic details}) 
      : super(message, code: code, details: details);
}

class ValidationError extends AppError {
  const ValidationError(String message, {String? code, dynamic details}) 
      : super(message, code: code, details: details);
}

class NotFoundError extends AppError {
  const NotFoundError(String message, {String? code, dynamic details}) 
      : super(message, code: code, details: details);
}

class PermissionError extends AppError {
  const PermissionError(String message, {String? code, dynamic details}) 
      : super(message, code: code, details: details);
}