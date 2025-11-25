import 'package:flutter/material.dart';

enum UserRole { student, teacher, admin, superAdmin }
enum QuestionType { mcq, shortAnswer, fillInBlanks }
enum TestStatus { draft, published, completed, archived }
enum NotificationType { test, result, reminder, announcement }

// Authentication Result
class AuthResult {
  final bool success;
  final String? error;
  final User? user;

  AuthResult._({required this.success, this.error, this.user});

  factory AuthResult.success(User user) {
    return AuthResult._(success: true, user: user);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(success: false, error: error);
  }
}

class Department {
  final String id;
  final String name;
  final String code;
  final String description;
  final String collegeId;
  final DateTime createdAt;
  final bool isActive;

  Department({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.collegeId,
    required this.createdAt,
    required this.isActive,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      code: json['code'] ?? '', // Handle missing code field
      description: json['description'],
      collegeId: json['college_id'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'description': description,
      'college_id': collegeId,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
    
    // Only include id if it's not empty (let Supabase generate UUID)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }

  Department copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? collegeId,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Department(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      collegeId: collegeId ?? this.collegeId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class College {
  final String id;
  final String name;
  final String code;
  final String description;
  final String? logo;
  final String primaryColor;
  final String secondaryColor;
  final DateTime createdAt;
  final bool isActive;

  College({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    this.logo,
    required this.primaryColor,
    required this.secondaryColor,
    required this.createdAt,
    required this.isActive,
  });

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo_url'],
      primaryColor: json['primary_color'] ?? '#1976D2',
      secondaryColor: json['secondary_color'] ?? '#42A5F5',
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'code': code,
      'description': description,
      'logo_url': logo,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
    
    // Only include id if it's not empty (let Supabase generate UUID)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }

  College copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? logo,
    String? primaryColor,
    String? secondaryColor,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return College(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? profilePicture;
  final String collegeId;
  final String? departmentId; // For students and teachers
  final int? year; // For students (1, 2, 3, 4, etc.)
  final String? studentId; // For students - assigned by admin
  final String? employeeId; // For teachers/admins - assigned by admin
  final bool canChangePassword; // Only superAdmin can change passwords
  final DateTime createdAt;
  final DateTime lastLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profilePicture,
    required this.collegeId,
    this.departmentId,
    this.year,
    this.studentId,
    this.employeeId,
    this.canChangePassword = false,
    required this.createdAt,
    required this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere((e) => e.toString() == 'UserRole.${json['role']}'),
      phone: json['phone'],
      profilePicture: json['profile_picture'],
      collegeId: json['college_id'] ?? '', // Handle null college_id for SuperAdmin
      departmentId: json['department_id'],
      year: json['year'],
      studentId: json['student_id'],
      employeeId: json['employee_id'],
      canChangePassword: json['can_change_password'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'phone': phone,
      // 'profile_picture': profilePicture, // Column doesn't exist in database schema
      'college_id': collegeId,
      'department_id': departmentId,
      'year': year,
      // 'student_id': studentId, // Column doesn't exist in database schema
      // 'employee_id': employeeId, // Column doesn't exist in database schema
      // 'can_change_password': canChangePassword, // Column doesn't exist in database
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
    };
    
    // Only include id if it's not empty (let Supabase generate UUID)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }
}

class Question {
  final String id;
  final String testId;
  final String text; // Changed from questionText to text
  final QuestionType type;
  final List<Answer> options; // Changed from List<String> to List<Answer>
  final int correctAnswerIndex; // Changed from correctAnswer to correctAnswerIndex
  final int points;
  final int order;

  Question({
    required this.id,
    required this.testId,
    required this.text,
    required this.type,
    required this.options,
    required this.correctAnswerIndex,
    required this.points,
    required this.order,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      testId: json['test_id'],
      text: json['text'],
      type: QuestionType.values.firstWhere((e) => e.toString() == 'QuestionType.${json['question_type']}'),
      options: json['options'] != null ? (json['options'] as List).map((a) => Answer.fromJson(a)).toList() : [],
      correctAnswerIndex: json['correct_answer_index'] ?? 0,
      points: json['points'] ?? 1,
      order: json['order_index'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'test_id': testId,
      'text': text,
      'question_type': type.toString().split('.').last,
      'correct_answer_index': correctAnswerIndex,
      'points': points,
      'order_index': order,
    };
    
    // Only include id if it's not empty (let Supabase generate UUID)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }

  Question copyWith({
    String? id,
    String? testId,
    String? text,
    QuestionType? type,
    List<Answer>? options,
    int? correctAnswerIndex,
    int? points,
    int? order,
  }) {
    return Question(
      id: id ?? this.id,
      testId: testId ?? this.testId,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      points: points ?? this.points,
      order: order ?? this.order,
    );
  }
}

class Test {
  final String id;
  final String title;
  final String description;
  final String createdBy; // Changed from creatorId to createdBy
  final String collegeId;
  final String departmentId; // Changed from targetDepartmentId to departmentId
  final List<int>? targetYears; // Specific years (null = all years)
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes; // Changed from duration to durationMinutes
  final TestStatus status;
  final List<Question> questions;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final bool isActive;

  Test({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.collegeId,
    required this.departmentId,
    this.targetYears,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.status,
    required this.questions,
    required this.createdAt,
    this.publishedAt,
    this.isActive = true,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdBy: json['created_by'] ?? '',
      collegeId: json['college_id'],
      departmentId: json['department_id'] ?? '',
      targetYears: json['target_years'] != null ? List<int>.from(json['target_years']) : null,
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      durationMinutes: json['duration_minutes'] ?? 60,
      status: TestStatus.values.firstWhere((e) => e.toString() == 'TestStatus.${json['status']}'),
      questions: (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
      createdAt: DateTime.parse(json['created_at']),
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at']) : null,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'title': title,
      'description': description,
      'created_by': createdBy,
      'college_id': collegeId,
      'department_id': departmentId,
      'target_years': targetYears,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration_minutes': durationMinutes,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'is_active': isActive,
    };
    
    // Only include id if it's not empty (let Supabase generate UUID)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }

  Test copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    String? collegeId,
    String? departmentId,
    List<int>? targetYears,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    TestStatus? status,
    List<Question>? questions,
    DateTime? createdAt,
    DateTime? publishedAt,
    bool? isActive,
  }) {
    return Test(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      collegeId: collegeId ?? this.collegeId,
      departmentId: departmentId ?? this.departmentId,
      targetYears: targetYears ?? this.targetYears,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

class TestResult {
  final String id;
  final String testId;
  final String studentId;
  final String testTitle;
  final List<Answer> answers;
  final int score;
  final int totalQuestions; // Changed from totalScore to totalQuestions
  final int correctAnswers; // Added correctAnswers field
  final int timeSpent; // Added timeSpent field
  final DateTime submittedAt;
  final DateTime completedAt;
  final bool isSynced;

  TestResult({
    required this.id,
    required this.testId,
    required this.studentId,
    required this.testTitle,
    required this.answers,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpent,
    required this.submittedAt,
    required this.completedAt,
    required this.isSynced,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'],
      testId: json['test_id'],
      studentId: json['student_id'],
      testTitle: json['test_title'] ?? '',
      answers: (json['answers'] as List).map((a) => Answer.fromJson(a)).toList(),
      score: json['score'],
      totalQuestions: json['total_questions'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      timeSpent: json['time_spent_minutes'] ?? 0,
      submittedAt: DateTime.parse(json['submitted_at']),
      completedAt: DateTime.parse(json['completed_at'] ?? json['submitted_at']),
      isSynced: json['is_synced'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'test_id': testId,
      'student_id': studentId,
      'answers': answers.map((a) => a.toJson()).toList(),
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'time_spent_minutes': timeSpent,
      'submitted_at': submittedAt.toIso8601String(),
      'is_completed': true,
    };
    
    // Only include id if it's not empty (let database generate UUID)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }
}

class Answer {
  final String id;
  final String questionId;
  final String studentId;
  final String text; // Changed from answerText to text
  final bool isCorrect;
  final DateTime submittedAt;

  Answer({
    required this.id,
    required this.questionId,
    required this.studentId,
    required this.text,
    required this.isCorrect,
    required this.submittedAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      questionId: json['question_id'],
      studentId: json['student_id'] ?? '',
      text: json['text'],
      isCorrect: json['is_correct'] ?? false,
      submittedAt: DateTime.parse(json['submitted_at'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'question_id': questionId,
      'student_id': studentId,
      'text': text,
      'is_correct': isCorrect,
      'submitted_at': submittedAt.toIso8601String(),
    };
    
    // Only include id if it's not empty (let Supabase generate UUID)
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }

  Answer copyWith({
    String? id,
    String? questionId,
    String? studentId,
    String? text,
    bool? isCorrect,
    DateTime? submittedAt,
  }) {
    return Answer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      studentId: studentId ?? this.studentId,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.relatedId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.announcement,
      ),
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      relatedId: json['related_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'related_id': relatedId,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? relatedId,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
    );
  }
}
