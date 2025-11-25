import '../network/network_service.dart';
import '../errors/app_errors.dart';
import '../../models/models.dart';

class TestRepository {
  final NetworkService _networkService;

  TestRepository(this._networkService);

  Future<Test> getTestById(String testId) async {
    try {
      final response = await _networkService.post<Map<String, dynamic>>(
        '/rpc/get_test_with_questions',
        body: {'test_id_param': testId}
      );
      
      if (response.success && response.data != null) {
        final testData = response.data!['test'] as Map<String, dynamic>;
        final questionsData = response.data!['questions'] as List<dynamic>;
        
        // Parse questions
        final questions = questionsData.map((questionJson) {
          // Sort options by order_index to match the correct_answer_index
          final optionsData = (questionJson['options'] as List<dynamic>).toList();
          optionsData.sort((a, b) => (a['order_index'] ?? 0).compareTo(b['order_index'] ?? 0));
          
          final options = optionsData.map((optionJson) {
            return Answer(
              id: optionJson['id'] ?? '',
              questionId: optionJson['question_id'] ?? '',
              studentId: '', // Not needed for options
              text: optionJson['text'] ?? '',
              isCorrect: optionJson['is_correct'] ?? false,
              submittedAt: DateTime.now(), // Not needed for options
            );
          }).toList();
          
          final question = Question(
            id: questionJson['id'] ?? '',
            testId: questionJson['test_id'] ?? '',
            text: questionJson['text'] ?? '',
            type: QuestionType.values.firstWhere(
              (e) => e.toString() == 'QuestionType.${questionJson['question_type']}',
              orElse: () => QuestionType.mcq,
            ),
            points: questionJson['points'] ?? 1,
            order: questionJson['order_index'] ?? 0,
            correctAnswerIndex: questionJson['correct_answer_index'] ?? 0,
            options: options,
          );
          
          print('🔍 Question Loading Debug:');
          print('  Question: ${question.text}');
          print('  Correct Answer Index: ${question.correctAnswerIndex}');
          print('  Options: ${question.options.map((o) => o.text).toList()}');
          print('  Correct Answer Text: ${question.options[question.correctAnswerIndex].text}');
          
          return question;
        }).toList();
        
        // Create Test object
        return Test(
          id: testData['id'] ?? '',
          title: testData['title'] ?? '',
          description: testData['description'] ?? '',
          createdBy: testData['created_by'] ?? '',
          collegeId: testData['college_id'] ?? '',
          departmentId: testData['department_id'] ?? '',
          targetYears: testData['target_years'] != null 
              ? List<int>.from(testData['target_years']) 
              : null,
          startTime: DateTime.parse(testData['start_time']),
          endTime: DateTime.parse(testData['end_time']),
          durationMinutes: testData['duration_minutes'] ?? 60,
          status: TestStatus.values.firstWhere(
            (e) => e.toString() == 'TestStatus.${testData['status']}',
            orElse: () => TestStatus.draft,
          ),
          questions: questions,
          createdAt: DateTime.parse(testData['created_at']),
          publishedAt: testData['published_at'] != null 
              ? DateTime.parse(testData['published_at']) 
              : null,
          isActive: testData['is_active'] ?? true,
        );
      }
      throw Exception('Failed to fetch test');
    } catch (e) {
      print('Error fetching test by ID: $e');
      rethrow;
    }
  }

  Future<List<Test>> getTests() async {
    try {
      final response = await _networkService.get('/rpc/get_tests_with_stats');
      if (response.success && response.data != null) {
        final List<dynamic> testsJson = response.data as List<dynamic>;
        return testsJson.map((json) {
          // Create a Test object from the stats data
          // The question_count is included in the response
          final questionCount = json['question_count'] ?? 0;
          
          return Test(
            id: json['id'] ?? '',
            title: json['title'] ?? '',
            description: json['description'] ?? '',
            createdBy: json['created_by'] ?? '',
            collegeId: json['college_id'] ?? '',
            departmentId: json['department_id'] ?? '',
            targetYears: json['target_years'] != null 
                ? List<int>.from(json['target_years']) 
                : null,
            startTime: DateTime.parse(json['start_time']),
            endTime: DateTime.parse(json['end_time']),
            durationMinutes: json['duration_minutes'] ?? 60,
            status: TestStatus.values.firstWhere(
              (e) => e.toString() == 'TestStatus.${json['status']}',
              orElse: () => TestStatus.draft,
            ),
            questions: List.generate(questionCount, (index) => Question(
              id: 'placeholder_$index',
              testId: json['id'] ?? '',
              text: 'Loading...',
              type: QuestionType.mcq,
              points: 1,
              order: index,
              correctAnswerIndex: 0,
              options: [],
            )), // Create placeholder questions based on count
            createdAt: DateTime.parse(json['created_at']),
            publishedAt: json['published_at'] != null 
                ? DateTime.parse(json['published_at']) 
                : null,
            isActive: json['is_active'] ?? true,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching tests: $e');
      return [];
    }
  }

  Future<Test> createTest(Test test) async {
    try {
      print('🔍 TestRepository: Creating test - ${test.title}');
      print('🔍 TestRepository: Questions count: ${test.questions.length}');
      
      // Prepare questions data for the database function
      final questionsData = test.questions.map((question) => {
        'text': question.text,
        'question_type': question.type.toString().split('.').last,
        'points': question.points,
        'correct_answer_index': question.correctAnswerIndex,
        'options': question.options.map((option) => {
          'text': option.text,
          'is_correct': option.isCorrect,
        }).toList(),
      }).toList();
      
      final requestBody = {
        'test_title': test.title,
        'test_description': test.description,
        'test_duration_minutes': test.durationMinutes,
        'test_college_id': test.collegeId,
        'test_department_id': test.departmentId,
        'test_created_by': test.createdBy,
        'test_start_time': test.startTime.toIso8601String(),
        'test_end_time': test.endTime.toIso8601String(),
        'test_target_years': test.targetYears,
        'questions_data': questionsData,
      };
      
      print('🔍 TestRepository: Request body prepared');
      
      final response = await _networkService.post<Map<String, dynamic>>(
        '/rpc/create_test_with_questions', 
        body: requestBody
      );
      
      print('🔍 TestRepository: Response success: ${response.success}');
      print('🔍 TestRepository: Response data: ${response.data}');
      print('🔍 TestRepository: Response error: ${response.error}');
      
      if (response.success && response.data != null) {
        final testId = response.data!['test_id'] as String;
        print('✅ TestRepository: Test created with ID: $testId');
        
        // Fetch the complete test data
        final fetchResponse = await _networkService.post<Map<String, dynamic>>(
          '/rpc/get_test_with_questions',
          body: {'test_id_param': testId}
        );
        
        if (fetchResponse.success && fetchResponse.data != null) {
          final testData = fetchResponse.data!['test'] as Map<String, dynamic>;
          final questionsData = fetchResponse.data!['questions'] as List<dynamic>;
          
          // Convert questions data to Question objects
          final questions = questionsData.map((qData) {
            final q = qData as Map<String, dynamic>;
            final options = (q['options'] as List).map((optData) {
              final opt = optData as Map<String, dynamic>;
              return Answer(
                id: opt['id'] ?? '',
                questionId: q['id'] ?? '',
                studentId: '', // Not applicable for test creation
                text: opt['text'] ?? '',
                isCorrect: opt['is_correct'] ?? false,
                submittedAt: DateTime.now(), // Not applicable for test creation
              );
            }).toList();
            
            return Question(
              id: q['id'] ?? '',
              testId: q['test_id'] ?? '',
              text: q['text'] ?? '',
              type: QuestionType.values.firstWhere(
                (e) => e.toString() == 'QuestionType.${q['question_type']}',
                orElse: () => QuestionType.mcq,
              ),
              options: options,
              correctAnswerIndex: q['correct_answer_index'] ?? 0,
              points: q['points'] ?? 1,
              order: q['order_index'] ?? 0,
            );
          }).toList();
          
          final createdTest = Test(
            id: testData['id'] ?? '',
            title: testData['title'] ?? '',
            description: testData['description'] ?? '',
            createdBy: testData['created_by'] ?? '',
            collegeId: testData['college_id'] ?? '',
            departmentId: testData['department_id'] ?? '',
            targetYears: testData['target_years'] != null 
                ? List<int>.from(testData['target_years']) 
                : null,
            startTime: DateTime.parse(testData['start_time']),
            endTime: DateTime.parse(testData['end_time']),
            durationMinutes: testData['duration_minutes'] ?? 60,
            status: TestStatus.values.firstWhere(
              (e) => e.toString() == 'TestStatus.${testData['status']}',
              orElse: () => TestStatus.draft,
            ),
            questions: questions,
            createdAt: DateTime.parse(testData['created_at']),
            publishedAt: testData['published_at'] != null 
                ? DateTime.parse(testData['published_at']) 
                : null,
            isActive: testData['is_active'] ?? true,
          );
          
          print('✅ TestRepository: Successfully created test: ${createdTest.title}');
          return createdTest;
        } else {
          throw Exception('Failed to fetch created test: ${fetchResponse.error}');
        }
      }
      throw Exception('Failed to create test: ${response.error}');
    } catch (e) {
      print('❌ TestRepository: Error creating test: $e');
      rethrow;
    }
  }

  Future<Test> updateTest(Test test) async {
    try {
      final response = await _networkService.put<Map<String, dynamic>>('/tests/${test.id}', body: test.toJson());
      if (response.success && response.data != null) {
        return Test.fromJson(response.data!);
      }
      throw Exception('Failed to update test');
    } catch (e) {
      print('Error updating test: $e');
      rethrow;
    }
  }

  Future<void> deleteTest(String testId) async {
    try {
      await _networkService.delete('/tests/$testId');
    } catch (e) {
      print('Error deleting test: $e');
      rethrow;
    }
  }

  Future<void> publishTest(String testId) async {
    try {
      await _networkService.put('/tests/$testId/publish');
    } catch (e) {
      print('Error publishing test: $e');
      rethrow;
    }
  }
}
