// Validation Result
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  
  const ValidationResult({
    required this.isValid,
    required this.errors,
  });
  
  factory ValidationResult.success() {
    return const ValidationResult(isValid: true, errors: []);
  }
  
  factory ValidationResult.failure(List<String> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }
}

// Validators
class Validators {
  // Email validation
  static ValidationResult validateEmail(String email) {
    if (email.isEmpty) {
      return ValidationResult.failure(['Email is required']);
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.failure(['Please enter a valid email address']);
    }
    
    return ValidationResult.success();
  }
  
  // Password validation
  static ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult.failure(['Password is required']);
    }
    
    if (password.length < 6) {
      return ValidationResult.failure(['Password must be at least 6 characters long']);
    }
    
    return ValidationResult.success();
  }
  
  // Name validation
  static ValidationResult validateName(String name) {
    if (name.isEmpty) {
      return ValidationResult.failure(['Name is required']);
    }
    
    if (name.length < 2) {
      return ValidationResult.failure(['Name must be at least 2 characters long']);
    }
    
    return ValidationResult.success();
  }
  
  // Test validation
  static ValidationResult validateTest({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required int duration,
    required List<dynamic> questions,
  }) {
    final errors = <String>[];
    
    if (title.isEmpty) {
      errors.add('Test title is required');
    }
    
    if (description.isEmpty) {
      errors.add('Test description is required');
    }
    
    if (endTime.isBefore(startTime)) {
      errors.add('End time must be after start time');
    }
    
    if (duration <= 0) {
      errors.add('Test duration must be greater than 0');
    }
    
    if (questions.isEmpty) {
      errors.add('At least one question is required');
    }
    
    return errors.isEmpty 
        ? ValidationResult.success() 
        : ValidationResult.failure(errors);
  }
  
  // Question validation
  static ValidationResult validateQuestion({
    required String questionText,
    required String type,
    required List<String>? options,
    required String correctAnswer,
    required int points,
  }) {
    final errors = <String>[];
    
    if (questionText.isEmpty) {
      errors.add('Question text is required');
    }
    
    if (correctAnswer.isEmpty) {
      errors.add('Correct answer is required');
    }
    
    if (points <= 0) {
      errors.add('Points must be greater than 0');
    }
    
    if (type == 'mcq' && (options == null || options.length < 2)) {
      errors.add('MCQ questions must have at least 2 options');
    }
    
    return errors.isEmpty 
        ? ValidationResult.success() 
        : ValidationResult.failure(errors);
  }
  
  // College validation
  static ValidationResult validateCollege({
    required String name,
    required String code,
    required String description,
  }) {
    final errors = <String>[];
    
    if (name.isEmpty) {
      errors.add('College name is required');
    }
    
    if (code.isEmpty) {
      errors.add('College code is required');
    }
    
    if (description.isEmpty) {
      errors.add('College description is required');
    }
    
    return errors.isEmpty 
        ? ValidationResult.success() 
        : ValidationResult.failure(errors);
  }
  
  // Department validation
  static ValidationResult validateDepartment({
    required String name,
    required String code,
    required String description,
    required String collegeId,
  }) {
    final errors = <String>[];
    
    if (name.isEmpty) {
      errors.add('Department name is required');
    }
    
    if (code.isEmpty) {
      errors.add('Department code is required');
    }
    
    if (description.isEmpty) {
      errors.add('Department description is required');
    }
    
    if (collegeId.isEmpty) {
      errors.add('College selection is required');
    }
    
    return errors.isEmpty 
        ? ValidationResult.success() 
        : ValidationResult.failure(errors);
  }
  
  // User validation
  static ValidationResult validateUser({
    required String name,
    required String email,
    required String role,
    String? studentId,
    String? employeeId,
    String? departmentId,
    int? year,
  }) {
    final errors = <String>[];
    
    final nameResult = validateName(name);
    if (!nameResult.isValid) {
      errors.addAll(nameResult.errors);
    }
    
    final emailResult = validateEmail(email);
    if (!emailResult.isValid) {
      errors.addAll(emailResult.errors);
    }
    
    if (role == 'student') {
      if (studentId == null || studentId.isEmpty) {
        errors.add('Student ID is required');
      }
      if (departmentId == null || departmentId.isEmpty) {
        errors.add('Department selection is required');
      }
      if (year == null || year < 1 || year > 4) {
        errors.add('Valid year (1-4) is required');
      }
    } else if (role == 'teacher' || role == 'admin') {
      if (employeeId == null || employeeId.isEmpty) {
        errors.add('Employee ID is required');
      }
      if (departmentId == null || departmentId.isEmpty) {
        errors.add('Department selection is required');
      }
    }
    
    return errors.isEmpty 
        ? ValidationResult.success() 
        : ValidationResult.failure(errors);
  }
}
